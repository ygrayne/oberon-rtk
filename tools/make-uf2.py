#!/usr/bin/env python3

"""
make-uf2 -- Convert Astrobe binaries to UF2 format for Raspberry Pi microcontrollers.
--
Two subcommands for each target family:
  rp2040 -- prepends a checksummed boot2 block for QSPI flash initialisation
  rp2350 -- prepends a picobin metadata block (IMAGE_DEF, vector table)
The program binary is placed at 0x10000100 in both cases. The output is a
.uf2 file that can be copied to a board in BOOTSEL mode or uploaded via picotool.
Supported platforms: Windows and macOS.
--
Usage:
    python make-uf2.py rp2040 <Prog.bin> [-v] [-b boot2_file]
    python make-uf2.py rp2350 <Prog.bin> [-v] [--ns] [--no-meta]

Example:
    python make-uf2.py rp2040 SignalSync.bin
    python make-uf2.py rp2350 SignalSync.bin
    python make-uf2.py rp2350 SignalSync.bin --ns
--
Copyright (c) 2023-2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/

The accompanying 'boot2.uf2' binary is
Copyright (c) 2019-2021 Raspberry Pi (Trading) Ltd.
SPDX-Licence-Identifier: BSD-3-Clause
"""

import sys
import struct
from pathlib import Path
import pylib.commands as commands

WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'make-uf2'
BOOT2_FILE_NAME = 'boot2.uf2'

XIP_BASE = 0x10000000

BOOT2_SIZE = 0x100 # RP2040
META_BLOCK_SIZE = 0x100 # RP2350

UF2_FAMID_RP2040 = 0xE48BFF56
UF2_FAMID_RP2350_ARM_S = 0xE48BFF59
UF2_FAMID_RP2350_ARM_NS = 0xE48BFF5B

UF2_BYTES_PER_BLOCK = 256

UF2_BLOCK_BEGIN = struct.pack("<L", 0x0A324655) # UF2\n
UF2_MAGIC_BEGIN = struct.pack("<L", 0x9E5D5157)
UF2_FLAGS       = struct.pack("<L", 0x00002000)
# UF2_ADDR: address
UF2_DATASIZE    = struct.pack("<L", UF2_BYTES_PER_BLOCK)
# UF2_BLOCKNO: block number
# UF2_NUMBLOCKS: number of blocks
# UF2_FAMID: familiy ID
UF2_MAGIC_END   = struct.pack("<L", 0x0AB16F30)

F_RP2350    = 0x10000000
F_CPU_ARM   = 0x00000000
F_CPU_RV    = 0x01000000
F_SEC_NS    = 0x00100000
F_SEC_S     = 0x00200000
F_TYPE_EXE  = 0x00010000
F_TYPE_DATA = 0x00020000
META_IMAGE_DEF = 0x0142
META_IMAGE_DEF_S  = META_IMAGE_DEF | F_RP2350 | F_CPU_ARM | F_SEC_S  | F_TYPE_EXE
META_IMAGE_DEF_NS = META_IMAGE_DEF | F_RP2350 | F_CPU_ARM | F_SEC_NS | F_TYPE_EXE


META_BLOCK_BEGIN  = struct.pack("<L", 0xFFFFDED3)
# META_IMAGE_DEF    = struct.pack("<L", 0x10210142)  # item size = 1 word
META_VECT_TABLE   = struct.pack("<L", 0x00000203)    # item size = 2 words
# META_ROLL_WIN_DELTA = struct.pack("<L", 0x00000205)  # item size = 2 words
META_LAST_ITEM    = struct.pack("<L", 0x000003FF)    # all items size = 3 words
META_LINK_SELF    = struct.pack("<L", 0x00000000)
META_BLOCK_END    = struct.pack("<L", 0xAB123579)


class MainCmd(commands.Command):
    _defs = {}

    def run(self, args):
        print(f'{PROG_NAME}: use a command, type \'{PROG_NAME} -h\' for a list of commands')


