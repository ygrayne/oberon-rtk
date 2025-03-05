#!/usr/bin/env python3

# Translate an Astrobe .bin file to UF2 format for Pico or Pico 2.
# Optionally copy to Pico's "virtual drive".
# --
# Supported platforms: Windows, macOS
# --
# Run python -m makeuf2 -h for help.
# Run python -m makeuf2 rp2040 -h for help with command 'rp2040'
# Run python -m makeuf2 rp2350 -h for help with command 'rp2350'
# --
# Copyright (c) 2023-2025 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

# The accompanying 'boot2.uf2' binary is
# Copyright (c) 2019-2021 Raspberry Pi (Trading) Ltd.
# SPDX-Licence-Identifier: BSD-3-Clause

import sys
import struct
import shutil
from pathlib import Path
import pylib.commands as commands

## constants
WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'makeuf2'
BOOT2_FILE_NAME = 'boot2.uf2'

DRIVE_NAME_RP2040 = 'RPI-RP2'
DRIVE_NAME_RP2350 = 'RP2350'

XIP_BASE = 0x10000000
XIP_SIZE_PICO = 0x200000
XIP_SIZE_PICO2 = 0x400000

UF2_FAMID_RP2040 = 0xE48BFF56
UF2_FAMID_RP2350_ARM_S = 0xE48BFF59

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

UF2_META_BLOCK_BEGIN  = struct.pack("<L", 0xFFFFDED3)
UF2_META_IMAGE_DEF    = struct.pack("<L", 0x10210142)  # item size = 1 word
UF2_META_VECT_TABLE   = struct.pack("<L", 0x00000203)  # item size = 2 words
UF2_META_LAST_ITEM    = struct.pack("<L", 0x000003FF)  # all items size = 3 words
UF2_META_LINK_SELF    = struct.pack("<L", 0x00000000)
UF2_META_BLOCK_END    = struct.pack("<L", 0xAB123579)

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
        print("{}: use a command, type '{} -h' for a list of commands".format(PROG_NAME, PROG_NAME))


class RPcmd(commands.Command):
    """Common code for all sub-commands"""
    _defs = {}
    _drive_name = ""

    def _run(self, args):
        bin_file_name = args.bin_file
        bin_file = Path(bin_file_name).resolve()
        uf2_file = bin_file.with_suffix('.uf2')
        self._bin_file = BinFile(bin_file)
        self._uf2_file = UF2file(uf2_file)
        try:
            flash_size = int(args.flash_size, base = 16)
        except:
            print("{}: enter flash size in hexadecimal format (with or without '0x' prefix)".format(PROG_NAME))
            sys.exit(1)
        self._prog_base_addr = XIP_BASE + 0x100
        self._prog_max_addr = XIP_BASE + flash_size

    def _get_drive(self, args):
        drive = args.drive            
        if drive is not None:
            if sys.platform == MACOS:
                drive = '/Volumes/' + drive
            if not Path(drive).exists():
                print("{}: cannot find {} ({})".format(PROG_NAME, drive, self._drive_name))
                sys.exit(1)
        else:
            if args.upload:
                drive = find_drive(self._drive_name)
                if drive != '':
                    print("{}: drive/volume {} is {}".format(PROG_NAME, self._drive_name, drive))
                    assert(Path(drive).exists())
                else:
                    print("{}: cannot find {}".format(PROG_NAME, self._drive_name))
                    sys.exit(1)
            else:
                drive = ''
        self._drive = drive

    def _print_verbose(self):
        print("bin image file: {}".format(self._bin_file.file))
        if hasattr(self, '_boot2_file'):
            print("boot2 image file: {}".format(self._boot2_file.file))
        print("UF2 file: {}".format(self._uf2_file.file))
        msp, entry = self._bin_file.vtable_values()
        print("initial main stack pointer: 0x{:x}".format(msp))
        print("program entry address: 0x{:x}".format(entry))
        print("program memory range: 0x{:x} 0x{:x}".format(self._prog_base_addr, self._prog_max_addr))


class RP2040(RPcmd):
    """'rp2040' sub-command"""
    _drive_name = DRIVE_NAME_RP2040
    _defs = {
        'help': 'create UF2 binary for RP2040/Pico, optionally upload',
        'pargs': {
            'bin_file': {
                'help': 'binary file (.bin)'
            }
        },
        'oargs': {
            'drive': {
                'flags': ['-d'],
                'help': 'upload drive or volume, eg. E: (Windows) or RPI-RP2 (macOs)',
            },
            'boot2_file': {
                'flags': ['-b'],
                'help': 'bootstage 2 file, default: {} in installation directory'.format(BOOT2_FILE_NAME)
            },
            'flash_size': {
                'flags': ['-f'],
                'help': 'flash memory size in hexadecimal, default: 0x{:x}'.format(XIP_SIZE_PICO),
                'default': hex(XIP_SIZE_PICO)
            },
            'upload': {
                'flags': ['-u'],
                'help': 'upload to \'RP2040\' (\'-d\' takes precedence)',
                'action': 'store_true'
            }
        }
    }

    def run(self, args):
        self._run(args)

        if args.boot2_file:
            boot2_file = Path(args.boot2_file_name).resolve()
        else:
            boot2_file = Path(sys.argv[0]).resolve().parent.joinpath(BOOT2_FILE_NAME)
        self._boot2_file = InFile(boot2_file)

        self._bin_file.read()
        self._boot2_file.read()
        self._uf2_file.open()

        if args.verbose:
            self._print_verbose()

        self._uf2_file.add_boot_block(self._boot2_file.data, self._bin_file.num_blocks() + 1)
        self._uf2_file.add_prog_blocks(self._bin_file.data, self._bin_file.num_blocks() + 1, UF2_FAMID_RP2040, self._prog_base_addr, self._prog_max_addr)
        self._uf2_file.close()
        print("UF2 binary {} created.".format(self._uf2_file.file.name))

        self._get_drive(args)
        if self._drive != '':
            self._uf2_file.copy(self._drive)
            print("UF2 binary {} installed on {}.".format(self._uf2_file.file.name, self._drive))


