#!/usr/bin/env python3
"""
gen-secure -- Generate NSC veneer binary and NS interface modules.
--
Reads the Astrobe linker .map file of a Secure program, parses the
listing files of the specified modules, and generates:
  - One combined NSC veneer binary (NSC.bin) with SG gateway sequences
  - One NSC pseudo-listing (NSC.alst) for debugging veneer code
  - NS interface modules (NS_<Module>.mod) with stub procedures
  - Type-only and CONST-only dependency modules as needed

Implements the ARM TrustZone calling convention for Cortex-M processors
with the Security Extension (ARMv8-M).

Configuration can be given via command line arguments, a configuration file
(gen-secure.cfg), or both. CLI arguments override cfg file values. The
default cfg file (gen-secure.cfg in cwd) is loaded automatically if present.
--
Usage:
    python gen-secure.py <s_map_file> [<module> ...]
                         [--nsc-addr ADDR] [--cfg-file PATH]
                         [--const-leaf NAME] [--nsc-dir DIR]
                         [--ns-dir DIR] [-v]

Example:
    python gen-secure.py s/S.map
    python gen-secure.py s/S.map S0
    python gen-secure.py s/S.map --nsc-addr C0FE000 S0 --const-leaf MCU2 --ns-dir ns
--
Copyright (c) 2025-2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import os
import re
import struct
import argparse
import configparser
from pathlib import Path

_pylib_dir = str(Path(__file__).resolve().parent / 'pylib')
if _pylib_dir not in sys.path:
    sys.path.insert(0, _pylib_dir)
import elfdata

PROG_NAME = 'gen-secure'

# --- Map file parsing ---

_MAP_DATA_RE = re.compile(
    r'^(\w+)\s*([0-9A-F]+)H\s+(\d+)\s+([0-9A-F]+)H\s+(\d+)\s+([0-9A-F]+)H\s+([0-9A-F]+)H'
)
_MAP_FILE_RE = re.compile(r'^(\w+)\s*([C-Z][:].+|/.+)')


def parse_map(map_path):
    """Parse .map file. Returns modules dict and file paths."""
    text = map_path.read_text(encoding='utf-8', errors='replace')
    modules = {}
    in_files = False

    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith('Files:'):
            in_files = True
            continue
        if in_files:
            m = _MAP_FILE_RE.match(stripped)
            if m:
                mod_name = m.group(1)
                if mod_name in modules:
                    arm_path = Path(m.group(2).strip())
                    modules[mod_name]['lst_path'] = arm_path.with_suffix('.lst')
            elif stripped == '' or stripped.startswith('Max '):
                in_files = False
            continue
        m = _MAP_DATA_RE.match(stripped)
        if m:
            mod_name = m.group(1)
            modules[mod_name] = {
                'code_addr': int(m.group(4), 16),
                'code_size': int(m.group(5)),
                'entry_addr': int(m.group(6), 16),
            }
    return modules


# --- Helpers ---

def error(msg):
    print(f'{PROG_NAME}: {msg}', file=sys.stderr)
    sys.exit(1)


def twoc4(num, bits=32):
    mask = (1 << bits) - 1
    return '{:08X}'.format(num & mask)


def parse_hex_addr(s):
    """Parse hex address, accepting optional trailing H."""
    s = s.strip()
    if s.upper().endswith('H'):
        s = s[:-1]
    if s.startswith('0') and len(s) > 1 and s[1:].isdigit() is False:
        pass
    return int(s, 16)


DEFAULT_CFG_FILE = 'gen-secure.cfg'
CFG_SECTION = 'gen-secure'


def load_cfg(cfg_path):
    """Load gen-secure.cfg. Returns dict of values from [gen-secure] section."""
    cp = configparser.ConfigParser()
    cp.optionxform = str
    cp.read(str(cfg_path), encoding='utf-8')
    cfg = {}
    if not cp.has_section(CFG_SECTION):
        error(f'no [{CFG_SECTION}] section in {cfg_path}')
    for key in ('nsc-addr', 'ns-dir', 'nsc-dir', 'const-leaf'):
        if cp.has_option(CFG_SECTION, key):
            cfg[key] = cp.get(CFG_SECTION, key).strip()
    if cp.has_option(CFG_SECTION, 'modules'):
        raw = cp.get(CFG_SECTION, 'modules')
        cfg['modules'] = raw.split()
    return cfg


# --- Comment stripping ---

class StripComments:
    """Strip all Oberon style comments, possibly nested, from text."""
    def __init__(self, s):
        self._string = s

    def strip(self):
        it = iter(self)
        lvl = 0
        source = ''
        add_space = False
        for c in it:
            if c == '(*':
                lvl += 1
                add_space = False
            elif c == '*)':
                lvl -= 1
                add_space = True
            else:
                if lvl == 0:
                    if add_space:
                        source += ' '
                        add_space = False
                    source += c[0]
        result = ''
        for line in source.splitlines(True):
            if not line.isspace():
                result += line
        return result

    def __iter__(self):
        self._index = 0
        return self

    def __next__(self):
        if self._index < len(self._string):
            token = self._string[self._index : self._index + 2]
            if token == '(*' or token == '*)':
                self._index += 2
            else:
                self._index += 1
            return token
        raise StopIteration


# --- LST text extraction ---

_SECTION_KW = {'CONST', 'TYPE', 'VAR', 'PROCEDURE', 'BEGIN', 'END'}


def read_source_lines(lst_path):
    """Read .lst file, strip comments, skip assembly lines. Return source lines."""
    text = lst_path.read_text(encoding='utf-8', errors='replace')
    text = StripComments(text).strip()
    lines = []
    for line in text.splitlines():
        if not line.startswith('.'):
            lines.append(line)
    return lines


def find_section(lines, section_kw):
    """Find the start index of a section keyword. Returns index or -1."""
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped == section_kw or stripped.startswith(section_kw + ' '):
            # make sure it's the keyword at the start, not inside something
            tokens = stripped.split()
            if tokens and tokens[0] == section_kw:
                return i
    return -1


def section_end(lines, start):
    """Find where a section ends (next section keyword or module end)."""
    for i in range(start + 1, len(lines)):
        stripped = lines[i].strip()
        if stripped == '':
            continue
        tokens = stripped.split()
        if tokens and tokens[0] in _SECTION_KW:
            return i
    return len(lines)


def extract_const_lines(lst_path):
    """Extract raw CONST section lines from .lst file."""
    lines = read_source_lines(lst_path)
    start = find_section(lines, 'CONST')
    if start < 0:
        return []
    end = section_end(lines, start)
    result = []
    for line in lines[start + 1 : end]:
        stripped = line.strip()
        if stripped:
            result.append(stripped)
    return result


def extract_type_lines(lst_path):
    """Extract raw TYPE section lines from .lst file."""
    lines = read_source_lines(lst_path)
    start = find_section(lines, 'TYPE')
    if start < 0:
        return []
    end = section_end(lines, start)
    result = []
    for line in lines[start + 1 : end]:
        stripped = line.strip()
        if stripped:
            result.append(stripped)
    return result


# --- Alias rewriting ---

_QUALIFIED_RE = re.compile(r'\b([A-Z]\w*)\.([A-Z]\w*)')


def rewrite_aliases(text, imports):
    """Rewrite qualified references: Alias.Name -> NS_ActualModule.Name."""
    def replacer(m):
        alias = m.group(1)
        name = m.group(2)
        if alias in imports:
            return f'NS_{imports[alias]}.{name}'
        return m.group(0)
    return _QUALIFIED_RE.sub(replacer, text)


# --- Type filtering ---

def filter_exported_types(type_lines):
    """Filter type lines to include only exported types (with all fields)."""
    result = []
    in_record = False
    include = False

    for line in type_lines:
        if in_record:
            result.append(line)
            if line.strip().startswith('END;') or line.strip() == 'END;':
                in_record = False
                include = False
            continue

        # Check for RECORD start
        rec_match = re.match(r'\s*(\w+)\s*(\*?)\s*=\s*RECORD', line)
        if rec_match:
            if rec_match.group(2) == '*':
                include = True
                in_record = True
                result.append(line)
            continue

        # Check for POINTER TO
        ptr_match = re.match(r'\s*(\w+)\s*(\*?)\s*=\s*POINTER\s+TO\s+', line)
        if ptr_match:
            if ptr_match.group(2) == '*':
                result.append(line)
            continue

        # Check for simple type alias
        simple_match = re.match(r'\s*(\w+)\s*(\*?)\s*=\s*', line)
        if simple_match:
            if simple_match.group(2) == '*':
                result.append(line)
            continue

    return result


# --- Procedure extraction from LST ---

_PROC_SIG_RE = re.compile(r'^\s*(PROCEDURE\s*(\*?)\s+(\w+)\s*(\*?)\s*(\(.*\))?\s*;)')
_ASM_RE = re.compile(r'^\.\s+(\d+)\s+([0-9A-F]+)H\s+([0-9A-F]+)H\s+([\w\.]+)\s*(.*)')


def extract_exported_procs(lst_path):
    """Extract exported procedure info from .lst file.
    Returns list of {sig, name, leaf, push_count, rel_addr} dicts.
    """
    raw_text = lst_path.read_text(encoding='utf-8', errors='replace')
    raw_lines = raw_text.splitlines()

    procs = []
    i = 0
    while i < len(raw_lines):
        line = raw_lines[i]
        m = _PROC_SIG_RE.match(line)
        if m:
            sig_text = m.group(1)
            is_leaf = m.group(2) == '*'
            proc_name = m.group(3)
            is_exported = m.group(4) == '*'
            if is_exported:
                # scan forward for push instruction
                push_count = 0
                rel_addr = 0
                for j in range(i + 1, min(i + 30, len(raw_lines))):
                    am = _ASM_RE.match(raw_lines[j])
                    if am:
                        mnemonic = am.group(4)
                        if mnemonic in ('push', 'push.w'):
                            rel_addr = int(am.group(1))
                            regs_str = am.group(5)
                            regs = [r.strip() for r in regs_str.strip('{}').split(',')]
                            push_count = len(regs)
                            break
                procs.append({
                    'sig': sig_text,
                    'name': proc_name,
                    'leaf': is_leaf,
                    'push_count': push_count,
                    'rel_addr': rel_addr,
                })
        i += 1
    return procs


# --- Dependency resolution ---

def parse_module_source(lst_path):
    """Parse a .lst file with elfdata. Returns ModuleSource or None."""
    try:
        tokens = elfdata.tokenize_alst(lst_path)
        parser = elfdata.OberonParser(tokens)
        module_src = parser.parse_module()
        if module_src is not None:
            module_src.consts = dict(parser.const_defs)
        return module_src
    except Exception as e:
        return None


def find_type_deps(type_lines, imports):
    """Find module dependencies from type definitions. Returns set of actual module names."""
    deps = set()
    for line in type_lines:
        for m in _QUALIFIED_RE.finditer(line):
            alias = m.group(1)
            if alias in imports:
                deps.add(imports[alias])
    return deps


def find_const_deps(const_lines, imports):
    """Find module dependencies from CONST definitions. Returns set of actual module names."""
    deps = set()
    for line in const_lines:
        for m in _QUALIFIED_RE.finditer(line):
            alias = m.group(1)
            if alias in imports:
                deps.add(imports[alias])
    return deps


def resolve_dependencies(exposed_names, map_modules, const_leaf, verbose):
    """Walk dependencies from exposed modules.
    Returns dict: module_name -> {classification, lst_path, imports,
                                   const_lines, type_lines}
    """
    result = {}
    work = list(exposed_names)

    # initialise exposed modules
    for name in exposed_names:
        if name not in map_modules:
            error(f'module {name} not found in map file')
        info = map_modules[name]
        if 'lst_path' not in info:
            error(f'no file path for module {name} in map file')
        lst_path = Path(info['lst_path'])
        if not lst_path.is_file():
            error(f'listing file not found: {lst_path}')
        module_src = parse_module_source(lst_path)
        if module_src is None:
            error(f'cannot parse listing file: {lst_path}')
        const_lines = extract_const_lines(lst_path)
        type_lines = extract_type_lines(lst_path)
        result[name] = {
            'classification': 'exposed',
            'lst_path': lst_path,
            'imports': module_src.imports,
            'const_lines': const_lines,
            'type_lines': filter_exported_types(type_lines),
            'module_src': module_src,
        }

    # walk dependencies
    visited = set(exposed_names)
    while work:
        current = work.pop(0)
        info = result[current]
        imports = info['imports']

        # find type dependencies
        type_deps = find_type_deps(info['type_lines'], imports)
        # find const dependencies
        const_deps = find_const_deps(info['const_lines'], imports)

        all_deps = type_deps | const_deps

        for dep_name in all_deps:
            if dep_name in visited:
                # upgrade const_only to type_only if needed
                if dep_name in result and result[dep_name]['classification'] == 'const_only':
                    if dep_name in type_deps:
                        result[dep_name]['classification'] = 'type_only'
                continue
            visited.add(dep_name)

            if dep_name not in map_modules:
                if verbose:
                    print(f'{PROG_NAME}: skipping dependency {dep_name} (not in map)')
                continue
            dep_map = map_modules[dep_name]
            if 'lst_path' not in dep_map:
                if verbose:
                    print(f'{PROG_NAME}: skipping dependency {dep_name} (no file path)')
                continue
            dep_lst = Path(dep_map['lst_path'])
            if not dep_lst.is_file():
                if verbose:
                    print(f'{PROG_NAME}: skipping dependency {dep_name} (lst not found)')
                continue

            dep_src = parse_module_source(dep_lst)
            dep_imports = dep_src.imports if dep_src else {}
            dep_const_lines = extract_const_lines(dep_lst)
            dep_type_lines = extract_type_lines(dep_lst)

            classification = 'type_only' if dep_name in type_deps else 'const_only'

            result[dep_name] = {
                'classification': classification,
                'lst_path': dep_lst,
                'imports': dep_imports,
                'const_lines': dep_const_lines,
                'type_lines': filter_exported_types(dep_type_lines),
                'module_src': dep_src,
            }

            # recurse unless this is the const leaf
            if dep_name != const_leaf:
                work.append(dep_name)

    return result


# --- NSC binary generation ---

SG_H = 0xE97F
SG_L = 0xE97F
LDR_R11_H = 0xF8DF
LDR_R11_L = 0xB004
BX_R11 = 0x4758
NOP = 0x46C0


def build_nsc_bin(gateways):
    """Build NSC binary from list of target addresses.
    Each gateway: 16 bytes (SG + ldr r11 + bx r11/nop + target addr).
    """
    buf = bytearray()
    for target_addr in gateways:
        buf.extend(struct.pack('<H', SG_H))
        buf.extend(struct.pack('<H', SG_L))
        buf.extend(struct.pack('<H', LDR_R11_H))
        buf.extend(struct.pack('<H', LDR_R11_L))
        buf.extend(struct.pack('<H', BX_R11))
        buf.extend(struct.pack('<H', NOP))
        buf.extend(struct.pack('<I', target_addr + 1))  # Thumb bit
    # pad to 32-byte boundary
    remainder = len(buf) % 32
    if remainder:
        buf.extend(b'\x00' * (32 - remainder))
    return buf


# --- NSC.alst generation ---

SG_INSTR = (SG_H << 16) | SG_L
LDR_R11_INSTR = (LDR_R11_H << 16) | LDR_R11_L


def generate_nsc_alst(nsc_addr, gateways, proc_names):
    """Generate NSC.alst listing file for debugging.
    gateways: list of target addresses (without Thumb bit).
    proc_names: list of procedure names, parallel to gateways.
    """
    lines = []
    lines.append(f'. <tool: {PROG_NAME}>')
    lines.append('')
    lines.append('MODULE NSC;')
    lines.append('')

    for i, (target_addr, proc_name) in enumerate(zip(gateways, proc_names)):
        base = nsc_addr + i * 16
        target_thumb = target_addr + 1
        lines.append(f'  PROCEDURE {proc_name};')
        lines.append('  BEGIN')
        lines.append(f'.{i * 16:>6}  {base:09X}  {SG_INSTR:09X}  sg')
        lines.append(f'.{i * 16 + 4:>6}  {base + 4:09X}  {LDR_R11_INSTR:09X}  ldr.w     r11,[pc,#4]')
        lines.append(f'.{i * 16 + 8:>6}  {base + 8:09X}      {BX_R11:05X}  bx        r11')
        lines.append(f'.{i * 16 + 10:>6}  {base + 10:09X}      {NOP:05X}  nop')
        lines.append(f'.{i * 16 + 12:>6}  {base + 12:09X}  {target_thumb:09X}  .word     0x{target_thumb:08X}')
        lines.append(f'  END {proc_name};')
        lines.append('')

    lines.append('END NSC.')
    lines.append('')
    return '\n'.join(lines)


# --- NS module generation ---

def collect_ns_imports(dep_info, all_deps, is_exposed):
    """Collect the IMPORT list for an NS_ module."""
    imports_needed = set()
    module_imports = dep_info['imports']

    # scan type and const lines for qualified references to deps
    for line in dep_info['type_lines'] + dep_info['const_lines']:
        for m in _QUALIFIED_RE.finditer(line):
            alias = m.group(1)
            if alias in module_imports:
                actual = module_imports[alias]
                if actual in all_deps:
                    imports_needed.add(f'NS_{actual}')

    result = sorted(imports_needed)
    if is_exposed:
        result = ['SYSTEM'] + result
    return result


def generate_ns_module(name, dep_info, all_deps, nsc_addr, gateway_index, map_modules, verbose):
    """Generate text for one NS_<name>.mod file.
    Returns (module_text, updated_gateway_index).
    """
    classification = dep_info['classification']
    is_exposed = classification == 'exposed'
    imports = dep_info['imports']
    const_lines = dep_info['const_lines']
    type_lines = dep_info['type_lines']

    lines = []
    lines.append(f'MODULE NS_{name};')
    lines.append(f'(* generated by {PROG_NAME}, do not edit *)')
    lines.append(f'(* Secure module: {name} *)')
    if is_exposed:
        lines.append(f'(* NSC base address: 0{twoc4(nsc_addr)}H *)')

    # IMPORT
    ns_imports = collect_ns_imports(dep_info, all_deps, is_exposed)
    if ns_imports:
        lines.append(f'IMPORT {", ".join(ns_imports)};')
    lines.append('')

    # CONST
    if const_lines:
        lines.append('CONST')
        for cl in const_lines:
            rewritten = rewrite_aliases(cl, imports)
            lines.append(f'  {rewritten}')
        lines.append('')

    # TYPE
    if type_lines and classification in ('exposed', 'type_only'):
        lines.append('TYPE')
        for tl in type_lines:
            rewritten = rewrite_aliases(tl, imports)
            lines.append(f'  {rewritten}')
        lines.append('')

    # Procedure stubs (exposed only)
    if is_exposed:
        lst_path = dep_info['lst_path']
        procs = extract_exported_procs(lst_path)
        code_addr = map_modules[name]['code_addr']

        for proc in procs:
            # rewrite signature
            sig = proc['sig']
            sig_rewritten = rewrite_aliases(sig, imports)
            lines.append(sig_rewritten)
            lines.append('BEGIN')

            push_count = proc['push_count']
            nsc_target = nsc_addr + gateway_index * 16
            addsp_opcode = f'0B0{push_count:02X}'
            nsc_target_str = twoc4(nsc_target + 1)

            lines.append(f'  SYSTEM.EMITH({addsp_opcode}H); (* add sp,#{push_count * 4}, fix stack *)')
            lines.append('  SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)')
            lines.append('  SYSTEM.EMITH(04758H); (* bx r11 *)')
            lines.append('  SYSTEM.ALIGN; (* word alignment *)')
            lines.append(f'  SYSTEM.DATA(0{nsc_target_str}H); (* nsc target address *)')
            lines.append(f'END {proc["name"]};')
            lines.append('')

            gateway_index += 1

    lines.append(f'END NS_{name}.')
    lines.append('')
    return '\n'.join(lines), gateway_index


# --- NSC.bin gateway list ---

def collect_gateways(exposed_names, dep_map, map_modules):
    """Collect target addresses and procedure names for all gateways in order.
    Returns (gateways, proc_names) as parallel lists.
    """
    gateways = []
    proc_names = []
    for name in exposed_names:
        lst_path = dep_map[name]['lst_path']
        procs = extract_exported_procs(lst_path)
        code_addr = map_modules[name]['code_addr']
        for proc in procs:
            target = code_addr + proc['rel_addr']
            gateways.append(target)
            proc_names.append(f'{name}_{proc["name"]}')
    return gateways, proc_names


# --- Module generation order ---

def generation_order(dep_map, exposed_names, const_leaf):
    """Return module names in generation order:
    const-leaf first, then other deps (type/const-only), then exposed.
    """
    const_only = []
    type_only = []
    exposed = []

    for name, info in dep_map.items():
        cls = info['classification']
        if cls == 'exposed':
            exposed.append(name)
        elif name == const_leaf:
            const_only.insert(0, name)
        elif cls == 'const_only':
            const_only.append(name)
        else:
            type_only.append(name)

    # exposed in original order
    exposed_ordered = [n for n in exposed_names if n in dep_map]
    return const_only + type_only + exposed_ordered


# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        prog=PROG_NAME,
        description='Generate NSC veneer binary and NS interface modules.',
    )
    parser.add_argument('s_map_file',
        help='path to Secure program .map file')
    parser.add_argument('module', nargs='*',
        help='S module name(s) to expose')
    parser.add_argument('--nsc-addr',
        help='NSC region address (hex, trailing H accepted)')
    parser.add_argument('--cfg-file', type=Path, metavar='PATH',
        help=f'configuration file (default: {DEFAULT_CFG_FILE} if present)')
    parser.add_argument('--const-leaf',
        help='CONST leaf module name (eg MCU2)')
    parser.add_argument('--nsc-dir',
        help='output directory for NSC.bin and NSC.alst (default: map file directory)')
    parser.add_argument('--ns-dir',
        help='output directory for NS_*.mod files')
    parser.add_argument('-v', '--verbose', action='store_true',
        help='verbose output')

    args = parser.parse_args()

    # load cfg file: explicit --cfg-file, or default if present
    cfg = {}
    if args.cfg_file:
        if not args.cfg_file.is_file():
            error(f'config file not found: {args.cfg_file}')
        cfg = load_cfg(args.cfg_file)
    else:
        default_cfg = Path(DEFAULT_CFG_FILE)
        if default_cfg.is_file():
            cfg = load_cfg(default_cfg)

    # merge: CLI overrides cfg
    nsc_addr_str = args.nsc_addr or cfg.get('nsc-addr')
    ns_dir_str = args.ns_dir or cfg.get('ns-dir')
    nsc_dir_str = args.nsc_dir or cfg.get('nsc-dir')
    const_leaf = args.const_leaf or cfg.get('const-leaf')
    verbose = args.verbose

    # modules: CLI if any given, else cfg
    if args.module:
        module_names = args.module
    else:
        module_names = cfg.get('modules', [])

    # validate required values
    if not nsc_addr_str:
        error('NSC address required (positional argument or nsc-addr in cfg file)')
    if not ns_dir_str:
        error('NS directory required (--ns-dir or ns-dir in cfg file)')
    if not module_names:
        error('at least one exposed module required (positional argument or modules in cfg file)')

    # parse addresses
    try:
        nsc_addr = parse_hex_addr(nsc_addr_str)
    except ValueError:
        error(f'invalid NSC address: {nsc_addr_str}')

    # parse map file
    map_path = Path(args.s_map_file)
    if not map_path.is_file():
        error(f'map file not found: {map_path}')
    map_modules = parse_map(map_path)

    # resolve paths
    nsc_dir = Path(nsc_dir_str) if nsc_dir_str else map_path.parent
    ns_dir = Path(ns_dir_str)

    if not nsc_dir.is_dir():
        error(f'NSC output directory not found: {nsc_dir}')
    if not ns_dir.is_dir():
        error(f'NS output directory not found: {ns_dir}')

    # accept module names as S0 or S0.mod (strip .mod suffix)
    exposed_names = [m[:-4] if m.endswith('.mod') else m for m in module_names]

    # validate exposed modules
    for name in exposed_names:
        if name not in map_modules:
            error(f'module {name} not found in map file')

    # resolve dependencies
    dep_map = resolve_dependencies(exposed_names, map_modules, const_leaf, verbose)

    if verbose:
        for name, info in dep_map.items():
            print(f'{PROG_NAME}: {name} -> {info["classification"]}')

    # build NSC.bin and NSC.alst
    gateways, proc_names = collect_gateways(exposed_names, dep_map, map_modules)
    nsc_bin = build_nsc_bin(gateways)
    nsc_bin_path = nsc_dir / 'NSC.bin'
    nsc_bin_path.write_bytes(nsc_bin)
    print(f'{PROG_NAME}: created {nsc_bin_path} ({len(nsc_bin)} bytes, {len(gateways)} gateways)')

    nsc_alst = generate_nsc_alst(nsc_addr, gateways, proc_names)
    nsc_alst_path = nsc_dir / 'NSC.alst'
    nsc_alst_path.write_text(nsc_alst, encoding='utf-8')
    print(f'{PROG_NAME}: created {nsc_alst_path}')

    # generate NS modules
    order = generation_order(dep_map, exposed_names, const_leaf)
    gateway_index = 0

    for name in order:
        info = dep_map[name]
        text, new_gw_index = generate_ns_module(
            name, info, dep_map, nsc_addr, gateway_index,
            map_modules, verbose,
        )
        if info['classification'] == 'exposed':
            gateway_index = new_gw_index

        mod_path = ns_dir / f'NS_{name}.mod'
        mod_path.write_text(text, encoding='utf-8')
        print(f'{PROG_NAME}: created {mod_path} ({info["classification"]})')

    n_files = len(order) + 2
    print(f'{PROG_NAME}: done, {n_files} files generated ({len(order)} modules, 1 binary, 1 listing)')


if __name__ == '__main__':
    main()
