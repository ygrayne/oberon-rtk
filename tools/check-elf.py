"""
check-elf -- Offline ELF/DWARF validation tool.
--
Compares DWARF debug data in an ELF file against ground truth from
assembly listing (.alst) files and the linker .map file, using
arm-none-eabi-readelf. Checks section structure, symbol table,
debug info entries, line number programs, and frame descriptions.
--
Usage:
    python check-elf.py <elf-file> [options]

    --rdb-dir DIR         Directory with .alst files (default: rdb)
    --map FILE            Linker .map file (default: auto-detect in cwd)
    --sym-prefix P        Expected symbol prefix (e.g. S for Secure)
    -v, --verbose         Show all checks including PASS
    --readelf PATH        Path to readelf (env: RTK_READELF;
                          default: arm-none-eabi-readelf)

Example:
    python check-elf.py SignalSync.elf
    python check-elf.py SignalSync.elf --map SignalSync.map -v
    python check-elf.py S.elf --sym-prefix S -v
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

# Import elfdata module
_pylib_dir = str(Path(__file__).resolve().parent / 'pylib')
if _pylib_dir not in sys.path:
    sys.path.insert(0, _pylib_dir)
import elfdata


# Readelf / objdump output parsing

def _run(cmd, timeout=30):
    """Run a command, return stdout as string."""
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    if result.returncode != 0:
        print(f"ERROR: {' '.join(cmd)}")
        print(result.stderr)
        sys.exit(1)
    return result.stdout


def parse_section_headers(readelf, elf_path):
    """Parse readelf -S output into list of section dicts."""
    out = _run([readelf, '-S', str(elf_path)])
    sections = {}
    for m in re.finditer(
        r'\[\s*(\d+)\]\s+(\S+)\s+(\S+)\s+([0-9a-f]+)\s+([0-9a-f]+)\s+([0-9a-f]+)',
        out
    ):
        name = m.group(2)
        if name:
            sections[name] = {
                'index': int(m.group(1)),
                'type': m.group(3),
                'addr': int(m.group(4), 16),
                'offset': int(m.group(5), 16),
                'size': int(m.group(6), 16),
            }
    return sections


def parse_symbol_table(readelf, elf_path):
    """Parse readelf -s output into list of symbol dicts."""
    out = _run([readelf, '-sW', str(elf_path)])
    symbols = []
    for line in out.splitlines():
        # Format: Num: Value Size Type Bind Vis Ndx Name
        m = re.match(
            r'\s*\d+:\s+([0-9a-f]+)\s+(\d+)\s+(\S+)\s+(\S+)\s+\S+\s+\S+\s+(.*)',
            line
        )
        if m:
            name = m.group(5).strip()
            if not name:
                continue
            symbols.append({
                'address': int(m.group(1), 16),
                'size': int(m.group(2)),
                'type': m.group(3),
                'bind': m.group(4),
                'name': name,
            })
    return symbols


def parse_debug_info(readelf, elf_path):
    """Parse readelf --debug-dump=info into structured DIE tree.

    Uses depth field from readelf output to track context rather than
    a stack, so child counts don't affect scope detection.
    """
    out = _run([readelf, '--debug-dump=info', str(elf_path)])
    cus = []
    current_cu = None
    current_subprog = None
    # current_die: the most recent DIE at each depth level
    current_die = {}

    for line in out.splitlines():
        # Compilation Unit header
        m = re.match(r'\s*Compilation Unit @ offset (\d+|0x[0-9a-f]+):', line)
        if m:
            if current_cu:
                cus.append(current_cu)
            current_cu = {'offset': int(m.group(1), 0), 'attrs': {}, 'subprograms': [],
                          'types': [], 'global_vars': []}
            current_subprog = None
            current_die = {}
            continue

        # DIE entry: <depth><offset>: Abbrev Number: N (TAG)
        m = re.match(r'\s*<(\d+)><([0-9a-f]+)>: Abbrev Number: (\d+)\s*\((\S+)\)', line)
        if m:
            depth = int(m.group(1))
            offset = int(m.group(2), 16)
            tag = m.group(4)

            # Depth 1 DIEs that aren't subprograms close any open subprogram
            if depth == 1 and tag != 'DW_TAG_subprogram':
                current_subprog = None

            die = {'offset': offset, 'attrs': {}, 'tag': tag, 'depth': depth}
            current_die[depth] = die
            # Clear deeper entries
            for d in list(current_die.keys()):
                if d > depth:
                    del current_die[d]

            if tag == 'DW_TAG_compile_unit':
                pass  # attrs go to current_cu
            elif tag == 'DW_TAG_subprogram':
                current_subprog = {'offset': offset, 'attrs': {}, 'params': [], 'locals': []}
                if current_cu:
                    current_cu['subprograms'].append(current_subprog)
            elif tag == 'DW_TAG_formal_parameter' and current_subprog:
                param = {'offset': offset, 'attrs': {}}
                current_subprog['params'].append(param)
                die['_target'] = param
            elif tag == 'DW_TAG_variable':
                var = {'offset': offset, 'attrs': {}}
                if current_subprog and depth >= 2:
                    current_subprog['locals'].append(var)
                elif current_cu and depth == 1:
                    current_cu['global_vars'].append(var)
                die['_target'] = var
            elif tag == 'DW_TAG_base_type':
                btype = {'offset': offset, 'attrs': {}, 'tag': tag}
                if current_cu:
                    current_cu['types'].append(btype)
                die['_target'] = btype
            elif tag in ('DW_TAG_structure_type', 'DW_TAG_array_type',
                         'DW_TAG_pointer_type', 'DW_TAG_subroutine_type'):
                ctype = {'offset': offset, 'attrs': {}, 'tag': tag, 'members': []}
                if current_cu:
                    current_cu['types'].append(ctype)
                die['_target'] = ctype
            elif tag == 'DW_TAG_member':
                member = {'offset': offset, 'attrs': {}}
                if current_cu and current_cu['types']:
                    parent = current_cu['types'][-1]
                    if 'members' in parent:
                        parent['members'].append(member)
                die['_target'] = member
            continue

        # Null DIE (end of children)
        m = re.match(r'\s*<(\d+)><[0-9a-f]+>: Abbrev Number: 0\s*$', line)
        if m:
            depth = int(m.group(1))
            if depth == 1:
                current_subprog = None
            continue

        # Attribute line
        m = re.match(r'\s+<[0-9a-f]+>\s+(DW_AT_\w+)\s*:\s*(.*)', line)
        if m:
            attr_name = m.group(1)
            attr_val = m.group(2).strip()

            # Find the most recent DIE to attach to
            if current_die:
                max_depth = max(current_die.keys())
                die = current_die[max_depth]
                tag = die.get('tag', '')

                if tag == 'DW_TAG_compile_unit' and current_cu:
                    current_cu['attrs'][attr_name] = attr_val
                elif tag == 'DW_TAG_subprogram' and current_subprog:
                    current_subprog['attrs'][attr_name] = attr_val
                elif '_target' in die:
                    die['_target']['attrs'][attr_name] = attr_val

    if current_cu:
        cus.append(current_cu)
    return cus


def parse_debug_line(readelf, elf_path):
    """Parse readelf --debug-dump=line into per-CU file tables."""
    out = _run([readelf, '--debug-dump=line', str(elf_path)])
    cus = []
    current = None

    for line in out.splitlines():
        if line.strip().startswith('Offset:'):
            if current:
                cus.append(current)
            current = {'files': [], 'entries': []}
            continue

        if current is None:
            continue

        # File table entry
        m = re.match(r'\s+(\d+)\s+\d+\s+\d+\s+\d+\s+(.+)', line)
        if m and current is not None:
            current['files'].append(m.group(2).strip())
            continue

        # Line number statement with address and line
        m = re.match(r'.*advance Address.*to (0x[0-9a-f]+) and Line.*to (\d+)', line)
        if m:
            current['entries'].append({
                'address': int(m.group(1), 16),
                'line': int(m.group(2)),
            })
            continue

        # Copy / set Address statements
        m = re.match(r'.*set Address to (0x[0-9a-f]+)', line)
        if m:
            current.setdefault('_pending_addr', int(m.group(1), 16))
            continue

        if 'Copy' in line and '_pending_addr' in (current or {}):
            # Next advance line will pick it up
            pass

    if current:
        cus.append(current)
    return cus


def parse_debug_frames(readelf, elf_path):
    """Parse readelf --debug-dump=frames into FDE list."""
    out = _run([readelf, '--debug-dump=frames', str(elf_path)])
    fdes = []
    for m in re.finditer(r'FDE.*pc=([0-9a-f]+)\.\.([0-9a-f]+)', out):
        fdes.append({
            'low_pc': int(m.group(1), 16),
            'high_pc': int(m.group(2), 16),
        })
    return fdes


# Attribute value helpers

def _extract_name(attrs):
    """Extract name from DW_AT_name attribute (handles indirect strings).

    readelf format: '(indirect string, offset: 0x2b): rdb/CLK.alst'
    We want the part after the last colon.
    """
    raw = attrs.get('DW_AT_name', '')
    # Find last ': ' — the actual value follows it
    idx = raw.rfind(': ')
    if idx >= 0:
        return raw[idx + 2:].strip()
    return raw.strip()


def _extract_int(val):
    """Extract integer from attribute value like '0xc000390' or '0x88' or '12'."""
    val = val.strip()
    m = re.match(r'(0x[0-9a-f]+|\d+)', val)
    if m:
        return int(m.group(1), 0)
    return None


def _extract_location(attrs):
    """Extract location expression description from DW_AT_location."""
    raw = attrs.get('DW_AT_location', '')
    m = re.search(r'\((.+)\)', raw)
    if m:
        return m.group(1)
    return raw


# Check result tracking

class Results:
    def __init__(self, verbose=False):
        self.passed = 0
        self.failed = 0
        self.skipped = 0
        self.verbose = verbose
        self.failures = []

    def ok(self, category, msg):
        self.passed += 1
        if self.verbose:
            print(f"  PASS  {category}: {msg}")

    def fail(self, category, msg):
        self.failed += 1
        self.failures.append((category, msg))
        print(f"  FAIL  {category}: {msg}")

    def skip(self, category, msg):
        self.skipped += 1
        if self.verbose:
            print(f"  SKIP  {category}: {msg}")

    def summary(self):
        total = self.passed + self.failed + self.skipped
        print(f"\n--- Results ---")
        print(f"Total:   {total}")
        print(f"PASS:    {self.passed}")
        print(f"FAIL:    {self.failed}")
        print(f"SKIP:    {self.skipped}")
        if self.failures:
            print(f"\nFailures:")
            for cat, msg in self.failures:
                print(f"  {cat}: {msg}")
        return self.failed == 0


# Check implementations

def check_sections(sections, has_debug, has_bss, has_image_def, has_arm_attr,
                    has_global_vars, r):
    """Check that all expected sections are present."""
    cat = 'sections'

    always = ['.text', '.symtab', '.strtab', '.shstrtab']
    for name in always:
        if name in sections:
            r.ok(cat, f'{name} present')
        else:
            r.fail(cat, f'{name} missing')

    if has_bss:
        if '.bss' in sections:
            r.ok(cat, '.bss present')
        else:
            r.fail(cat, '.bss missing')

    if has_image_def:
        if '.image_def' in sections:
            r.ok(cat, '.image_def present')
        else:
            r.fail(cat, '.image_def missing')

    if has_debug:
        debug_sects = ['.debug_line', '.debug_info', '.debug_abbrev',
                       '.debug_aranges', '.debug_str', '.debug_frame']
        for name in debug_sects:
            if name in sections:
                r.ok(cat, f'{name} present')
            else:
                r.fail(cat, f'{name} missing')

        # .debug_pubnames only expected when global variables exist
        if '.debug_pubnames' in sections:
            r.ok(cat, '.debug_pubnames present')
        elif has_global_vars:
            r.fail(cat, '.debug_pubnames missing')
        else:
            r.skip(cat, '.debug_pubnames absent (no global variables)')

        if has_arm_attr:
            if '.ARM.attributes' in sections:
                r.ok(cat, '.ARM.attributes present')
            else:
                r.fail(cat, '.ARM.attributes missing')


def check_symbols(sym_list, debug_data, r, symbol_prefix=''):
    """Check symbol table against elfdata ground truth."""
    cat = 'symbols'
    pfx = f'{symbol_prefix}_' if symbol_prefix else ''
    sym_by_name = {}
    for s in sym_list:
        sym_by_name[s['name']] = s

    # Check procedure symbols
    for proc in debug_data.procedures:
        sym_name = f'{pfx}{proc.name.replace(".", "_")}'
        if sym_name in sym_by_name:
            s = sym_by_name[sym_name]
            # Mask off Thumb bit (bit 0) for address comparison
            sym_addr = s['address'] & ~1
            if sym_addr == proc.address:
                r.ok(cat, f'{sym_name} address 0x{proc.address:08x}')
            else:
                r.fail(cat, f'{sym_name} address: expected 0x{proc.address:08x}, '
                       f'got 0x{sym_addr:08x}')
            if proc.size > 0:
                if s['size'] == proc.size:
                    r.ok(cat, f'{sym_name} size {proc.size}')
                else:
                    r.fail(cat, f'{sym_name} size: expected {proc.size}, got {s["size"]}')
        else:
            r.fail(cat, f'{sym_name} missing from symbol table')

    # Check $t mapping symbols
    t_syms = {s['address'] for s in sym_list if s['name'] == '$t'}
    for proc in debug_data.procedures:
        if proc.address in t_syms:
            r.ok(cat, f'$t at 0x{proc.address:08x}')
        else:
            r.fail(cat, f'$t missing at 0x{proc.address:08x} ({proc.name})')

    # Check global variable symbols
    for gs in debug_data.global_symbols:
        sym_name = f'{pfx}{gs.module_name}_{gs.name}'
        if sym_name in sym_by_name:
            s = sym_by_name[sym_name]
            if s['address'] == gs.address:
                r.ok(cat, f'{sym_name} address 0x{gs.address:08x}')
            else:
                r.fail(cat, f'{sym_name} address: expected 0x{gs.address:08x}, '
                       f'got 0x{s["address"]:08x}')
        else:
            r.fail(cat, f'{sym_name} missing from symbol table')


def check_compilation_units(dwarf_cus, debug_data, r):
    """Check CU DIEs against elfdata module list."""
    cat = 'CUs'
    cu_by_name = {}
    for cu in dwarf_cus:
        name = _extract_name(cu['attrs'])
        cu_by_name[name] = cu

    for mod in debug_data.modules:
        # Expected filename: rdb/<module>.alst
        expected_name = f'rdb/{mod.name}.alst'
        if mod.name == '_startup':
            expected_name = 'rdb/_startup.alst'

        if expected_name in cu_by_name:
            cu = cu_by_name[expected_name]
            r.ok(cat, f'{mod.name} CU present')

            # Check low_pc
            low_pc_val = _extract_int(cu['attrs'].get('DW_AT_low_pc', ''))
            if low_pc_val is not None and low_pc_val == mod.low_pc:
                r.ok(cat, f'{mod.name} low_pc 0x{mod.low_pc:08x}')
            elif low_pc_val is not None:
                r.fail(cat, f'{mod.name} low_pc: expected 0x{mod.low_pc:08x}, '
                       f'got 0x{low_pc_val:08x}')

            # Check high_pc (relative size in DWARF v4)
            high_pc_val = _extract_int(cu['attrs'].get('DW_AT_high_pc', ''))
            expected_size = mod.high_pc - mod.low_pc
            if high_pc_val is not None and high_pc_val == expected_size:
                r.ok(cat, f'{mod.name} high_pc (size) {expected_size}')
            elif high_pc_val is not None:
                r.fail(cat, f'{mod.name} high_pc (size): expected {expected_size}, '
                       f'got {high_pc_val}')

            # Check producer
            producer = _extract_name({'DW_AT_name': cu['attrs'].get('DW_AT_producer', '')})
            if 'makedebug' in producer.lower() or 'oberon' in producer.lower():
                r.ok(cat, f'{mod.name} producer')
            else:
                r.fail(cat, f'{mod.name} producer: unexpected "{producer}"')
        else:
            r.fail(cat, f'{mod.name} CU missing (expected {expected_name})')


def check_procedures(dwarf_cus, debug_data, r, symbol_prefix=''):
    """Check subprogram DIEs against elfdata procedures."""
    cat = 'procs'
    pfx = f'{symbol_prefix}_' if symbol_prefix else ''

    # Build ProcSymbol lookup keyed by prefixed name (matching DWARF DW_AT_name)
    proc_by_name = {}
    for ps in debug_data.procedures:
        proc_by_name[f'{pfx}{ps.name}'] = ps

    # Build ProcSource lookup keyed by prefixed name
    procsrc_by_name = {}
    for mod in debug_data.modules:
        if mod.module_src is None:
            continue
        for proc_src in mod.module_src.procedures:
            qual_name = f'{pfx}{mod.name}.{proc_src.name}'
            procsrc_by_name[qual_name] = proc_src

    # Walk DWARF CUs and match subprograms
    found = set()
    for cu in dwarf_cus:
        for sp in cu['subprograms']:
            name = _extract_name(sp['attrs'])
            if not name:
                continue
            found.add(name)

            # Check low_pc
            low_pc_val = _extract_int(sp['attrs'].get('DW_AT_low_pc', ''))
            if name in proc_by_name:
                ps = proc_by_name[name]
                if low_pc_val is not None and low_pc_val == ps.address:
                    r.ok(cat, f'{name} low_pc 0x{ps.address:08x}')
                elif low_pc_val is not None:
                    r.fail(cat, f'{name} low_pc: expected 0x{ps.address:08x}, '
                           f'got 0x{low_pc_val:08x}')

                # Check high_pc (size)
                high_pc_val = _extract_int(sp['attrs'].get('DW_AT_high_pc', ''))
                if high_pc_val is not None and high_pc_val == ps.size:
                    r.ok(cat, f'{name} size {ps.size}')
                elif high_pc_val is not None:
                    r.fail(cat, f'{name} size: expected {ps.size}, got {high_pc_val}')

            # Check frame_base present
            if 'DW_AT_frame_base' in sp['attrs']:
                r.ok(cat, f'{name} frame_base present')
            else:
                r.fail(cat, f'{name} frame_base missing')

            # Check parameter count against ProcSource
            if name in procsrc_by_name:
                exp_src = procsrc_by_name[name]
                exp_param_count = sum(len(p.names) for p in exp_src.params)
                got_param_count = len(sp['params'])
                if got_param_count == exp_param_count:
                    r.ok(cat, f'{name} param count {exp_param_count}')
                else:
                    r.fail(cat, f'{name} param count: expected {exp_param_count}, '
                           f'got {got_param_count}')

                # Check local count
                exp_local_count = sum(len(v.names) for v in exp_src.local_vars)
                got_local_count = len(sp['locals'])
                if got_local_count == exp_local_count:
                    r.ok(cat, f'{name} local count {exp_local_count}')
                else:
                    r.fail(cat, f'{name} local count: expected {exp_local_count}, '
                           f'got {got_local_count}')

    # Check that every ProcSymbol has a matching DWARF subprogram
    for ps in debug_data.procedures:
        expected = f'{pfx}{ps.name}'
        if expected not in found:
            r.fail(cat, f'{expected} subprogram DIE missing')


def check_variables(dwarf_cus, r):
    """Check that parameter and local variable DIEs have required attributes."""
    cat = 'vars'

    for cu in dwarf_cus:
        for sp in cu['subprograms']:
            sp_name = _extract_name(sp['attrs'])

            for param in sp['params']:
                p_name = _extract_name(param['attrs'])
                label = f'{sp_name}.{p_name}' if p_name else f'{sp_name}.(param)'

                if 'DW_AT_name' in param['attrs']:
                    r.ok(cat, f'{label} has name')
                else:
                    r.fail(cat, f'{label} missing name')

                if 'DW_AT_type' in param['attrs']:
                    r.ok(cat, f'{label} has type')
                else:
                    r.fail(cat, f'{label} missing type')

                if 'DW_AT_location' in param['attrs']:
                    r.ok(cat, f'{label} has location')
                else:
                    r.fail(cat, f'{label} missing location')

            for local in sp['locals']:
                l_name = _extract_name(local['attrs'])
                label = f'{sp_name}.{l_name}' if l_name else f'{sp_name}.(local)'

                if 'DW_AT_name' in local['attrs']:
                    r.ok(cat, f'{label} has name')
                else:
                    r.fail(cat, f'{label} missing name')

                if 'DW_AT_type' in local['attrs']:
                    r.ok(cat, f'{label} has type')
                else:
                    r.fail(cat, f'{label} missing type')

                if 'DW_AT_location' in local['attrs']:
                    r.ok(cat, f'{label} has location')
                else:
                    r.fail(cat, f'{label} missing location')


def check_types(dwarf_cus, r):
    """Spot-check base types and composite type structure."""
    cat = 'types'

    expected_base = {
        'INTEGER': (4, 'signed'),
        'SET': (4, 'unsigned'),
        'REAL': (4, 'float'),
        'CHAR': (1, 'unsigned char'),
        'BOOLEAN': (1, 'unsigned'),
        'BYTE': (1, 'unsigned'),
    }

    # Collect all base types across all CUs (each CU may define its own)
    base_found = {}
    for cu in dwarf_cus:
        for t in cu['types']:
            if t.get('tag') == 'DW_TAG_base_type':
                name = _extract_name(t['attrs'])
                if name in expected_base:
                    base_found.setdefault(name, []).append(t)

            # Check structure_type has byte_size
            if t.get('tag') == 'DW_TAG_structure_type':
                name = _extract_name(t['attrs'])
                if 'DW_AT_byte_size' in t['attrs']:
                    r.ok(cat, f'structure {name} has byte_size')
                else:
                    r.fail(cat, f'structure {name} missing byte_size')

            # Check pointer_type has byte_size (only for explicit pointers,
            # not implicit VAR-param pointers which omit it by design)
            if t.get('tag') == 'DW_TAG_pointer_type':
                if 'DW_AT_byte_size' in t['attrs']:
                    r.ok(cat, f'pointer_type has byte_size')
                else:
                    r.skip(cat, f'pointer_type without byte_size (implicit)')

    # Verify base types (check first occurrence of each)
    for name, (exp_size, exp_enc) in expected_base.items():
        if name in base_found:
            t = base_found[name][0]
            # Check size
            size_raw = t['attrs'].get('DW_AT_byte_size', '')
            size_val = _extract_int(size_raw)
            if size_val == exp_size:
                r.ok(cat, f'{name} byte_size {exp_size}')
            else:
                r.fail(cat, f'{name} byte_size: expected {exp_size}, got {size_val}')

            # Check encoding
            enc_raw = t['attrs'].get('DW_AT_encoding', '')
            if exp_enc in enc_raw:
                r.ok(cat, f'{name} encoding {exp_enc}')
            else:
                r.fail(cat, f'{name} encoding: expected {exp_enc}, got "{enc_raw}"')
        # Don't fail if a base type is absent — not all CUs use all types


def check_line_numbers(line_cus, debug_data, r):
    """Check line number tables have valid file refs and address ranges."""
    cat = 'lines'

    # Build module address ranges
    mod_ranges = {}
    for mod in debug_data.modules:
        mod_ranges[mod.name] = (mod.low_pc, mod.high_pc)

    for i, lcu in enumerate(line_cus):
        if not lcu['files']:
            r.skip(cat, f'CU {i}: no file table')
            continue

        # Check file references are .alst files
        for fname in lcu['files']:
            if fname.endswith('.alst'):
                r.ok(cat, f'CU {i}: file {fname}')
            else:
                r.fail(cat, f'CU {i}: unexpected file extension: {fname}')

        # Check entries have valid addresses (non-zero, non-decreasing)
        if lcu['entries']:
            prev_addr = 0
            monotonic = True
            for entry in lcu['entries']:
                if entry['address'] < prev_addr:
                    monotonic = False
                    break
                prev_addr = entry['address']
            if monotonic:
                r.ok(cat, f'CU {i}: addresses monotonic')
            else:
                r.fail(cat, f'CU {i}: addresses not monotonic')
        else:
            r.skip(cat, f'CU {i}: no line entries')


def check_frames(fdes, debug_data, r):
    """Check FDE coverage of procedures."""
    cat = 'frames'

    # Build FDE set indexed by start address
    fde_starts = {f['low_pc'] for f in fdes}

    for proc in debug_data.procedures:
        if proc.address in fde_starts:
            r.ok(cat, f'{proc.name} has FDE')
        else:
            r.fail(cat, f'{proc.name} missing FDE at 0x{proc.address:08x}')


# Main

def main():
    parser = argparse.ArgumentParser(
        description='Offline ELF/DWARF validation against .alst ground truth')
    parser.add_argument('elf', help='ELF file to check')
    parser.add_argument('--rdb-dir', default='rdb',
                        help='Directory containing .alst files (default: rdb)')
    parser.add_argument('--map', dest='map_file', default=None,
                        help='Path to .map file for global variable addresses')
    parser.add_argument('--sym-prefix', '--symbol-prefix',
                        dest='symbol_prefix', default='',
                        help='Expected symbol prefix (e.g. S for Secure, NS for Non-Secure)')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Show all checks including PASS')
    parser.add_argument('--readelf', default=None,
                        help='Path to readelf binary')
    args = parser.parse_args()

    # Resolve readelf: --readelf > RTK_READELF > PATH
    readelf = args.readelf
    if readelf is None:
        readelf = os.environ.get('RTK_READELF')
    if readelf is None:
        readelf = 'arm-none-eabi-readelf'

    elf_path = Path(args.elf)
    if not elf_path.exists():
        print(f"ERROR: ELF file not found: {elf_path}")
        sys.exit(1)

    rdb_dir = Path(args.rdb_dir)
    if not rdb_dir.exists():
        print(f"ERROR: rdb directory not found: {rdb_dir}")
        sys.exit(1)

    # Auto-detect map file
    map_path = None
    if args.map_file:
        map_path = Path(args.map_file)
    else:
        candidate = elf_path.with_suffix('.map')
        if candidate.exists():
            map_path = candidate

    # Load ground truth via elfdata
    print(f"Loading ground truth from {rdb_dir}/ ...")
    debug_data = elfdata.extract(
        str(rdb_dir),
        src_subdir=rdb_dir.name,
        map_file=str(map_path) if map_path else None,
    )
    print(f"  {len(debug_data.modules)} modules, "
          f"{len(debug_data.procedures)} procedures, "
          f"{len(debug_data.global_symbols)} global variables")
    if args.symbol_prefix:
        print(f"  symbol prefix: {args.symbol_prefix}_")

    # Parse ELF
    print(f"Parsing {elf_path} ...")
    sections = parse_section_headers(readelf, elf_path)
    sym_list = parse_symbol_table(readelf, elf_path)
    dwarf_cus = parse_debug_info(readelf, elf_path)
    line_cus = parse_debug_line(readelf, elf_path)
    fdes = parse_debug_frames(readelf, elf_path)
    print(f"  {len(sections)} sections, {len(sym_list)} symbols, "
          f"{len(dwarf_cus)} CUs, {len(fdes)} FDEs")

    # Detect features
    has_debug = '.debug_info' in sections
    has_bss = '.bss' in sections
    has_image_def = '.image_def' in sections
    has_arm_attr = any(
        (rdb_dir / f).exists()
        for f in ['arm-attr.cfg']
    )

    # Run checks
    r = Results(verbose=args.verbose)

    has_global_vars = len(debug_data.global_symbols) > 0

    print("\nChecking sections ...")
    check_sections(sections, has_debug, has_bss, has_image_def, has_arm_attr,
                   has_global_vars, r)

    print("Checking symbols ...")
    check_symbols(sym_list, debug_data, r, symbol_prefix=args.symbol_prefix)

    if has_debug:
        print("Checking compilation units ...")
        check_compilation_units(dwarf_cus, debug_data, r)

        print("Checking procedures ...")
        check_procedures(dwarf_cus, debug_data, r, symbol_prefix=args.symbol_prefix)

        print("Checking variables ...")
        check_variables(dwarf_cus, r)

        print("Checking types ...")
        check_types(dwarf_cus, r)

        print("Checking line numbers ...")
        check_line_numbers(line_cus, debug_data, r)

        print("Checking frames ...")
        check_frames(fdes, debug_data, r)

    # Summary
    ok = r.summary()
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
