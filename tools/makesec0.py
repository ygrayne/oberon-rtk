#!/usr/bin/env python3

# Create and update NSC and NS modules to call Secure code
# from Non-secure code.
# Proof-of-concept, ugly code
# --
# Supported platforms: Windows, macOS
# --
# Run python -m makesec -h for help.
# --
# Copyright (c) 2025 Gray, gray@graraven.org
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
            'lst_file': {
                'help': 'secure module listing file (.lst)',
            },
        },
    }

    def run(self, args):

        lst_f = Path(args.lst_file).resolve()
        if not lst_f.is_file():
            print(f'{PROG_NAME}: cannot find secure listing file {lst_f}')
            sys.exit(1)

        lst_file = LstFile(lst_f)
        nsc_file = NSCmod(lst_file)
        nsc_file.make()
        nsc_file.write_file()
        ns_file = NSmod(lst_file)
        ns_file.make()
        ns_file.write_file()


class FixupCmd(commands.Command):
    _defs = {
        'help': '',
        'pargs': {
            'lst_file': {
                'help': 'secure module listing file (.lst)',
            },
            's_addr': {
                'help': 'absolute address of S module in hexadecimal'
            },
            'nsc_addr': {
                'help': 'absolute address of NSC module in hexadecimal'
            },
            'ns_addr': {
                'help': 'absolute address of NS module in hexadecimal'
            },
        },
    }

    def run(self, args):

        lst_f = Path(args.lst_file).resolve()
        if not lst_f.is_file():
            print(f'{PROG_NAME}: cannot find secure listing file {lst_f}')
            sys.exit(1)

        try:
            s_addr = int(args.s_addr, 16)
            nsc_addr = int(args.nsc_addr, 16)
            ns_addr = int(args.ns_addr, 16)
        except:
          print(f'{PROG_NAME}: enter addresses in hexadecimal format (with or without \'0x\' prefix)')
          sys.exit(1)

        lst_file = LstFile(lst_f)
        nsc_file = NSCmod(lst_file)
        nsc_file.fixup(s_addr, nsc_addr)
        nsc_file.write_file()
        ns_file = NSmod(lst_file)
        ns_file.fixup(nsc_addr, ns_addr)
        ns_file.write_file()


## files and modules
class LstFile:

    def __init__(self, lst_f): # Path
        # lst_f exists, tested by caller
        try:
            with lst_f.open('r') as f:
                text = f.read()
        except:
            print(f'{PROG_NAME}: cannot read {lst_f}')
            sys.exit(1)
        self._text = text
        self._mod_name = lst_f.stem.upper()

    @property
    def text(self):
        return self._text

    @property
    def mod_name(self):
        return self._mod_name


def twoc4(num, bits):
    """2-complement in hex notation, as string"""
    mask = (1 << bits) - 1
    # binS = f'{(num & mask):0{bits}b}'
    # print("bin", binS, int(binS, 2))
    return '{:03X}'.format(int(f'{(num & mask):0{bits}b}', 2))


