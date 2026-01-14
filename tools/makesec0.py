#!/usr/bin/env python3

# Create and update NSC and NS modules to call Secure code
# from Non-secure code.
# Proof-of-concept
# --
# Supported platforms: Windows, macOS
# --
# Run python -m makesec -h for help.
# --
# Copyright (c) 2025-2026 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import sys, struct, re
from pathlib import Path
import pylib.commands as commands

## constants
WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'makesec'
NSC = 'NSC'
NS = 'NS'
NSC_dir = 'nsc'
NS_dir = 'ns'

## commands
class MainCmd(commands.Command):
    _defs = {
        'oargs': {
            'verbose': {
                'flags': ['-v'],
                'help': 'verbose, print feedback',
                'action': 'store_true',
            }
        }
    }

    def run(self, args):
        print(f'{PROG_NAME}: use a command, type \'{PROG_NAME} -h\' for a list of commands')


class MakeCmd(commands.Command):
    _defs = {
        'help': '',
        'pargs': {
            'mod_file': {
                'help': 'secure module file (.mod)',
            },
        },
    }

    def run(self, args):

        mod_f = Path(args.mod_file).resolve()
        if not mod_f.is_file():
            print(f'{PROG_NAME}: cannot find secure module file {mod_f}')
            sys.exit(1)

        pat = Patterns()
        files = Files(mod_f)
        s_mod = Smod(files)

        if not s_mod.is_secure(pat):
            print(f'{PROG_NAME}: module is not marked as secure {mod_f}')
            sys.exit(1)

        nsc_mod = NSCmod(files, s_mod)
        nsc_mod.make(pat)
        nsc_mod.write_mod_file()
        ns_mod = NSmod(files, s_mod)
        ns_mod.make(pat)
        ns_mod.write_mod_file()


class FixupCmd(commands.Command):
    _defs = {
        'help': '',
        'pargs': {
            'mod_file': {
                'help': 'secure module file (.mod)',
            },
            's_addr': {
                'help': 'absolute address of S module in hexadecimal'
            },
            'nsc_addr': {
                'help': 'absolute address of NSC module in hexadecimal'
            },
        },
    }

    def run(self, args):

        mod_f = Path(args.mod_file).resolve()
        if not mod_f.is_file():
            print(f'{PROG_NAME}: cannot find secure module file {mod_f}')
            sys.exit(1)

        pat = Patterns()
        files = Files(mod_f)
        s_mod = Smod(files)

        if not s_mod.is_secure(pat):
            print(f'{PROG_NAME}: module is not marked as secure {mod_f}')
            sys.exit(1)

        try:
            s_addr = int(args.s_addr, 16)
            nsc_addr = int(args.nsc_addr, 16)
        except:
          print(f'{PROG_NAME}: enter addresses in hexadecimal format (with or without \'0x\' prefix)')
          sys.exit(1)

        nsc_mod = NSCmod(files, s_mod)
        nsc_mod.fixup(s_addr, pat)
        nsc_mod.write_mod_file()
        ns_mod = NSmod(files, s_mod)
        ns_mod.fixup(nsc_addr, pat)
        ns_mod.write_mod_file()


class Patterns:
    sec_pat = r'^\s*\(\*!\s*SEC\s*\*\)'
    proc_begin_pat = r'^\s*(PROCEDURE\s*\*?\s+([\w]+)\s*(\*?).*;)'
    asm_pat = r'^\.\s+(\d+)\s+([0-9A-F]+H)\s+([0-9A-F]+H)\s+([\w\.]+)\s*(.*)'
    # data_pat = r'^\s*(\(\*=\s*B\s*(\d+)\s*\*\))\s*SYSTEM.DATA.*'
    data_s_pat = r'^\s*(\(\*!addr_s\s*(\d+)\s+\*\))\s*SYSTEM.DATA.*'
    data_nsc_pat = r'^\s*(\(\*!addr_nsc\s*(\d+)\s+\*\))\s*SYSTEM.DATA.*'

    def __init__(self):
        self._sec_re = re.compile(self.sec_pat)
        self._proc_begin_re = re.compile(self.proc_begin_pat)
        self._asm_re = re.compile(self.asm_pat)
        self._data_s_re = re.compile(self.data_s_pat)
        self._data_nsc_re = re.compile(self.data_nsc_pat)

    @property
    def sec_re(self):
        return self._sec_re

    @property
    def proc_begin_re(self):
        return self._proc_begin_re

    @property
    def asm_re(self):
        return self._asm_re

    @property
    def data_s_re(self):
        return self._data_s_re

    @property
    def data_nsc_re(self):
        return self._data_nsc_re