class RPcmd(commands.Command):
    """Common code for all sub-commands"""
    _defs = {}

    def _run(self, args):
        bin_file_name = args.bin_file
        bin_file = Path(bin_file_name).resolve()
        uf2_file = bin_file.with_suffix('.uf2')
        self._bin_file = BinFile(bin_file)
        self._uf2_file = UF2file(uf2_file)

    def _print_verbose(self, args):
        print(f'image file: {self._bin_file.file}')
        if hasattr(self, '_boot2_file'):
            print(f'boot2 image file: {self._boot2_file.file}')
        print(f'UF2 file: {self._uf2_file.file}')
        fam_id = args.nonsec and 'rp2350-arm-ns' or 'rp2350-arm-s'
        print(f'family ID: {fam_id}')
        if args.nometa:
            print('no meta block prepended')
        msp, entry = self._bin_file.vtable_values()
        print(f'initial main stack pointer: {msp:#x}')
        print(f'program entry address: {entry:#x}')


class RP2040(RPcmd):
    """'rp2040' sub-command"""
    _defs = {
        'help': 'create UF2 binary for RP2040/Pico',
        'pargs': {
            'bin_file': {
                'help': 'binary file (.bin)'
            }
        },
        'oargs': {
            'verbose': {
                'flags': ['-v', '--verbose'],
                'help': 'verbose, print feedback',
                'action': 'store_true',
            },
            'boot2_file': {
                'flags': ['-b'],
                'help': f'bootstage 2 file, default: {BOOT2_FILE_NAME} in installation directory'
            }
        }
    }

    def run(self, args):
        self._run(args)

        self._code_addr = XIP_BASE + BOOT2_SIZE

        if args.boot2_file:
            boot2_file = Path(args.boot2_file_name).resolve()
        else:
            boot2_file = Path(sys.argv[0]).resolve().parent.joinpath(BOOT2_FILE_NAME)
        self._boot2_file = InFile(boot2_file)

        self._bin_file.read()
        self._boot2_file.read()
        self._uf2_file.open()

        if args.verbose:
            self._print_verbose(args)

        self._uf2_file.add_boot_block(self._boot2_file.data, self._bin_file.num_blocks() + 1)
        self._uf2_file.add_prog_blocks(self._bin_file.data, self._bin_file.num_blocks() + 1, UF2_FAMID_RP2040, self._code_addr)
        self._uf2_file.close()
        print(f'{PROG_NAME}: created UF2 binary {self._uf2_file.file.name}')


class RP2350(RPcmd):
    """'rp2350' sub-command"""
    _defs = {
        'help': 'create UF2 binary for RP2350/Pico2',
        'pargs': {
            'bin_file': {
                'help': 'binary file (.bin)',
            },
        },
        'oargs': {
            'verbose': {
                'flags': ['-v', '--verbose'],
                'help': 'verbose, print feedback',
                'action': 'store_true',
            },
            'nonsec': {
                'flags': ['--ns'],
                'help': 'tag image as non-secure (\'rp2350-arm-ns\'), default: secure (\'rp2350-arm-s\')',
                'action': 'store_true'
            },
            'nometa': {
                'flags': ['--no-meta'],
                'help': f'prepend no meta data block',
                'action': 'store_true'
            },

        }
    }

    def run(self, args):
        self._run(args)

        self._bin_file.read()
        self._uf2_file.open()

        if args.verbose:
            self._print_verbose(args)

        img_addr = XIP_BASE
        vtab_addr = img_addr
        num_blocks = self._bin_file.num_blocks() + 1
        if not args.nometa:
            vtab_addr += META_BLOCK_SIZE
            if args.nonsec:
                self._uf2_file.add_meta_block(num_blocks, UF2_FAMID_RP2350_ARM_NS, META_IMAGE_DEF_NS, img_addr, vtab_addr)
            else:
                self._uf2_file.add_meta_block(num_blocks, UF2_FAMID_RP2350_ARM_S, META_IMAGE_DEF_S, img_addr, vtab_addr)
        if args.nonsec:
            self._uf2_file.add_prog_blocks(self._bin_file.data, num_blocks, UF2_FAMID_RP2350_ARM_NS, vtab_addr)
        else:
            self._uf2_file.add_prog_blocks(self._bin_file.data, num_blocks, UF2_FAMID_RP2350_ARM_S, vtab_addr)
        self._uf2_file.close()
        print(f'{PROG_NAME}: created UF2 binary {self._uf2_file.file.name}')