class NSCmod:
    proc_begin_pat = r'^\s*(\(\*=\s*NSC\s*\*\)\s*PROCEDURE\*?\s*([\w]+).*;)'
    asm_pat = r'^\.\s+(\d+)\s+([0-9A-F]+H)\s+([0-9A-F]+H)\s+([\w\.]+)\s*(.*)'
    emit_pat = r'^\s*(\(\*=\s*B\s*(\d+)\s*\*\))\s*SYSTEM.EMITH.*'

    def __init__(self, lst_file_sec):
        self._lst_file_sec = lst_file_sec
        self._mod_name = f'{NSC}_{lst_file_sec.mod_name}'
        self._mod_file_name = f'{NSC}_{lst_file_sec.mod_name}.mod'
        self._mod_imp_name = f'{lst_file_sec.mod_name}'
        # print("mod name", self._mod_name)
        # print("file name", self._file_name)
        self._mod_file = Path(self._mod_file_name).resolve().parent.parent.joinpath(NSC_dir).joinpath(self._mod_file_name)
        self._lst_file = self._mod_file.with_suffix('.lst')
        # print("file", self._lst_file)

    def make(self):
        proc_begin_re = re.compile(self.proc_begin_pat)
        asm_re = re.compile(self.asm_pat)
        mlines = list()
        mlines.append(f'MODULE {self._mod_name};')
        mlines.append(f'(* generated, do not edit *)')
        # mlines.append(f'IMPORT SYSTEM, {self._lst_file_sec.mod_name};')
        mlines.append(f'IMPORT SYSTEM, Main;')
        lines = self._lst_file_sec.text.splitlines()
        in_proc = False
        push = False
        for l in lines:
            ln = list()
            m = proc_begin_re.match(l)
            if m is not None:
                in_proc = True
                # print(l)
                ln.append(m.group(1))
                proc_name = m.group(2)
                # print("proc", proc_name)
                ln = "".join(ln)
                mlines.append(ln)
                mlines.append("BEGIN")
                mlines.append("(* SYSTEM.EMIT(0E97FE97FH); *) (* SG *)")
                continue
            if in_proc:
                m = asm_re.match(l)
                if m is not None:
                    # print(l)
                    rel_addr = int(m.group(1))
                    # abs_addr = int(m.group(2)[:-1], 16)
                    # op_code = int(m.group(3)[:-1], 16)
                    asm_mnemonic = m.group(4)
                    # print(rel_addr, hex(abs_addr), hex(op_code), asm_mnemonic)
                    # if asm_mnemonic == 'push':
                    #     push = True
                    #     continue
                    # else:
                    #     if push and asm_mnemonic == 'sub':
                    #         push = False
                    #         continue
                    addr = rel_addr
                    in_proc = False
                    mlines.append(f'(*= B {addr} *) SYSTEM.EMITH(0E000H)')
                    ln.append(f'END {proc_name};')
                    ln = "".join(ln)
                    mlines.append(ln)
                    continue
            else:
                continue
        mlines.append(f'END {self._mod_name}.')
        mlines.append(" ")
        mtext = '\n'.join(mlines)
        self._mtext = mtext
        # print(mtext)


    def fixup(self, s_addr, nsc_addr):
        emit_re = re.compile(self.emit_pat)
        asm_re = re.compile(self.asm_pat)

        try:
            with self._lst_file.open('r', encoding='utf-8') as f:
                self._ltext = f.read()
            print(f'{PROG_NAME}: read listing file {self._lst_file}')
        except:
            print(f'{PROG_NAME}: error reading listing file {self._lst_file}')
            sys.exit(1)

        try:
            with self._mod_file.open('r', encoding='utf-8') as f:
                self._mtext = f.read()
            print(f'{PROG_NAME}: read module file {self._mod_file}')
        except:
            print(f'{PROG_NAME}: error reading module file {self._mod_file}')
            sys.exit(1)

        lines = self._ltext.splitlines()
        in_emit = False
        for l in lines:
            # print(l)
            m = emit_re.match(l)
            if m is not None:
                emit_line = m.group(0)
                emit_prefix = m.group(1)
                s_rel_addr = int(m.group(2))
                s_abs_addr = s_rel_addr + s_addr
                in_emit = True
                continue
            if in_emit:
                m = asm_re.match(l)
                if m is not None:
                    nsc_rel_addr = int(m.group(1))
                    nsc_abs_addr = nsc_rel_addr + nsc_addr
                    # print("nsc", hex(nsc_rel_addr), hex(nsc_abs_addr))
                    offset = s_abs_addr - nsc_abs_addr
                    offset = (offset - 4) // 2
                    offset2c = twoc4(offset, 11)
                    # print("o", offset, offset2c, f'{offset2c}H')
                    offsetH = f'{offset2c}H'
                    emit_opcode = f'0E{offsetH}'
                    new_emit_line = '{} {}'.format(emit_prefix, f'SYSTEM.EMITH({emit_opcode})')
                    self._mtext = self._mtext.replace(emit_line, new_emit_line)
                    in_emit = False
                    continue
        # print(self._mtext)


    def write_file(self):
        try:
            with self._mod_file.open('w', encoding='utf-8') as f:
                f.write(self._mtext)
            print(f'{PROG_NAME}: created or updated module file {self._mod_file}')
        except:
            print(f'{PROG_NAME}: error writing module file {self._mod_file}')
            sys.exit(1)


