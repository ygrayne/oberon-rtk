#!/usr/bin/env python3

# For a Secure module, create NSC veneer binary and NS interface module.
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
        s_mod.set_mod_name(files, pat)
        nsc_bin = NSCbin(files)
        ns_mod = NSmod(files)
        ns_mod.add_mod_begin(nsc_abs_addr)
        s_mod.make_types(ns_mod, pat)
        s_mod.make_procs(s_abs_addr, nsc_abs_addr, nsc_bin, ns_mod, pat)
        ns_mod.add_mod_end()
        nsc_bin.write_bin_file()
        ns_mod.write_mod_file()

class Patterns:
    proc_sig_pat = r'^\s*(PROCEDURE\s*\*?\s+([\w]+)\s*(\*?).*;)'
    asm_pat = r'^\.\s+(\d+)\s+([0-9A-F]+H)\s+([0-9A-F]+H)\s+([\w\.]+)\s*(.*)'
    type_pat = r'^\s*TYPE'
    var_pat = r'^\s*VAR'
    proc_pat = r'^\s*PROCEDURE'
    body_begin_pat = r'^\s*BEGIN'
    mod_begin_pat = r'^\s*MODULE\s+([\w]+)\s*;'
    mod_end_pat = r'^\s*END\s+\w+\.'
    rec_begin_pat = r'^\s*\w+\s*(\*?)\s*\=\s*RECORD'
    rec_end_pat = r'^\s*END;'
    type_s_pat = r'^\s*[\w]+\s*(\*?)\s*\=\s*.*;'

    def __init__(self):
        self._proc_sig_re = re.compile(self.proc_sig_pat)
        self._asm_re = re.compile(self.asm_pat)
        self._type_re = re.compile(self.type_pat)
        self._var_re = re.compile(self.var_pat)
        self._proc_re = re.compile(self.proc_pat)
        self._body_begin_re = re.compile(self.body_begin_pat)
        self._mod_begin_re = re.compile(self.mod_begin_pat)
        self._mod_end_re = re.compile(self.mod_end_pat)
        self._rec_begin_re = re.compile(self.rec_begin_pat)
        self._rec_end_re = re.compile(self.rec_end_pat)
        self._type_s_re = re.compile(self.type_s_pat)

    @property
    def proc_sig_re(self):
        return self._proc_sig_re

    @property
    def asm_re(self):
        return self._asm_re

    @property
    def type_re(self):
        return self._type_re

    @property
    def var_re(self):
        return self._var_re

    @property
    def proc_re(self):
        return self._proc_re

    @property
    def body_begin_re(self):
        return self._body_begin_re

    @property
    def mod_begin_re(self):
        return self._mod_begin_re

    @property
    def mod_end_re(self):
        return self._mod_end_re

    @property
    def rec_begin_re(self):
        return self._rec_begin_re

    @property
    def rec_end_re(self):
        return self._rec_end_re

    @property
    def type_s_re(self):
        return self._type_s_re