class InFile:
    """Input files: 'program.bin' and 'boot2.uf2'"""
    def __init__(self, file):
        self._file = file # Path()

    def read(self):
        # if not self._file.is_file():
        #     print("{}: cannot find {}".format(PROG_NAME, self._file))
        #     sys.exit(1)
        try:
            with self._file.open('rb') as bfile:
                self._data = bfile.read()
                # print(len(self._data))
        except:
            print("{}: cannot read {}".format(PROG_NAME, self._file))
            sys.exit(1)

    @property
    def file(self):
        return self._file

    @property
    def data(self):
        return self._data


class BinFile(InFile):
    """Program binary file (.bin)"""
    def __init__(self, file):
        super().__init__(file)

    def num_blocks(self):
        return (len(self._data) + UF2_BYTES_PER_BLOCK - 1) // UF2_BYTES_PER_BLOCK

    def vtable_values(self):
        msp = struct.unpack("<L", self._data[0:4])[0]
        entry = struct.unpack("<L", self._data[4:8])[0]
        return msp, entry


class UF2file:
    """Output UF2 file"""
    def __init__(self, file):
        self._file = file # Path()
        self._buf = bytes()

    @property
    def file(self):
        return self._file

    def open(self):
        try:
            self._fd = self._file.open('wb')
        except:
            print("{}: cannot create UF2 file {}".format(PROG_NAME, self._file))
            sys.exit(1)

    def close(self):
        self._fd.close()

    def add_boot_block(self, data, num_blocks):
        try:
            self._fd.write(data[0:24])
            self._fd.write(struct.pack("<L", num_blocks))
            self._fd.write(data[28:len(data)])
        except:
            print("{}: error writing boot block to UF2 file {}".format(PROG_NAME, self._file.name))
            self._fd.close()
            sys.exit(1)

    def add_meta_block(self, num_blocks, fam_id, img_def, img_addr, vtab_addr):
        try:
            self._fd.write(UF2_BLOCK_BEGIN)
            self._fd.write(UF2_MAGIC_BEGIN)
            self._fd.write(UF2_FLAGS)
            self._fd.write(struct.pack("<I", img_addr))
            self._fd.write(UF2_DATASIZE)
            self._fd.write(struct.pack("<I", 0))
            self._fd.write(struct.pack("<I", num_blocks))
            self._fd.write(struct.pack("<I", fam_id))
            self._fd.write(META_BLOCK_BEGIN)
            self._fd.write(struct.pack("<I", img_def))
            self._fd.write(META_VECT_TABLE)
            self._fd.write(struct.pack("<I", vtab_addr))
            self._fd.write(META_LAST_ITEM)
            self._fd.write(META_LINK_SELF)
            self._fd.write(META_BLOCK_END)
            for _ in range(0x3C, 0x1FC):
                self._fd.write(struct.pack("B", 0))
            self._fd.write(UF2_MAGIC_END)
        except:
            print("{}: error writing meta data block to UF2 file {}".format(PROG_NAME, self._file.name))
            self._fd.close()
            sys.exit(1)

    def add_prog_blocks(self, data, num_blocks, fam_id, code_addr):
        code_max_addr = code_addr + (num_blocks * UF2_BYTES_PER_BLOCK)
        try:
            for offs, block, addr in zip(range(0, len(data), 256), range(1, num_blocks, 1), range(code_addr, code_max_addr, 256)):
                self._fd.write(UF2_BLOCK_BEGIN)
                self._fd.write(UF2_MAGIC_BEGIN)
                self._fd.write(UF2_FLAGS)
                self._fd.write(struct.pack("<L", addr))
                self._fd.write(UF2_DATASIZE)
                self._fd.write(struct.pack("<L", block))
                self._fd.write(struct.pack("<L", num_blocks))
                self._fd.write(struct.pack("<L", fam_id))
                # print(block, num_blocks, hex(addr), hex(fam_id))
                chunk = data[offs:min(offs + 256, len(data))]
                self._fd.write(chunk)
                chunk_size = len(chunk)
                for _ in range(chunk_size, 0x1FC - 32):
                    self._fd.write(struct.pack("B", 0))
                self._fd.write(UF2_MAGIC_END)
        except:
            print(f'{PROG_NAME}: error writing program blocks to UF2 file {self._file.name}')
            self._fd.close()
            sys.exit(1)


def main():

    platform = sys.platform
    if platform != MACOS and platform != WINDOWS:
        print(f"{platform} is not supported.")
        sys.exit(1)

    cmds = {
        'rp2040': RP2040(),
        'rp2350': RP2350()
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
