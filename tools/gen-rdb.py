#!/usr/bin/env python3
"""
gen-rdb -- Generate the rdb directory with debug data files.
--
Reads the Astrobe linker .map file, derives .bin and per-module .lst files,
and generates the rdb/ subdirectory containing:
  - One .alst file per linked module (assembly listing with absolute addresses)
  - _startup.alst (init call sequence pseudo-listing)
  - arm-attr.cfg (ARM ELF attributes for the target MCU)
  - NSC.alst (if --nsc is given, copied from gen-secure output)

WARNING: gen-rdb deletes all existing files in the target rdb directory
before generating new ones. Do not store hand-edited files there.
--
Usage:
    python gen-rdb.py <Prog.map> [--mcu MCU] [--rdb-dir DIR] [--attr-cfg PATH] [-v]

Example:
    python gen-rdb.py SignalSync.map
    python gen-rdb.py SignalSync.map --mcu STM32U585
    python gen-rdb.py s/S.map --rdb-dir s/rdb
    python gen-rdb.py s/S.map --rdb-dir s/rdb --nsc-dir s
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import os
import re
import argparse
import configparser
import shutil
import struct
from pathlib import Path


ALST = '.alst'
DEFAULT_RDB_DIR = 'rdb'

# Map file patterns

_MAP_DATA_RE = re.compile(
    r'^(\w+)\s*([0-9A-F]+)H\s+(\d+)\s+([0-9A-F]+)H\s+(\d+)\s+([0-9A-F]+)H\s+([0-9A-F]+)H'
)
_MAP_FILE_RE = re.compile(r'^(\w+)\s*([C-Z][:].+|/.+)')
_MAP_CODE_RE = re.compile(r'^Code Range:\s+([0-9A-F]+)H')
_MAP_END_RE = re.compile(
    r'^End Addr / Total\s+'
    r'[0-9A-Fa-f]+H\s+'
    r'\d+\s+'
    r'([0-9A-Fa-f]+)H'
)
_MAP_CONFIG_RE = re.compile(r'^Configuration:\s+(.+)')

# Listing file patterns

_ASM_RE = re.compile(
    r'^\.\s+(\d+)\s+[0-9A-F]+H\s+([0-9A-F]+)H\s+([\w\.]+)\s*(.*)'
)
_ANN_RE = re.compile(r'^\.\s+(\d+)\s+(<\w+:)(\s+.+)(>)')
_LINENO_RE = re.compile(r'^\.\s+(\d+)\s+(<LineNo:)\s+(\d+)(>)')
_CASE_RE = re.compile(r'^\.\s+(\d+)\s+(<Case:)\s+(\d+)(>)')
_TYPE_RE = re.compile(r'^\.\s+(\d+)\s+(<Type:)\s+(.+)(>)')
_CONST_RE = re.compile(r'^\.\s+(\d+)\s+(<Const:)\s+([0-9A-F]+)H\s+.+(>)')
_GLOBAL_RE = re.compile(r'^\.\s+(\d+)\s+(<Global:)\s+([0-9A-F]+)H\s+.+(>)')
_STRING_RE = re.compile(r'^\.\s+(\d+)\s+(<String:)\s+(.+)(>)')

# Proc/BL patching patterns

_ASM_LINE_RE = re.compile(
    r'^\.\s+(\d+)\s+([0-9A-F]+)\s+([0-9A-F]+)\s+(.*)', re.IGNORECASE
)
_MODULE_RE = re.compile(r'^MODULE\s+(\w+)')
_PROCEDURE_RE = re.compile(r'^\s*PROCEDURE\*?\s+(\w+)')
_BL_LINE_RE = re.compile(
    r'^\.\s+(\d+)\s+([0-9A-F]+)\s+([0-9A-F]+)\s+(bl\.w\s+)(.*)', re.IGNORECASE
)


# --- Map file parsing ---

def parse_map(map_path):
    """Parse .map file. Returns dict with all extracted data."""
    text = map_path.read_text(encoding='utf-8', errors='replace')

    modules = {}
    code_start = 0
    code_end = None
    config_str = None

    first_line = text.split('\n')[0].strip()
    idx = first_line.find(' Linker')
    tool_name = first_line[:idx] if idx > 0 else first_line

    for line in text.splitlines():
        m = _MAP_DATA_RE.match(line)
        if m:
            mod_name = m.group(1)
            modules[mod_name] = {
                'data_addr': int(m.group(2), 16) - 4,
                'data_size': int(m.group(3)),
                'code_addr': int(m.group(4), 16),
                'code_size': int(m.group(5)),
                'entry_addr': int(m.group(6), 16),
            }
            continue
        m = _MAP_FILE_RE.match(line)
        if m:
            mod_name = m.group(1)
            if mod_name in modules:
                mod_file = Path(m.group(2)).with_suffix('.mod')
                modules[mod_name]['file'] = str(mod_file)
            continue
        m = _MAP_CODE_RE.match(line)
        if m:
            code_start = int(m.group(1), 16)
            continue
        m = _MAP_END_RE.match(line)
        if m:
            code_end = int(m.group(1), 16)
            continue
        m = _MAP_CONFIG_RE.match(line)
        if m:
            config_str = m.group(1).strip()

    return {
        'modules': modules,
        'code_start': code_start,
        'code_end': code_end,
        'config_str': config_str,
        'tool_name': tool_name,
        'prog_name': list(modules)[-1] if modules else map_path.stem,
    }


# --- Binary file access ---

def read_binary(bin_path):
    """Read .bin file. Returns bytes."""
    return bin_path.read_bytes()


def lookup_u32(bin_data, code_start, addr):
    """Read 32-bit LE word from binary at memory address."""
    pos = addr - code_start
    return struct.unpack('<L', bin_data[pos:pos + 4])[0]


def lookup_u16(bin_data, code_start, addr):
    """Read 16-bit LE halfword from binary at memory address."""
    pos = addr - code_start
    return struct.unpack('<H', bin_data[pos:pos + 2])[0]


# --- Module name lookup ---

def get_mod_name(modules, addr):
    """Look up which module owns the given address."""
    for mod, data in modules.items():
        if addr in range(data['data_addr'], data['data_addr'] - data['data_size'], -1):
            return mod, 'data'
        if addr in range(data['code_addr'], data['code_addr'] + data['code_size']):
            return mod, 'code'
    return 'Unknown', ''


# --- Formatting helpers ---

def _hs(n):
    """Format a number as hex string for listing columns."""
    if n <= 0xffff:
        return f"{'':<6s}{n:0>5X}"
    else:
        return f"{'':<2s}{n:0>9X}"


def _twoc(n, word_length):
    """Convert unsigned to signed (two's complement)."""
    if n & (1 << (word_length - 1)):
        n = n - (1 << word_length)
    return n


# --- .alst generation ---

def make_alst(lst_path, code_addr, bin_data, code_start, modules,
              rdb_dir, tool_name, prog_name, mcu_str):
    """Transform one .lst file into an .alst file. Returns output Path."""
    text = lst_path.read_text(encoding='utf-8')
    out_path = rdb_dir / lst_path.with_suffix(ALST).name

    elines = []
    elines.append('. <tool: ' + tool_name + '>')
    elines.append('. <prog: ' + prog_name + '.mod>')
    elines.append('. <mcu: ' + mcu_str + '>\n')

    for line in text.splitlines():
        ln = ['.']

        m = _ASM_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            op_code = int(m.group(2), 16)
            asm_mnemonic = m.group(3)
            rol = m.group(4)
            abs_addr = rel_addr + code_addr
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            if rol.startswith('Ext Proc'):
                op_code = (lookup_u16(bin_data, code_start, abs_addr) << 16) + \
                          lookup_u16(bin_data, code_start, abs_addr + 2)
            ln.append(_hs(op_code))
            ln.append(f"{'':<2s}{asm_mnemonic:<10s}")
            ln.append(rol)
            elines.append(''.join(ln))
            continue

        m = _TYPE_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = m.group(3)
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            bin_val = lookup_u32(bin_data, code_start, abs_addr)
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(_hs(bin_val))
            ln.append(f"{'':<2s}{ann_begin:<9s}")
            ln.append(str(ann_data))
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        m = _LINENO_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = int(m.group(3))
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(_hs(ann_data))
            ln.append(f"{'':<2s}{ann_begin:<9s}")
            ln.append(str(ann_data))
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        m = _CASE_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = int(m.group(3))
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(_hs(ann_data))
            ln.append(f"{'':<2s}{ann_begin:<9s}")
            ln.append(str(ann_data))
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        m = _CONST_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = int(m.group(3), 16)
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(_hs(ann_data))
            ln.append(f"{'':<2s}{ann_begin:<9s}")
            ln.append(str(_twoc(ann_data, 32)))
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        m = _GLOBAL_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = int(m.group(3), 16)
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            bin_val = lookup_u32(bin_data, code_start, abs_addr)
            mod_name, type_str = get_mod_name(modules, bin_val)
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(_hs(bin_val))
            ln.append(f"{'':<2s}{ann_begin:<9s}")
            ln.append(f'{mod_name} {type_str}')
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        m = _STRING_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = m.group(3)
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            bin_val = lookup_u32(bin_data, code_start, abs_addr)
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(f"{'':<2s}{bin_val:0>9X}")
            ln.append(f"{'':<2s}{ann_begin:<9s}")
            ln.append(ann_data)
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        m = _ANN_RE.match(line)
        if m:
            rel_addr = int(m.group(1))
            ann_begin = m.group(2)
            ann_data = m.group(3)
            ann_end = m.group(4)
            abs_addr = rel_addr + code_addr
            ln.append(f'{rel_addr:>6}')
            ln.append(f"{'':<2s}{abs_addr:0>9X}")
            ln.append(f"{'':<14s}{ann_begin}")
            ln.append(ann_data)
            ln.append(ann_end)
            elines.append(''.join(ln))
            continue

        elines.append(line)

    elines.append(' ')
    with out_path.open('w', encoding='utf-8') as f:
        f.write('\n'.join(elines))

    return out_path


# --- BL instruction codec ---

def decode_bl(instr_hex_str):
    """Decode Thumb-2 BL instruction. Returns signed offset or None."""
    try:
        instr = int(instr_hex_str, 16)
        first_half = (instr >> 16) & 0xFFFF
        second_half = instr & 0xFFFF

        # bl.w: 11110 S imm10 | 11 J1 1 J2 imm11
        if (first_half & 0xF800) != 0xF000:
            return None
        if (second_half & 0xD000) != 0xD000:
            return None

        S = (first_half >> 10) & 1
        imm10 = first_half & 0x3FF
        J1 = (second_half >> 13) & 1
        J2 = (second_half >> 11) & 1
        imm11 = second_half & 0x7FF

        I1 = 1 if (J1 ^ S) == 0 else 0
        I2 = 1 if (J2 ^ S) == 0 else 0

        offset = (S << 23) | (I1 << 22) | (I2 << 21) | (imm10 << 11) | imm11
        if offset & 0x800000:
            offset |= 0xFF000000
        if offset >= 0x80000000:
            offset -= 0x100000000

        return offset

    except (ValueError, TypeError):
        return None


def encode_bl(pc, target):
    """Encode Thumb-2 BL instruction. Returns 4 bytes (little-endian halfwords)."""
    offset = target - (pc + 4)
    if not (-(1 << 24) <= offset < (1 << 24)):
        raise ValueError(f'BL offset out of range: {offset:#x}')
    uoff = offset & 0x1FFFFFF
    s = (uoff >> 24) & 1
    i1 = (uoff >> 23) & 1
    i2 = (uoff >> 22) & 1
    imm10 = (uoff >> 12) & 0x3FF
    imm11 = (uoff >> 1) & 0x7FF
    j1 = (i1 ^ s ^ 1) & 1
    j2 = (i2 ^ s ^ 1) & 1
    hw1 = 0xF000 | (s << 10) | imm10
    hw2 = 0xD000 | (j1 << 13) | (j2 << 11) | imm11
    return struct.pack('<HH', hw1, hw2)


# --- Procedure database and BL patching ---

def build_proc_db(rdb_dir):
    """Build procedure address database from all .alst files.
    Returns dict: addr_hex_str -> (module_name, proc_name)."""
    proc_db = {}
    for f in rdb_dir.iterdir():
        if not (f.is_file() and f.suffix == ALST):
            continue
        lines = f.read_text(encoding='utf-8').splitlines()
        mod_name = None
        pending = None
        for line in lines:
            m = _MODULE_RE.match(line)
            if m:
                mod_name = m.group(1)
                pending = None
                continue
            m = _PROCEDURE_RE.match(line)
            if m:
                pending = m.group(1)
                continue
            if pending is not None:
                m = _ASM_LINE_RE.match(line)
                if m:
                    abs_addr = int(m.group(2), 16)
                    key = f'{abs_addr:08X}'
                    if mod_name is not None:
                        proc_db[key] = (mod_name, pending)
                    pending = None
    return proc_db


def patch_bl_calls(rdb_dir, proc_db):
    """Patch bl.w targets with procedure names in all .alst files."""
    for efile in rdb_dir.iterdir():
        if not (efile.is_file() and efile.suffix == ALST):
            continue
        lines = efile.read_text(encoding='utf-8').splitlines()
        mod_name = None
        elines = []

        for line in lines:
            m = _MODULE_RE.match(line)
            if m:
                mod_name = m.group(1)
                elines.append(line)
                continue

            m = _BL_LINE_RE.match(line)
            if m:
                abs_addr_str = m.group(2)
                instr_str = m.group(3)
                rol = m.group(5)
                offset = decode_bl(instr_str)
                if offset is not None:
                    abs_addr = int(abs_addr_str, 16)
                    target_addr = abs_addr + 4 + (offset * 2)
                    target_key = f'{target_addr:08X}'
                    if target_key in proc_db:
                        module, proc = proc_db[target_key]
                        if module == mod_name:
                            line = line.replace(
                                rol, f'{proc} [{offset} -> {target_key}]')
                        else:
                            line = line.replace(
                                rol, f'{module}.{proc} [{offset} -> {target_key}]')
                elines.append(line)
                continue

            elines.append(line)

        elines.append(' ')
        with efile.open('w', encoding='utf-8') as f:
            f.write('\n'.join(elines))


# --- Startup listing ---

_STARTUP_HEADER_LINES = 6  # tool, prog, mcu, blank, MODULE, blank


def generate_startup(modules, code_end, prog_name, mcu_str):
    """Generate _startup.alst content."""
    lines = []
    lines.append('. <tool: gen-rdb>')
    lines.append(f'. <prog: {prog_name}.mod>')
    lines.append(f'. <mcu: {mcu_str}>')
    lines.append('')
    lines.append('MODULE _startup;')
    lines.append('')

    pc = code_end
    mod_list = list(modules.items())
    for i, (name, data) in enumerate(mod_list):
        file_line = _STARTUP_HEADER_LINES + i + 1
        raw = encode_bl(pc, data['entry_addr'])
        hw1, hw2 = struct.unpack('<HH', raw)
        instr = f'{hw1:04X}{hw2:04X}'
        lines.append(
            f'.{file_line:6d}  {pc:08X}  {instr}  bl.w  {name}..init'
        )
        pc += 4

    # Terminal self-loop
    file_line = _STARTUP_HEADER_LINES + len(mod_list) + 1
    raw = encode_bl(pc, pc)
    hw1, hw2 = struct.unpack('<HH', raw)
    instr = f'{hw1:04X}{hw2:04X}'
    lines.append(
        f'.{file_line:6d}  {pc:08X}  {instr}  bl.w  {pc:08X}'
    )

    lines.append('')
    lines.append('END _startup.')
    lines.append('')
    return '\n'.join(lines)


# --- MCU resolution ---

def resolve_mcu(config_str, mcu_override, attr_sections):
    """Determine MCU from --mcu argument or .map Configuration line.
    Returns (mcu_name, core_name) or (None, None) if unresolved."""
    if mcu_override:
        if attr_sections and mcu_override in attr_sections:
            section = attr_sections[mcu_override]
            if 'CPU' in section:
                return mcu_override, section['CPU']
        return mcu_override, None

    if not config_str:
        return None, None

    tokens = config_str.split()
    if attr_sections:
        for token in tokens:
            if token in attr_sections:
                section = attr_sections[token]
                if 'CPU' in section:
                    return token, section['CPU']
                # It's a core section (has Tag_* lines)
                return token, token

    # No match in attr_sections -- cannot identify MCU
    return None, None


# --- Attribute config ---

def load_attr_cfg(attr_cfg_path):
    """Parse master arm-elf-attr.cfg. Returns {section: {key: value}}."""
    cp = configparser.ConfigParser()
    cp.optionxform = str
    cp.read(str(attr_cfg_path), encoding='utf-8')
    sections = {}
    for sec in cp.sections():
        sections[sec] = dict(cp.items(sec))
    return sections



def write_arm_attr(rdb_dir, mcu_name, core_name, attr_sections, attr_cfg_path):
    """Write rdb/arm-attr.cfg for the given MCU.
    MCU sections inherit all tags from their core section, then any
    Tag_* lines in the MCU section override individual core defaults."""
    if mcu_name in attr_sections:
        mcu_section = attr_sections[mcu_name]
        if 'CPU' in mcu_section:
            core = mcu_section['CPU']
            if core not in attr_sections:
                return False
            # Start with core tags, apply MCU overrides
            tags = dict(attr_sections[core])
            for key, val in mcu_section.items():
                if key.startswith('Tag_'):
                    tags[key] = val
        else:
            tags = mcu_section
    elif core_name and core_name in attr_sections:
        tags = attr_sections[core_name]
    else:
        return False

    label = f'{mcu_name} ({core_name})' if core_name else mcu_name
    lines = []
    lines.append(f'# ARM ELF Attributes for {label}')
    lines.append(f'# Generated by gen-rdb from {attr_cfg_path.name}')
    lines.append('')
    for key, val in tags.items():
        if key.startswith('Tag_'):
            lines.append(f'{key} = {val}')
    lines.append('')

    out_path = rdb_dir / 'arm-attr.cfg'
    out_path.write_text('\n'.join(lines), encoding='utf-8')
    return True


# --- Main ---

def main():
    parser = argparse.ArgumentParser(
        description='Generate the rdb directory with debug data files.'
    )
    parser.add_argument(
        'map_file',
        type=Path,
        help='Linker .map file'
    )
    parser.add_argument(
        '--mcu',
        metavar='MCU',
        help='Override MCU identifier (skips .map Configuration lookup)'
    )
    parser.add_argument(
        '--rdb-dir',
        default=DEFAULT_RDB_DIR,
        metavar='DIR',
        help=f'Output directory path relative to cwd (default: {DEFAULT_RDB_DIR})'
    )
    parser.add_argument(
        '--attr-cfg',
        type=Path,
        metavar='PATH',
        help='Path to master arm-elf-attr.cfg'
    )
    parser.add_argument(
        '--nsc-dir',
        type=Path,
        metavar='DIR',
        help='Directory containing NSC.alst to copy into rdb directory'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )
    args = parser.parse_args()

    map_path = args.map_file
    if not map_path.exists():
        print(f'Error: map file not found: {map_path}', file=sys.stderr)
        sys.exit(1)

    bin_path = map_path.with_suffix('.bin')
    if not bin_path.exists():
        print(f'Error: binary file not found: {bin_path}', file=sys.stderr)
        sys.exit(1)

    # Parse .map file
    map_data = parse_map(map_path)

    # Read .bin file
    bin_data = read_binary(bin_path)
    code_start = map_data['code_start']

    # Load attr cfg (--attr-cfg or RTK_ARM_ATTR_CFG env var)
    attr_sections = None
    attr_cfg_path = None
    if args.attr_cfg:
        attr_cfg_path = args.attr_cfg
    else:
        env_val = os.environ.get('RTK_ARM_ATTR_CFG')
        if env_val:
            attr_cfg_path = Path(env_val)
    if attr_cfg_path is not None:
        if not attr_cfg_path.exists():
            print(f'Error: attr-cfg not found: {attr_cfg_path}', file=sys.stderr)
            sys.exit(1)
        attr_sections = load_attr_cfg(attr_cfg_path)

    # Resolve MCU
    mcu_name, core_name = resolve_mcu(
        map_data['config_str'], args.mcu, attr_sections)
    if mcu_name and core_name:
        mcu_str = f'{mcu_name}/{core_name}'
    elif mcu_name:
        mcu_str = mcu_name
    else:
        mcu_str = 'unknown'

    if mcu_str == 'unknown':
        print('Warning: MCU not resolved from Configuration line',
              file=sys.stderr)

    # Clear + create rdb dir (path relative to cwd)
    rdb_dir = Path(args.rdb_dir)
    if rdb_dir.exists():
        for f in rdb_dir.iterdir():
            if not f.is_dir():
                f.unlink()
    rdb_dir.mkdir(exist_ok=True)

    # Pass 1: generate .alst files from .lst files
    tool_name = map_data['tool_name']
    prog_name = map_data['prog_name']
    modules = map_data['modules']

    n_created = 0
    n_skipped = 0
    for mod_name, mod in modules.items():
        if 'file' not in mod:
            continue
        lst_path = Path(mod['file']).with_suffix('.lst')
        if not lst_path.exists():
            if args.verbose:
                print(f'  skip (no .lst): {lst_path.stem}')
            n_skipped += 1
            continue
        make_alst(lst_path, mod['code_addr'], bin_data, code_start,
                  modules, rdb_dir, tool_name, prog_name, mcu_str)
        if args.verbose:
            print(f'  created: {lst_path.stem}{ALST}')
        n_created += 1

    # Pass 2: build proc db, patch bl.w calls
    proc_db = build_proc_db(rdb_dir)
    patch_bl_calls(rdb_dir, proc_db)

    # Generate _startup.alst
    if map_data['code_end'] is not None:
        startup_content = generate_startup(
            modules, map_data['code_end'], prog_name, mcu_str)
        startup_path = rdb_dir / '_startup.alst'
        startup_path.write_text(startup_content, encoding='utf-8')
        if args.verbose:
            n_mods = len(modules)
            print(f'  created: _startup.alst ({n_mods} modules)')
    else:
        print('Warning: no "End Addr / Total" in .map, skipping _startup.alst',
              file=sys.stderr)

    # Generate arm-attr.cfg
    attr_written = False
    if mcu_str != 'unknown' and attr_sections:
        attr_written = write_arm_attr(
            rdb_dir, mcu_name, core_name, attr_sections, attr_cfg_path)
        if args.verbose and attr_written:
            print(f'  created: arm-attr.cfg ({mcu_str})')

    if not attr_written and mcu_str != 'unknown' and not attr_sections:
        print('Warning: arm-elf-attr.cfg not found, skipping arm-attr.cfg',
              file=sys.stderr)

    # Copy NSC.alst if requested
    if args.nsc_dir:
        nsc_src = args.nsc_dir / 'NSC.alst'
        if nsc_src.exists():
            shutil.copy2(nsc_src, rdb_dir / 'NSC.alst')
            if args.verbose:
                print('  copied: NSC.alst')
        else:
            print(f'Warning: NSC.alst not found in: {args.nsc_dir}',
                  file=sys.stderr)

    # Summary
    print(f'gen-rdb: {n_created} .alst files created in {rdb_dir}')
    if n_skipped:
        print(f'gen-rdb: {n_skipped} module(s) skipped (no .lst file)')


if __name__ == '__main__':
    main()