class Files:
    def __init__(self, s_mod_file): # Path
        self._s_mod_file = s_mod_file
        self._s_mod_name = s_mod_file.stem.upper()
        self._s_lst_file = s_mod_file.with_suffix('.lst')
        self._s_map_file = s_mod_file.with_suffix('.map')
        self._nsc_dir = s_mod_file.parent.parent.joinpath(NSC_dir)
        self._nsc_mod_name = f'{NSC}_{self._s_mod_name}'
        self._nsc_mod_file = self._nsc_dir.joinpath(self._nsc_mod_name).with_suffix('.mod')
        self._nsc_lst_file = self._nsc_mod_file.with_suffix('.lst')
        self._nsc_map_file = self._nsc_mod_file.with_suffix('.map')
        self._ns_dir = s_mod_file.parent.parent.joinpath(NS_dir)
        self._ns_mod_name = f'{NS}_{self._s_mod_name}'
        self._ns_mod_file = self._ns_dir.joinpath(self._ns_mod_name).with_suffix('.mod')
        self._ns_lst_file = self._ns_mod_file.with_suffix('.lst')
        # print(self.s_mod_file)
        # print(self.s_mod_name)
        # print(self.s_lst_file)
        # print(self.nsc_mod_name)
        # print(self.nsc_mod_file)
        # print(self.nsc_lst_file)
        # print(self.ns_mod_name)
        # print(self.ns_mod_file)
        # print(self.ns_lst_file)

        if not self._s_mod_file.is_file():
            print(f'{PROG_NAME}: cannot find secure module file {self._s_mod_file}')
            sys.exit(1)
        if not self._s_lst_file.is_file():
            print(f'{PROG_NAME}: cannot find secure listing file {self._s_lst_file}')
            sys.exit(1)


    @property
    def s_mod_file(self):
        return self._s_mod_file

    @property
    def s_lst_file(self):
        return self._s_lst_file

    @property
    def s_map_file(self):
        return self._s_map_file

    @property
    def s_mod_name(self):
        return self._s_mod_name

    @property
    def nsc_mod_file(self):
        return self._nsc_mod_file

    @property
    def nsc_lst_file(self):
        return self._nsc_lst_file

    @property
    def nsc_map_file(self):
        return self._nsc_map_file

    @property
    def nsc_mod_name(self):
        return self._nsc_mod_name

    @property
    def ns_mod_file(self):
        return self._ns_mod_file

    @property
    def ns_lst_file(self):
        return self._ns_lst_file

    @property
    def ns_mod_name(self):
        return self._ns_mod_name


class Smod:
    def __init__(self, files):
        try:
            with files.s_mod_file.open('r') as f:
                    mod_txt = f.read()
        except:
            print(f'{PROG_NAME}: cannot read secure module file {files.s_mod_file}')
            sys.exit(1)
        self._mod_txt = mod_txt

        try:
            with files.s_lst_file.open('r') as f:
                lst_txt = f.read()
        except:
            print(f'{PROG_NAME}: cannot read secure listing file {files.s_lst_file}')
            sys.exit(1)
        self._lst_txt = lst_txt

    def is_secure(self, pat):
        lines = self._mod_txt.splitlines()
        is_sec = False
        for l in lines:
            m = pat.sec_re.match(l)
            if m is not None:
                is_sec = True
                break
            else:
                continue
        return is_sec

    @property
    def lst_text(self):
        return self._lst_txt


class NSCmod:
    def __init__(self, files, s_mod):
        self._s_mod = s_mod
        self._nsc_mod_file = files.nsc_mod_file
        self._nsc_mod_name = files.nsc_mod_name

    def make(self, pat):
        mlines = list()
        mlines.append(f'MODULE {self._nsc_mod_name};')
        mlines.append('(* generated, do not edit *)')
        mlines.append('IMPORT SYSTEM, Main;\n')
        lines = self._s_mod.lst_text.splitlines()
        in_proc = False
        for l in lines:
            if in_proc:
                m = pat.asm_re.match(l)
                if m is not None:
                    rel_addr = int(m.group(1))
                    # rel_addr2c = twoc4(rel_addr, 32)
                    mlines.append('(* SYSTEM.EMIT(0E97FE97FH); *) (* SG *)')
                    mlines.append('SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)')
                    mlines.append('SYSTEM.EMITH(04758H); (* bx r11 *)')
                    mlines.append(f'(*!addr_s {rel_addr} *) SYSTEM.DATA(0H); (* target address *)')
                    mlines.append(f'END {proc_name};\n')
                    in_proc = False
            else:
                m = pat.proc_begin_re.match(l)
                if m is not None:
                    exp = m.group(3)
                    if exp != "":
                        in_proc = True
                        ln = m.group(1)
                        proc_name = m.group(2)
                        mlines.append(ln)
                        mlines.append('BEGIN')
        mlines.append(f'END {self._nsc_mod_name}.')
        mlines.append('')
        mtext = '\n'.join(mlines)
        self._mtext = mtext


    def fixup(self, s_addr, pat):
        try:
            with self._nsc_mod_file.open('r', encoding='utf-8') as f:
                self._mtext = f.read()
            print(f'{PROG_NAME}: read module file {self._nsc_mod_file}')
        except:
            print(f'{PROG_NAME}: error reading module file {self._nsc_mod_file}')
            sys.exit(1)

        lines = self._mtext.splitlines()
        for l in lines:
            m = pat.data_s_re.match(l)
            if m is not None:
                data_line = m.group(0)
                prefix = m.group(1)
                rel_addr = int(m.group(2))
                abs_addr = rel_addr + s_addr + 1
                abs_addr2c = twoc4(abs_addr, 32)
                new_data_line = '{} {}'.format(prefix, f'SYSTEM.DATA(0{abs_addr2c}H); (* target address *)')
                self._mtext = self._mtext.replace(data_line, new_data_line)


    def write_mod_file(self):
        try:
            with self._nsc_mod_file.open('w', encoding='utf-8') as f:
                f.write(self._mtext)
            print(f'{PROG_NAME}: created or updated module file {self._nsc_mod_file}')
        except:
            print(f'{PROG_NAME}: error writing module file {self._nsc_mod_file}')
            sys.exit(1)


