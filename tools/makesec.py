#!/usr/bin/env python3

# For a Secure module, create NSC veneer binary and NS interface module.
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

WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'makesec'
NSC = 'NSC'
NS = 'NS'
NSC_dir = 's'
NS_dir = 'ns'


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
            'lst_file': {
                'help': 'secure listing file (.lst)',
            },
        's_abs_addr': {
                'help': 'absolute address of S (Secure) module in hexadecimal'
            },
        'nsc_abs_addr': {
                'help': 'absolute address of NSC (Non-secure Callable) image in hexadecimal'
            },
        }
    }

    def run(self, args):

        try:
            s_abs_addr = int(args.s_abs_addr, 16)
            nsc_abs_addr = int(args.nsc_abs_addr, 16)
        except:
          print(f'{PROG_NAME}: enter addresses in hexadecimal format (without \'0x\' prefix or \'H\' suffix)')
          sys.exit(1)

        files = Files(args.lst_file)
        pat = Patterns()

        s_mod = Smod(files)
        nsc_bin = NSCbin(files)
        ns_mod = NSmod(files)
        s_mod.make(s_abs_addr, nsc_abs_addr, nsc_bin, ns_mod, pat)


class Patterns:
    proc_begin_pat = r'^\s*(PROCEDURE\s*\*?\s+([\w]+)\s*(\*?).*;)'
    asm_pat = r'^\.\s+(\d+)\s+([0-9A-F]+H)\s+([0-9A-F]+H)\s+([\w\.]+)\s*(.*)'

    def __init__(self):
        self._proc_begin_re = re.compile(self.proc_begin_pat)
        self._asm_re = re.compile(self.asm_pat)

    @property
    def proc_begin_re(self):
        return self._proc_begin_re

    @property
    def asm_re(self):
        return self._asm_re


class Files:
    def __init__(self, s_lst_file):
        self._s_lst_file = Path(s_lst_file).resolve()
        self._s_mod_name = self._s_lst_file.stem.upper()

        self._nsc_dir = self._s_lst_file.parent.parent.joinpath(NSC_dir)
        self._nsc_bin_name = f'{NSC}_{self._s_mod_name}'
        self._nsc_bin_file = self._nsc_dir.joinpath(self._nsc_bin_name).with_suffix('.bin')

        self._ns_dir = self._s_lst_file.parent.parent.joinpath(NS_dir)
        self._ns_mod_name = f'{NS}_{self._s_mod_name}'
        self._ns_mod_file = self._ns_dir.joinpath(self._ns_mod_name).with_suffix('.mod')

        # print(self._s_lst_file)
        # print(self._s_mod_name)
        # print(self._nsc_bin_name)
        # print(self._nsc_bin_file)
        # print(self._ns_mod_name)
        # print(self._ns_mod_file)

        if not self._s_lst_file.is_file():
            print(f'{PROG_NAME}: cannot find secure listing file {self._s_lst_file}')
            sys.exit(1)

    @property
    def s_lst_file(self):
        return self._s_lst_file

    @property
    def s_mod_name(self):
        return self._s_mod_name

    @property
    def nsc_bin_file(self):
        return self._nsc_bin_file

    @property
    def ns_mod_file(self):
        return self._ns_mod_file

    @property
    def ns_mod_name(self):
        return self._ns_mod_name