class Files:
    def __init__(self, s_lst_file):
        self._s_lst_file = Path(s_lst_file).resolve()
        # self._s_mod_file = self._s_lst_file.with_suffix('.mod')
        # self._s_mod_name = self._s_lst_file.stem.upper()

        self._nsc_dir = self._s_lst_file.parent.parent.joinpath(NSC_dir)
        # self._nsc_bin_name = f'{NSC}_{self._s_mod_name}'
        # self._nsc_bin_file = self._nsc_dir.joinpath(self._nsc_bin_name).with_suffix('.bin')

        self._ns_dir = self._s_lst_file.parent.parent.joinpath(NS_dir)
        # self._ns_mod_name = f'{NS}_{self._s_mod_name}'
        # self._ns_mod_file = self._ns_dir.joinpath(self._ns_mod_name).with_suffix('.mod')

        # print(self._s_lst_file)
        # print(self._s_mod_name)
        # print(self._nsc_bin_name)
        # print(self._nsc_bin_file)
        # print(self._ns_mod_name)
        # print(self._ns_mod_file)

        if not self._s_lst_file.is_file():
            print(f'{PROG_NAME}: cannot find secure listing file {self._s_lst_file}')
            sys.exit(1)
        # if not self._s_mod_file.is_file():
        #     print(f'{PROG_NAME}: cannot find secure module file {self._s_mod_file}')
        #     sys.exit(1)

    def set_mod_name(self, mod_name):
        self._s_mod_name = mod_name
        self._nsc_bin_name = f'{NSC}_{self._s_mod_name}'
        self._nsc_bin_file = self._nsc_dir.joinpath(self._nsc_bin_name).with_suffix('.bin')
        self._ns_mod_name = f'{NS}_{self._s_mod_name}'
        self._ns_mod_file = self._ns_dir.joinpath(self._ns_mod_name).with_suffix('.mod')


    @property
    def s_lst_file(self):
        return self._s_lst_file

    # @property
    # def s_mod_file(self):
    #     return self._s_mod_file

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
                sc = StripComments(lst_txt)
                lst_txt = sc.strip()
                print(lst_txt)
        except:
            print(f'{PROG_NAME}: cannot read secure listing file {files.s_lst_file}')
            sys.exit(1)
        # try:
        #     with files.s_mod_file.open('r') as f:
        #         mod_txt = f.read()
        # except:
        #     print(f'{PROG_NAME}: cannot read secure listing file {files.s_lst_file}')
        #     sys.exit(1)
        self._lst_txt = lst_txt
        # self._mod_txt = mod_txt

    def set_mod_name(self, files, pat):
        lines = self._lst_txt.splitlines()
        for l in lines:
            print(l)
            m = pat.mod_begin_re.match(l)
            if m is not None:
                mod_name = m.group(1)
                files.set_mod_name(mod_name)
                break

    def make_types(self, ns_mod, pat):
        # ns_mod.add_mod_begin()
        lines = self._lst_txt.splitlines()
        in_type = False
        in_rec = False
        for l in lines:
            if in_type:
                if (pat.var_re.match(l) or
                    pat.proc_re.match(l) or
                    pat.body_begin_re.match(l) or
                    pat.mod_end_re.match(l)):
                    break
                # m = pat.var_re.match(l)
                # if m is not None:
                #     print('VAR')
                #     break
                # m = pat.proc_re.match(l)
                # if m is not None:
                #     print('PROC')
                #     break
                # m = pat.body_begin_re.match(l)
                # if m is not None:
                #     print('BEGIN')
                #     break
                # m = pat.mod_end_re.match(l)
                # if m is not None:
                #     print('END')
                #     break
                if in_rec:
                    ns_mod.add_line(l)
                    m = pat.rec_end_re.match(l)
                    if m is not None:
                        in_rec = False
                    continue
                else:
                    m = pat.rec_begin_re.match(l)
                    if m is not None:
                        if m.group(1) != '':
                            ns_mod.add_line(l)
                            in_rec = True
                            continue
                        else:
                            continue
                    m = pat.type_s_re.match(l)
                    if m is not None:
                        if m.group(1) != '':
                            ns_mod.add_line(l)
                            continue

            else:
                m = pat.type_re.match(l)
                if m is not None:
                    in_type = True
                    ns_mod.add_line('TYPE')
        ns_mod.add_line(' ')

    def make_procs(self, s_abs_addr, nsc_abs_addr, nsc_bin, ns_mod, pat):
        # ns_mod.add_mod_begin()
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
               m = pat.proc_sig_re.match(l)
               if m is not None:
                    exp = m.group(3)
                    if exp != "": # if exported
                        in_proc = True
                        proc_sig = m.group(1)
                        proc_name = m.group(2)
                        ns_mod.add_proc_sig(proc_sig)
                        nsc_bin.add_gateway()

        # ns_mod.add_mod_end()
        # ns_mod.write_mod_file()
        # nsc_bin.write_bin_file()


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
        self._s_mod_name = files.s_mod_name
        self._mlines = list()

    def add_mod_begin(self, nsc_abs_addr):
        self._mlines.append(f'MODULE {self._mod_name};')
        self._mlines.append('(* generated, do not edit *)')
        self._mlines.append(f'(* Secure module: {self._s_mod_name} *)')
        self._mlines.append(f'(* NSC veneer address: 0{twoc4(nsc_abs_addr, 32)}H *)')
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

    def add_line(self, line):
        self._mlines.append(f'{line.lstrip(" ")}')

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
    return '{:08X}'.format(int(f'{(num & mask):0{bits}b}', 2))


class StripComments():
    """Strip all Oberon style comments, possibly nested, from a text file."""
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
                    if add_space: source += ' '; add_space = False
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
            if token == '*)':
                self._index += 2
            else:
                self._index += 1
            return token
        else:
            raise StopIteration


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