class NSmod:
    def __init__(self, files, s_mod):
        self._s_mod = s_mod
        self._ns_mod_file = files.ns_mod_file
        self._ns_mod_name = files.ns_mod_name

    def make(self, pat):
        mlines = list()
        mlines.append(f'MODULE {self._ns_mod_name};')
        mlines.append('(* generated, do not edit *)')
        mlines.append('IMPORT SYSTEM;\n')
        lines = self._s_mod.lst_text.splitlines()
        in_proc = False
        rel_addr = -10
        for l in lines:
            if in_proc:
                m = pat.asm_re.match(l)
                if m is not None:
                    asm_mnemonic = m.group(4)
                    if asm_mnemonic == 'push':
                        rel_addr = rel_addr + 16
                        # rel_addr2c = twoc4(rel_addr, 32)
                        p_regs = m.group(5)
                        p_regs = [r.strip() for r in p_regs.strip("{}").split(",")]
                        num_reg = len(p_regs)
                        addsp_opcode = f'0B0{num_reg:02X}'
                        mlines.append(f'SYSTEM.EMITH({addsp_opcode}H); (* add sp,#{num_reg * 4}, fix stack *)')
                        mlines.append('SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)')
                        mlines.append('SYSTEM.EMITH(04758H); (* bx r11 *)')
                        mlines.append('SYSTEM.ALIGN; (* word alignment *)')
                        mlines.append(f'(*!addr_nsc {rel_addr} *) SYSTEM.DATA(0H); (* target address *)')
                        mlines.append(f'END {proc_name};\n')
                        in_proc = False
            else:
                m = pat.proc_begin_re.match(l)
                if m is not None:
                    exp = m.group(3)
                    if exp != "":
                        in_proc = True
                        ln = m.group(1)
                        proc_name = m.group(2)
                        mlines.append(ln)
                        mlines.append('BEGIN')
        mlines.append(f'END {self._ns_mod_name}.')
        mlines.append('')
        mtext = '\n'.join(mlines)
        self._mtext = mtext


    def fixup(self, nsc_addr, pat):
        try:
            with self._ns_mod_file.open('r', encoding='utf-8') as f:
                self._mtext = f.read()
            print(f'{PROG_NAME}: read module file {self._ns_mod_file}')
        except:
            print(f'{PROG_NAME}: error reading module file {self._ns_mod_file}')
            sys.exit(1)

        lines = self._mtext.splitlines()
        for l in lines:
            m = pat.data_nsc_re.match(l)
            if m is not None:
                data_line = m.group(0)
                prefix = m.group(1)
                rel_addr = int(m.group(2))
                abs_addr = rel_addr + nsc_addr + 1
                abs_addr2c = twoc4(abs_addr, 32)
                new_data_line = '{} {}'.format(prefix, f'SYSTEM.DATA(0{abs_addr2c}H); (* target address *)')
                self._mtext = self._mtext.replace(data_line, new_data_line)

    def write_mod_file(self):
        try:
            with self._ns_mod_file.open("w", encoding='utf-8') as f:
                f.write(self._mtext)
            print(f'{PROG_NAME}: created or updated module file {self._ns_mod_file}')
        except:
            print(f'{PROG_NAME}: error writing module file {self._ns_mod_file}')
            sys.exit(1)


def twoc4(num, bits):
    mask = (1 << bits) - 1
    # binS = f'{(num & mask):0{bits}b}'
    # print("bin", binS, int(binS, 2))
    return '{:08X}'.format(int(f'{(num & mask):0{bits}b}', 2))


def main():

    platform = sys.platform
    if platform != MACOS and platform != WINDOWS:
        print(f'{platform} is not supported')
        sys.exit(1)

    cmds = {
        'make': MakeCmd(),
        'fixup': FixupCmd()
    }

    main_cmd = MainCmd()

    parser = commands.Parser(prog = PROG_NAME)
    parser.add_args(main_cmd)
    for cmd_name, cmd_def in cmds.items():
        parser.add_sub_command(cmd_name, cmd_def)

    args = parser.parse()
    args.func(args)

if __name__ == '__main__':
    main()
