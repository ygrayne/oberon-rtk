#!/usr/bin/env python3
"""
gen-dev -- Generate merged definition modules from per-device sources.
--
Reads per-peripheral and per-subsystem Oberon definition modules from
a source directory and merges their CONST sections into output modules.
Source files are grouped by name suffix:

    *_SYS.mod  ->  SYS.mod
    *_DEV.mod  ->  DEV.mod

All source modules live in one directory. The tool produces one output
module per group, with intra-group imports resolved and qualified
references rewritten.

Each source module is a standard Oberon module:

    MODULE UART_DEV;
    (** UART device definitions for STM32U585. **)
      IMPORT BASE, RCC_SYS;
      CONST
        USART1_BASE* = BASE.USART1_BASE;
        USART1_BC_reg* = RCC_SYS.RCC_APB2ENR;
        ...
    END UART_DEV.
--
Usage:
    python gen-dev.py <source_dir> <output_dir> [-v]

    source_dir      Directory containing *_SYS.mod and *_DEV.mod files
    output_dir      Directory for generated SYS.mod and DEV.mod

Example:
    python gen-dev.py cfg/src cfg/
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import re
import argparse
from pathlib import Path


# Groups: suffix pattern -> output module name
GROUPS = {
    '_SYS': 'SYS',
    '_DEV': 'DEV',
}


def parse_source(path):
    """Parse an Oberon definition module.

    Returns (module_name, imports, const_lines, docstring) where:
      module_name: str
      imports: list of str (imported module names)
      const_lines: list of str (raw CONST lines, comments/blanks stripped)
      docstring: str or None
    """
    text = path.read_text(encoding='utf-8')
    lines = text.split('\n')

    module_name = None
    imports = []
    const_lines = []
    docstring = None
    in_const = False
    in_docstring = False
    doc_lines = []

    for line in lines:
        stripped = line.strip()

        # module name
        if module_name is None:
            m = re.match(r'MODULE\s+(\w+)\s*;', stripped)
            if m:
                module_name = m.group(1)
                continue

        # docstring: first (* ... *) block after MODULE
        if module_name and docstring is None and not imports and not in_const:
            if in_docstring:
                doc_lines.append(line)
                if '*)' in stripped:
                    docstring = '\n'.join(doc_lines)
                    in_docstring = False
                continue
            if stripped.startswith('(*'):
                in_docstring = True
                doc_lines.append(line)
                if '*)' in stripped:
                    docstring = '\n'.join(doc_lines)
                    in_docstring = False
                continue

        # import list (collect until semicolon)
        if stripped.startswith('IMPORT'):
            import_text = stripped[6:]
            idx = lines.index(line)
            if ';' not in import_text:
                for next_line in lines[idx + 1:]:
                    import_text += ' ' + next_line.strip()
                    if ';' in next_line:
                        break
            import_text = import_text.rstrip(';').strip()
            for part in import_text.split(','):
                part = part.strip()
                if part:
                    if ':=' in part:
                        part = part.split(':=')[-1].strip()
                    imports.append(part)
            continue

        # CONST section
        if stripped == 'CONST':
            in_const = True
            continue

        # END module
        if re.match(r'END\s+\w+\s*\.', stripped):
            in_const = False
            continue

        if in_const:
            # skip blank lines and standalone comment lines
            if not stripped:
                continue
            if stripped.startswith('(*') and stripped.endswith('*)'):
                continue
            const_lines.append(line)

    return module_name, imports, const_lines, docstring


def _resolve_cross_group(imp):
    """Resolve a cross-group import to its output module name.
    E.g. RCC_SYS -> SYS, UART_DEV -> DEV. If no match, return as-is."""
    for suffix, out_name in GROUPS.items():
        if imp.endswith(suffix):
            return out_name
    return imp


def _topo_sort(sources):
    """Sort sources by intra-group dependencies (topological order).

    A source that imports another source in the same group must come
    after it. Sources with no intra-group dependencies come first.
    """
    source_names = {mod_name for _, mod_name, _, _, _ in sources}
    by_name = {mod_name: src for src in sources for _, mod_name, _, _, _ in [src]}

    # build adjacency: mod_name -> set of intra-group dependencies
    deps = {}
    for _, mod_name, imports, _, _ in sources:
        deps[mod_name] = {imp for imp in imports if imp in source_names}

    # Kahn's algorithm
    order = []
    ready = [n for n in deps if not deps[n]]
    while ready:
        ready.sort(reverse=True)  # deterministic: alphabetical within level
        n = ready.pop()
        order.append(n)
        for m in deps:
            deps[m].discard(n)
            if not deps[m] and m not in order and m not in ready:
                ready.append(m)

    if len(order) != len(sources):
        missing = source_names - set(order)
        print(f'gen-dev: circular dependency among: {", ".join(sorted(missing))}')
        sys.exit(1)

    return [by_name[n] for n in order]


def generate_module(name, sources):
    """Generate merged module content from parsed sources.

    sources: list of (source_path, module_name, imports, const_lines, docstring)
    Returns the output module text.
    """
    # sort by intra-group dependencies
    sources = _topo_sort(sources)

    # collect source module names for intra-group filtering
    source_names = {mod_name for _, mod_name, _, _, _ in sources}

    # collect external imports, rewriting cross-group references
    # e.g. RCC_SYS (a _SYS source) imported by a _DEV source -> SYS
    all_imports = []
    seen_imports = set()
    for _, mod_name, imports, _, _ in sources:
        for imp in imports:
            if imp in source_names:
                continue  # intra-group: drop
            resolved = _resolve_cross_group(imp)
            if resolved not in seen_imports:
                all_imports.append(resolved)
                seen_imports.add(resolved)

    # rewrite qualified references in CONST lines:
    # - intra-group: RCC_SYS.X -> X (same module after merge)
    # - cross-group: RCC_SYS.X -> SYS.X (merged into other output)
    for idx, (src_path, mod_name, imports, const_lines, docstring) in enumerate(sources):
        rewritten = []
        for line in const_lines:
            for sn in source_names:
                line = line.replace(f'{sn}.', '')
            for suffix, out_name in GROUPS.items():
                # rewrite references to source modules of OTHER groups
                import re as _re
                line = _re.sub(
                    r'\b(\w+' + _re.escape(suffix) + r')\.',
                    lambda m: f'{out_name}.' if m.group(1) not in source_names else '',
                    line)
            rewritten.append(line)
        sources[idx] = (src_path, mod_name, imports, rewritten, docstring)

    out = []
    out.append(f'MODULE {name};')
    out.append(f'(** Generated by gen-dev. Do not edit. **)')
    out.append('')

    if all_imports:
        out.append(f'  IMPORT {", ".join(all_imports)};')
        out.append('')

    out.append('  CONST')
    out.append('')

    for src_path, mod_name, imports, const_lines, docstring in sources:
        out.append(f'  (* == {mod_name} == *)')
        for line in const_lines:
            out.append(line)
        out.append('')

    out.append(f'END {name}.')
    out.append('')

    return '\n'.join(out)


def main():
    parser = argparse.ArgumentParser(
        prog='gen-dev',
        description='Generate merged definition modules from per-device sources.',
    )
    parser.add_argument('source_dir', type=Path,
        help='directory containing *_SYS.mod and *_DEV.mod files')
    parser.add_argument('output_dir', type=Path,
        help='output directory for generated SYS.mod and DEV.mod')
    parser.add_argument('-v', '--verbose', action='store_true',
        help='verbose output')
    args = parser.parse_args()

    if not args.source_dir.is_dir():
        print(f'gen-dev: source directory not found: {args.source_dir}')
        sys.exit(1)

    if not args.output_dir.is_dir():
        print(f'gen-dev: output directory not found: {args.output_dir}')
        sys.exit(1)

    # group source files by suffix
    groups = {}
    for suffix, out_name in GROUPS.items():
        files = sorted(args.source_dir.glob(f'*{suffix}.mod'))
        if files:
            groups[out_name] = files

    if not groups:
        print(f'gen-dev: no *_SYS.mod or *_DEV.mod files in {args.source_dir}')
        sys.exit(1)

    # process each group
    for out_name, source_files in groups.items():
        sources = []
        for sf in source_files:
            name, imports, const_lines, docstring = parse_source(sf)
            if name is None:
                print(f'gen-dev: cannot parse MODULE name in {sf}')
                sys.exit(1)
            if not const_lines:
                if args.verbose:
                    print(f'  skip: {sf.name} (no CONST)')
                continue
            sources.append((sf, name, imports, const_lines, docstring))
            if args.verbose:
                print(f'  read: {sf.name} ({len(const_lines)} lines, '
                      f'imports: {", ".join(imports) if imports else "none"})')

        if not sources:
            continue

        output_path = args.output_dir / f'{out_name}.mod'
        output = generate_module(out_name, sources)
        output_path.write_text(output, encoding='utf-8')
        print(f'gen-dev: {output_path} ({len(sources)} sources)')


if __name__ == '__main__':
    main()