class NSmod:
    proc_begin_pat = r'^\s*(\(\*=\s*NSC\s*\*\)\s*PROCEDURE\*?\s*([\w]+).*;)'
    asm_pat = r'^\.\s+(\d+)\s+([0-9A-F]+H)\s+([0-9A-F]+H)\s+([\w\.]+)\s*(.*)'
    emit_pat = r'^\s*(\(\*=\s*B\s*(\d+)\s*\*\))\s*SYSTEM.EMITH.*'

    def __init__(self, lst_file_sec):
        self._lst_file_sec = lst_file_sec
        self._mod_name = f'{NS}_{lst_file_sec.mod_name}'
        self._mod_imp_name = f'{NSC}_{lst_file_sec.mod_name}'
        self._mod_file_name = f'{NS}_{lst_file_sec.mod_name}.mod'
        self._mod_file = Path(self._mod_file_name).resolve().parent.parent.joinpath(NS_dir).joinpath(self._mod_file_name)
        self._lst_file = self._mod_file.with_suffix('.lst')
        print("file", self._lst_file)

    def make(self):
        proc_begin_re = re.compile(self.proc_begin_pat)
        asm_re = re.compile(self.asm_pat)
        mlines = list()
        mlines.append(f'MODULE {self._mod_name};')
        mlines.append(f'(* generated, do not edit *)')
        # mlines.append(f'IMPORT SYSTEM, {self._mod_imp_name};')
        mlines.append(f'IMPORT SYSTEM;')
        lines = self._lst_file_sec.text.splitlines()
        in_proc = False
        push = False
        addr = -2
        for l in lines:
            ln = list()
            m = proc_begin_re.match(l)
            if m is not None:
                in_proc = True
                # print(l)
                ln.append(m.group(1))
                proc_name = m.group(2)
                ln = "".join(ln)
                mlines.append(ln)
                mlines.append("BEGIN")
                continue
            if in_proc:
                m = asm_re.match(l)
                if m is not None:
                    asm_mnemonic = m.group(4)
                    if asm_mnemonic == 'push':
                        p_regs = m.group(5)
                        p_regs = [r.strip() for r in p_regs.strip("{}").split(",")]
                        # print("pregs2", p_regs, len(p_regs))
                        num_reg = len(p_regs)
                        addsp_opcode = f'0B0{num_reg:02X}'
                        # print(addsp_opcode)
                        mlines.append(f'SYSTEM.EMITH({addsp_opcode}H); (* add sp,#{num_reg * 4}, fix stack *)')
                        addr = addr + 8
                        continue
                    in_proc = False
                    mlines.append(f'(*= B {addr} *) SYSTEM.EMITH(0E000H)')
                    ln.append(f'END {proc_name};')
                    # ln.append(m.group(1))
                    ln = "".join(ln)
                    mlines.append(ln)
                    continue
            else:
                continue
        mlines.append(f'END {self._mod_name}.')
        mlines.append("")
        mtext = '\n'.join(mlines)
        self._mtext = mtext
        # print(mtext)


    def fixup(self, nsc_addr, ns_addr):
        emit_re = re.compile(self.emit_pat)
        asm_re = re.compile(self.asm_pat)

        try:
            with self._lst_file.open('r', encoding='utf-8') as f:
                self._ltext = f.read()
            print(f'{PROG_NAME}: read listing file {self._lst_file}')
        except:
            print(f'{PROG_NAME}: error reading listing file {self._lst_file}')
            sys.exit(1)

        try:
            with self._mod_file.open('r', encoding='utf-8') as f:
                self._mtext = f.read()
            print(f'{PROG_NAME}: read module file {self._mod_file}')
        except:
            print(f'{PROG_NAME}: error reading module file {self._mod_file}')
            sys.exit(1)

        lines = self._ltext.splitlines()
        in_emit = False
        for l in lines:
            # print(l)
            m = emit_re.match(l)
            if m is not None:
                emit_line = m.group(0)
                emit_prefix = m.group(1)
                nsc_rel_addr = int(m.group(2))
                nsc_abs_addr = nsc_rel_addr + nsc_addr
                in_emit = True
                continue
            if in_emit:
                m = asm_re.match(l)
                if m is not None:
                    ns_rel_addr = int(m.group(1))
                    ns_abs_addr = ns_rel_addr + ns_addr
                    offset = nsc_abs_addr - ns_abs_addr
                    offset = (offset - 4) // 2
                    offset2c = twoc4(offset, 11)
                    offsetH = f'{offset2c}H'
                    emit_opcode = f'0E{offsetH}'
                    new_emit_line = '{} {}'.format(emit_prefix, f'SYSTEM.EMITH({emit_opcode})')
                    self._mtext = self._mtext.replace(emit_line, new_emit_line)
                    in_emit = False
                    continue
        # print(self._mtext)


    def write_file(self):
        try:
            with self._mod_file.open("w", encoding='utf-8') as f:
                f.write(self._mtext)
            print(f'{PROG_NAME}: created or updated module file {self._mod_file}')
        except:
            print(f'{PROG_NAME}: error writing module file {self._mod_file}')
            sys.exit(1)


## main
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