class Smod:
    def __init__(self, files):
        try:
            with files.s_lst_file.open('r') as f:
                lst_txt = f.read()
        except:
            print(f'{PROG_NAME}: cannot read secure listing file {files.s_lst_file}')
            sys.exit(1)
        self._lst_txt = lst_txt


    def make(self, s_abs_addr, nsc_abs_addr, nsc_bin, ns_mod, pat):
        ns_mod.add_mod_begin()
        lines = self._lst_txt.splitlines()
        in_proc = False
        sg_block_addr = 0
        for l in lines:
            if in_proc:
                m = pat.asm_re.match(l)
                if m is not None:
                    asm_mnemonic = m.group(4)
                    rel_addr = int(m.group(1))
                    if asm_mnemonic == 'push':
                        p_regs = m.group(5)
                        p_regs = [r.strip() for r in p_regs.strip("{}").split(",")]
                        num_reg = len(p_regs)
                        bx_addr = nsc_abs_addr + sg_block_addr
                        sg_block_addr += 16
                        ns_mod.add_proc(num_reg, bx_addr)
                        ns_mod.add_proc_end(proc_name)
                        s_target_addr = s_abs_addr + rel_addr
                        nsc_bin.add_address(s_target_addr)
                        in_proc = False

            else:
               m = pat.proc_begin_re.match(l)
               if m is not None:
                    exp = m.group(3)
                    if exp != "": # if exported
                        in_proc = True
                        proc_sig = m.group(1)
                        proc_name = m.group(2)
                        ns_mod.add_proc_sig(proc_sig)
                        nsc_bin.add_gateway()

        ns_mod.add_mod_end()
        ns_mod.write_mod_file()
        nsc_bin.write_bin_file()


class NSCbin:
    sg_instr_h = 0xE97F
    sg_instr_l = 0xE97F
    ldr_r11_instr_h = 0xF8DF
    ldr_r11_instr_l = 0xB004
    bx_r11_instr = 0x4758
    nop_instr = 0x46C0

    def __init__(self, files):
        self._bin_file = files.nsc_bin_file
        self._buf = bytearray()

    def add_gateway(self):
        # add halfword-wise
        self._buf.extend(struct.pack('<H', self.sg_instr_h))
        self._buf.extend(struct.pack('<H', self.sg_instr_l))
        self._buf.extend(struct.pack('<H', self.ldr_r11_instr_h))
        self._buf.extend(struct.pack('<H', self.ldr_r11_instr_l))
        self._buf.extend(struct.pack('<H', self.bx_r11_instr))
        self._buf.extend(struct.pack('<H', self.nop_instr))

    def add_address(self, s_target_addr):
        s_target_addr += 1
        self._buf.extend(struct.pack('<I', s_target_addr))

    def write_bin_file(self):
        try:
            with self._bin_file.open("wb") as f:
                f.write(self._buf)
            print(f'{PROG_NAME}: created bin file {self._bin_file}')
        except:
            print(f'{PROG_NAME}: error writing bin file {self._bin_file}')
            sys.exit(1)


class NSmod:
    def __init__(self, files):
        self._mod_name = files.ns_mod_name
        self._mod_file = files.ns_mod_file
        self._mlines = list()

    def add_mod_begin(self):
        self._mlines.append(f'MODULE {self._mod_name};')
        self._mlines.append('(* generated, do not edit *)')
        self._mlines.append('IMPORT SYSTEM;\n')

    def add_proc_sig(self, proc_sig):
        self._mlines.append(proc_sig)
        self._mlines.append('BEGIN')

    def add_proc(self, num_reg, nsc_target_addr):
        addsp_opcode = f'0B0{num_reg:02X}'
        self._mlines.append(f'SYSTEM.EMITH({addsp_opcode}H); (* add sp,#{num_reg * 4}, fix stack *)')
        self._mlines.append('SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)')
        self._mlines.append('SYSTEM.EMITH(04758H); (* bx r11 *)')
        self._mlines.append('SYSTEM.ALIGN; (* word alignment *)')
        nsc_target_addr += 1
        nsc_target_addr2c = twoc4(nsc_target_addr, 32)
        self._mlines.append(f'SYSTEM.DATA(0{nsc_target_addr2c}H); (* nsc target address *)')

    def add_proc_end(self, proc_name):
        self._mlines.append(f'END {proc_name};\n')

    def add_mod_end(self):
        self._mlines.append(f'END {self._mod_name}.')
        self._mlines.append('')
        self._mtext = '\n'.join(self._mlines)
        # print(self._mtext)

    def write_mod_file(self):
        try:
            with self._mod_file.open("w", encoding='utf-8') as f:
                f.write(self._mtext)
            print(f'{PROG_NAME}: created module file {self._mod_file}')
        except:
            print(f'{PROG_NAME}: error writing module file {self._mod_file}')
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
