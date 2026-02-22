#!/usr/bin/env python3

"""
Create the rdb directory with .alst debug listing files.
--
Reads the Astrobe linker .map and .bin files produced after linking, together
with the per-module .lst files produced by the compiler, and creates a
subdirectory (default: rdb/) containing one .alst file per linked module.

The .alst files are consumed by makeelf to build a debug-ready ELF file.
--
Run with option -h for help.
--
Put into a directory on $PYTHONPATH, and run as
'python -m  makerdb ...
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import re
import argparse
import struct
from pathlib import Path


ELST = '.alst'
DEFAULT_RDB_DIR = 'rdb'


class ARMinstrDecoder:
    """ARM Thumb-2 instruction decoder"""

    @staticmethod
    def decode_bl_instr(instr_hex_str):
        """Decode ARM Thumb-2 bl.w instruction to extract signed halfword offset."""
        try:
            instr = int(instr_hex_str, 16)
            first_half  = (instr >> 16) & 0xFFFF
            second_half =  instr        & 0xFFFF

            # bl.w: 11110 S imm10 | 11 J1 1 J2 imm11
            if (first_half  & 0xF800) != 0xF000:
                return None
            if (second_half & 0xD000) != 0xD000:
                return None

            S     = (first_half  >> 10) & 1
            imm10 =  first_half         & 0x3FF
            J1    = (second_half >> 13) & 1
            J2    = (second_half >> 11) & 1
            imm11 =  second_half        & 0x7FF

            I1 = 1 if (J1 ^ S) == 0 else 0
            I2 = 1 if (J2 ^ S) == 0 else 0

            offset = (S << 23) | (I1 << 22) | (I2 << 21) | (imm10 << 11) | imm11
            if offset & 0x800000:       # sign-extend to 32 bits
                offset |= 0xFF000000
            if offset >= 0x80000000:    # convert to Python signed int
                offset -= 0x100000000

            return offset

        except (ValueError, TypeError):
            return None

class MapFile:

    data_pat = r'^(\w+)\s*([0-9A-F]+)H\s+(\d+)\s+([0-9A-F]+)H\s+(\d+)\s+([0-9A-F]+)H\s+([0-9A-F]+)H'
    file_pat = r'^(\w+)\s*([C-Z][:].+|/.+)'
    res_pat  = r'^\.ref\s+([0-9A-F]+)H\s+(\d+)'
    code_pat = r'^Code Range:\s+([0-9A-F]+)H'

    def __init__(self, file_path):
        self._file = Path(file_path)

    def read(self):
        with self._file.open('r', encoding='utf-8') as f:
            self._text = f.read()

    def extract(self):
        mod_re  = re.compile(self.data_pat)
        file_re = re.compile(self.file_pat)
        res_re  = re.compile(self.res_pat)
        code_re = re.compile(self.code_pat)

        modules   = dict()
        prog_data = {}
        code_start = 0

        for l in self._text.splitlines():
            m = mod_re.match(l)
            if m is not None:
                mod_name   = m.group(1)
                data_addr  = int(m.group(2), 16)
                data_size  = int(m.group(3))
                code_addr  = int(m.group(4), 16)
                code_size  = int(m.group(5))
                entry_addr = int(m.group(6), 16)
                modules[mod_name] = {
                    'data_addr':  data_addr - 4,
                    'data_size':  data_size,
                    'code_addr':  code_addr,
                    'code_size':  code_size,
                    'entry_addr': entry_addr,
                }
                continue
            m = file_re.match(l)
            if m is not None:
                mod_name  = m.group(1)
                file_path = m.group(2)
                if mod_name in modules:
                    mod_file = Path(file_path).with_suffix('.mod')
                    modules[mod_name]['file'] = str(mod_file)
                continue
            m = res_re.match(l)
            if m is not None:
                prog_data = {
                    'res_addr': int(m.group(1), 16),
                    'res_size': int(m.group(2)),
                }
                continue
            m = code_re.match(l)
            if m is not None:
                code_start = int(m.group(1), 16)

        self._modules   = modules
        self._prog_data = prog_data
        self._code_start = code_start

    def get_mod_data(self):
        """Return list of {file, code_addr} for each module that has a file entry."""
        return [
            {'file': md['file'], 'code_addr': md['code_addr']}
            for md in self._modules.values()
            if 'file' in md
        ]

    def get_code_start(self):
        return self._code_start

    def get_mod_name(self, addr):
        for mod, data in self._modules.items():
            if addr in range(data['data_addr'], data['data_addr'] - data['data_size'], -1):
                return mod, 'data'
            if addr in range(data['code_addr'], data['code_addr'] + data['code_size']):
                return mod, 'code'
        return 'Unknown', ''

    def get_prog_module(self):
        """Return path to main program .mod file (same stem as .map file)."""
        return str(self._file.with_suffix('.mod'))

    def get_tool_name(self):
        """Extract tool name from map header, e.g. 'Astrobe for RP2350'."""
        first_line = self._text.split('\n')[0].strip()
        idx = first_line.find(' Linker')
        return first_line[:idx] if idx > 0 else first_line


class BinFile:

    def __init__(self, file_path, code_start):
        self._file       = Path(file_path)
        self._code_start = code_start

    def read(self):
        with self._file.open('rb') as f:
            self._data = f.read()

    def lookup(self, mem_addr):
        """Read a 32-bit LE word at the given memory address."""
        pos = mem_addr - self._code_start
        return struct.unpack('<L', self._data[pos:pos + 4])[0]

    def lookup2(self, mem_addr):
        """Read a 16-bit LE halfword at the given memory address."""
        pos = mem_addr - self._code_start
        return struct.unpack('<H', self._data[pos:pos + 2])[0]


class LstFile:

    asm_pat    = r'^\.\s+(\d+)\s+[0-9A-F]+H\s+([0-9A-F]+)H\s+([\w\.]+)\s*(.*)'
    ann_pat    = r'^\.\s+(\d+)\s+(<\w+:)(\s+.+)(>)'
    lineno_pat = r'^\.\s+(\d+)\s+(<LineNo:)\s+(\d+)(>)'
    case_pat   = r'^\.\s+(\d+)\s+(<Case:)\s+(\d+)(>)'
    type_pat   = r'^\.\s+(\d+)\s+(<Type:)\s+(.+)(>)'
    const_pat  = r'^\.\s+(\d+)\s+(<Const:)\s+([0-9A-F]+)H\s+.+(>)'
    global_pat = r'^\.\s+(\d+)\s+(<Global:)\s+([0-9A-F]+)H\s+.+(>)'
    string_pat = r'^\.\s+(\d+)\s+(<String:)\s+(.+)(>)'

    def __init__(self, mod_file_path):
        self._file = Path(mod_file_path).with_suffix('.lst')

    def exists(self):
        return self._file.exists()

    def read(self):
        with self._file.open('r', encoding='utf-8') as f:
            self._text = f.read()

    def hs(self, n):
        if n <= 0xffff:
            return f"{'':<6s}{n:0>5X}"
        else:
            return f"{'':<2s}{n:0>9X}"

    def twoc(self, n, word_length):
        if n & (1 << (word_length - 1)):
            n = n - (1 << word_length)
        return n

    def make_elst_file(self, code_addr, bin_file, map_file, rdb_dir, tool_name):
        asm_re    = re.compile(self.asm_pat)
        ann_re    = re.compile(self.ann_pat)
        lineno_re = re.compile(self.lineno_pat)
        case_re   = re.compile(self.case_pat)
        type_re   = re.compile(self.type_pat)
        const_re  = re.compile(self.const_pat)
        global_re = re.compile(self.global_pat)
        string_re = re.compile(self.string_pat)

        self._efile = rdb_dir.joinpath(self._file.name).with_suffix(ELST)

        elines = []
        elines.append('. <tool: ' + tool_name + '>')
        elines.append('. <prog: ' + map_file.get_prog_module() + '>\n')

        for l in self._text.splitlines():
            ln = ['.']
            m = asm_re.match(l)
            if m is not None:
                rel_addr     = int(m.group(1))
                op_code      = int(m.group(2), 16)
                asm_mnemonic = m.group(3)
                rol          = m.group(4)
                abs_addr     = rel_addr + code_addr
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                if rol.startswith('Ext Proc'):
                    op_code = (bin_file.lookup2(abs_addr) << 16) + bin_file.lookup2(abs_addr + 2)
                ln.append(self.hs(op_code))
                ln.append(f"{'':<2s}{asm_mnemonic:<10s}")
                ln.append(rol)
                elines.append(''.join(ln))
                continue
            m = type_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = m.group(3)
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                bin_data  = bin_file.lookup(abs_addr)
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(self.hs(abs_addr))
                ln.append(self.hs(bin_data))
                ln.append(f"{'':<2s}{ann_begin:<9s}")
                ln.append(str(ann_data))
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            m = lineno_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = int(m.group(3))
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(self.hs(ann_data))
                ln.append(f"{'':<2s}{ann_begin:<9s}")
                ln.append(str(ann_data))
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            m = case_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = int(m.group(3))
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(self.hs(ann_data))
                ln.append(f"{'':<2s}{ann_begin:<9s}")
                ln.append(str(ann_data))
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            m = const_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = int(m.group(3), 16)
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(self.hs(ann_data))
                ln.append(f"{'':<2s}{ann_begin:<9s}")
                ln.append(str(self.twoc(ann_data, 32)))
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            m = global_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = int(m.group(3), 16)
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                bin_data  = bin_file.lookup(abs_addr)
                mod_name, type_str = map_file.get_mod_name(bin_data)
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(self.hs(bin_data))
                ln.append(f"{'':<2s}{ann_begin:<9s}")
                ln.append(f'{mod_name} {type_str}')
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            m = string_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = m.group(3)
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                bin_data  = bin_file.lookup(abs_addr)
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(f"{'':<2s}{bin_data:0>9X}")
                ln.append(f"{'':<2s}{ann_begin:<9s}")
                ln.append(ann_data)
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            m = ann_re.match(l)
            if m is not None:
                rel_addr  = int(m.group(1))
                ann_begin = m.group(2)
                ann_data  = m.group(3)
                ann_end   = m.group(4)
                abs_addr  = rel_addr + code_addr
                ln.append(f'{rel_addr:>6}')
                ln.append(f"{'':<2s}{abs_addr:0>9X}")
                ln.append(f"{'':<14s}{ann_begin}")
                ln.append(ann_data)
                ln.append(ann_end)
                elines.append(''.join(ln))
                continue
            elines.append(l)

        elines.append(' ')
        with self._efile.open('w', encoding='utf-8') as f:
            f.write('\n'.join(elines))

        return self._efile


class ProcData:
    """Database of all procedures in all program modules.

    Key = absolute entry address as 8-character uppercase hex string.
    Value = (module_name, proc_name).
    """
    asm_line_pat = r'^\.\s+(\d+)\s+([0-9A-F]+)\s+([0-9A-F]+)\s+(.*)'
    module_pat = r'^MODULE\s+(\w+)'
    procedure_pat = r'^\s*PROCEDURE\*?\s+(\w+)'

    def __init__(self, debug_dir):
        self._dir  = Path(debug_dir)
        self._data = {}

    def build(self):
        for f in self._dir.iterdir():
            if f.is_file() and f.suffix == ELST:
                self._extract_procs(f)

    def _extract_procs(self, elst_file):

        asm_line_re = re.compile(self.asm_line_pat, re.IGNORECASE)
        module_re = re.compile(self.module_pat)
        procedure_re = re.compile(self.procedure_pat)

        lines    = elst_file.read_text(encoding='utf-8').splitlines()
        mod_name = None
        pending  = None   # pending procedure name

        for line in lines:
            m = module_re.match(line)
            if m:
                mod_name = m.group(1)
                pending  = None
                continue
            m = procedure_re.match(line)
            if m:
                pending = m.group(1)
                continue
            if pending is not None:
                m = asm_line_re.match(line)
                if m:
                    abs_addr = int(m.group(2), 16)
                    key = f'{abs_addr:08X}'
                    if mod_name is not None:
                        self._data[key] = (mod_name, pending)
                    pending = None

    def lookup(self, abs_addr_str):
        return self._data[abs_addr_str]


class ElstFiles:

    module_pat = r'^MODULE\s+(\w+)'
    bl_pat = r'^\.\s+(\d+)\s+([0-9A-F]+)\s+([0-9A-F]+)\s+(bl\.w\s+)(.*)'

    def __init__(self, debug_dir):
        self._dir = Path(debug_dir)

    def patch_calls(self, proc_data):

        bl_re = re.compile(self.bl_pat, re.IGNORECASE)
        module_re = re.compile(self.module_pat)

        decoder = ARMinstrDecoder()
        for efile in self._dir.iterdir():
            if not (efile.is_file() and efile.suffix == ELST):
                continue
            lines    = efile.read_text(encoding='utf-8').splitlines()
            mod_name = None
            elines   = []

            for l in lines:
                m = module_re.match(l)
                if m:
                    mod_name = m.group(1)
                    elines.append(l)
                    continue
                m = bl_re.match(l)
                if m:
                    abs_addr_str = m.group(2)
                    instr_str = m.group(3)
                    rol = m.group(5)
                    offset = decoder.decode_bl_instr(instr_str)
                    if offset is not None:
                        abs_addr    = int(abs_addr_str, 16)
                        target_addr = abs_addr + 4 + (offset * 2)
                        target_key  = f'{target_addr:08X}'
                        try:
                            module, proc = proc_data.lookup(target_key)
                            if module == mod_name:
                                l = l.replace(rol, f'{proc} [{offset} -> {target_key}]')
                            else:
                                l = l.replace(rol, f'{module}.{proc} [{offset} -> {target_key}]')
                        except KeyError:
                            pass  # leave line unchanged if target not in database
                    elines.append(l)
                    continue

                elines.append(l)

            elines.append(' ')
            with efile.open('w', encoding='utf-8') as f:
                f.write('\n'.join(elines))


def main():
    parser = argparse.ArgumentParser(
        description='Create the rdb directory with .alst debug listing files.'
    )
    parser.add_argument(
        'mod_file',
        help='Program module file (.mod)'
    )
    parser.add_argument(
        '-d',
        default=DEFAULT_RDB_DIR,
        dest='rdb_dir',
        help=f'Name of the output subdirectory (default: {DEFAULT_RDB_DIR})'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Print each .alst file as it is created'
    )
    args = parser.parse_args()

    mod_path = Path(args.mod_file)
    map_path = mod_path.with_suffix('.map')
    bin_path = mod_path.with_suffix('.bin')

    if not mod_path.exists():
        print(f'Error: module file not found: {mod_path}', file=sys.stderr)
        sys.exit(1)
    if not map_path.exists():
        print(f'Error: map file not found: {map_path}', file=sys.stderr)
        sys.exit(1)
    if not bin_path.exists():
        print(f'Error: binary file not found: {bin_path}', file=sys.stderr)
        sys.exit(1)

    rdb_dir = mod_path.parent / args.rdb_dir

    # Clear existing .alst files before creating new ones
    if rdb_dir.exists():
        for f in rdb_dir.iterdir():
            if not f.is_dir() and f.suffix == ELST:
                f.unlink()

    # Read map and binary
    map_file = MapFile(map_path)
    map_file.read()
    map_file.extract()
    tool_name  = map_file.get_tool_name()
    code_start = map_file.get_code_start()

    bin_file = BinFile(bin_path, code_start)
    bin_file.read()

    rdb_dir.mkdir(exist_ok=True)

    # Pass 1: create .alst files from .lst files
    n_created = 0
    n_skipped = 0
    for md in map_file.get_mod_data():
        lst = LstFile(md['file'])
        if not lst.exists():
            if args.verbose:
                print(f'  skip (no .lst): {Path(md["file"]).stem}')
            n_skipped += 1
            continue
        lst.read()
        efile = lst.make_elst_file(md['code_addr'], bin_file, map_file, rdb_dir, tool_name)
        if args.verbose:
            print(f'  created: {efile.name}')
        n_created += 1

    # Pass 2: resolve bl.w call targets in all .alst files
    proc_data = ProcData(rdb_dir)
    proc_data.build()

    elst_files = ElstFiles(rdb_dir)
    elst_files.patch_calls(proc_data)


    print(f'makerdb: {n_created} .alst files created in {rdb_dir}')
    if n_skipped:
        print(f'makerdb: {n_skipped} module(s) skipped (no .lst file)')


if __name__ == '__main__':
    main()