class RP2350(RPcmd):
    """'rp2350' sub-command"""
    _drive_name = DRIVE_NAME_RP2350
    _defs = {
        'help': 'create UF2 binary for RP2350/Pico2, optionally upload',
        'pargs': {
            'bin_file': {
                'help': 'binary file (.bin)'
            }
        },
        'oargs': {
            'drive': {
                'flags': ['-d'],
                'help': 'upload drive or volume, eg. E: (Windows) or RPI-RP2 (macOS)'
            },
            'flash_size': {
                'flags': ['-f'],
                'help': 'flash memory size in hexadecimal, default: 0x{:x}'.format(XIP_SIZE_PICO2),
                'default': hex(XIP_SIZE_PICO2)
            },
            'upload': {
                'flags': ['-u'],
                'help': 'upload to \'RP2350\' (\'-d\' takes precedence)',
                'action': 'store_true'
            }
        }
    }

    def run(self, args):
        self._run(args)
        self._bin_file.read()
        self._uf2_file.open()

        if args.verbose:
            self._print_verbose()

        meta_addr = XIP_BASE
        vtab_addr = XIP_BASE + 0x100
        num_blocks = self._bin_file.num_blocks() + 1
        self._uf2_file.add_meta_block(num_blocks, UF2_FAMID_RP2350_ARM_S, meta_addr, vtab_addr)
        self._uf2_file.add_prog_blocks(self._bin_file.data, num_blocks, UF2_FAMID_RP2350_ARM_S, self._prog_base_addr, self._prog_max_addr)
        self._uf2_file.close()
        print("UF2 binary {} created.".format(self._uf2_file.file.name))

        self._get_drive(args)
        if self._drive != '':
            self._uf2_file.copy(self._drive)
            print("UF2 binary {} installed on {}.".format(self._uf2_file.file.name, self._drive))


## files
class InFile:
    """Input files: 'program.bin' and 'boot2.uf2'"""
    def __init__(self, file):
        self._file = file # Path()

    def read(self):
        if not self._file.exists():
            print("{}: cannot find {}".format(PROG_NAME, self._file))
            sys.exit(1)
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

    def copy(self, dest):
        try:
            shutil.copy(self._file, dest)
        except:
            print("{}: cannot upload {} to {}.".format(PROG_NAME, self._file.name, dest))
            sys.exit(1)

    def add_boot_block(self, data, num_blocks):
        try:
            self._fd.write(data[0:24])
            self._fd.write(struct.pack("<L", num_blocks))
            self._fd.write(data[28:len(data)])
        except:
            print("{}: error writing boot block to UF2 file {}".format(PROG_NAME, self._file.name))
            self._fd.close()
            sys.exit(1)

    def add_meta_block(self, num_blocks, fam_id, meta_addr, vtab_addr):
        try:
            self._fd.write(UF2_BLOCK_BEGIN)
            self._fd.write(UF2_MAGIC_BEGIN)
            self._fd.write(UF2_FLAGS)
            self._fd.write(struct.pack("<L", meta_addr))
            self._fd.write(UF2_DATASIZE)
            self._fd.write(struct.pack("<L", 0))
            self._fd.write(struct.pack("<L", num_blocks))
            self._fd.write(struct.pack("<L", fam_id))
            self._fd.write(UF2_META_BLOCK_BEGIN)
            self._fd.write(UF2_META_IMAGE_DEF)
            self._fd.write(UF2_META_VECT_TABLE)
            self._fd.write(struct.pack("<L", vtab_addr))
            self._fd.write(UF2_META_LAST_ITEM)
            self._fd.write(UF2_META_LINK_SELF)
            self._fd.write(UF2_META_BLOCK_END)
            for _ in range(0x3C, 0x1FC):
                self._fd.write(struct.pack("B", 0))
            self._fd.write(UF2_MAGIC_END)
        except:
            print("{}: error writing meta data block to UF2 file {}".format(PROG_NAME, self._file.name))
            self._fd.close()
            sys.exit(1)

    def add_prog_blocks(self, data, num_blocks, fam_id, code_addr, code_max_addr):
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
                chunk = data[offs:min(offs + 256, len(data))]
                self._fd.write(chunk)
                chunk_size = len(chunk)
                for _ in range(chunk_size, 0x1FC - 32):
                    self._fd.write(struct.pack("B", 0))
                self._fd.write(UF2_MAGIC_END)
        except:
            print("{}: error writing program blocks to UF2 file {}.".format(PROG_NAME, self._file))
            self._fd.close()
            sys.exit(1)

## utility
# solution without additional packages to install...
from string import ascii_uppercase
import subprocess

def find_drive(drive_name):
    platform = sys.platform
    if platform == WINDOWS:
        for drive_letter in ascii_uppercase:
            drive_id = drive_letter + ':'
            if Path(drive_id).exists():
                v = subprocess.check_output(['cmd', '/c vol ' + drive_id])
                if drive_name in str(v):
                    return drive_id
        return ''
    elif platform == MACOS:
        drive_id = Path('/Volumes/' + drive_name)
        if drive_id.exists():
            return drive_id
        else:
            return ''
    else:
        raise AssertionError    

## main
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
