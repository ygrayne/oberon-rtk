#!/usr/bin/env python3

"""
gen-bin-res -- Create a binary resource file from a binary file.
--
Converts any binary file into an Astrobe binary resource file that
can be linked into an Oberon program and read at runtime using the
BinRes library module. The output contains a 4-byte little-endian
size header, the binary data, and zero-padding to 4-byte alignment.
--
Usage:
    python gen-bin-res.py <bin_file> [-o <rsrc_file>]

Example:
    python gen-bin-res.py rgb_blink.bin
    python gen-bin-res.py rgb_blink.bin -o IceData.res
--
Copyright (c) 2025-2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys, struct
from pathlib import Path
import pylib.commands as commands

WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'gen-bin-res'
DATA_FILE = 'bres.res'

class MainCmd(commands.Command):
    _defs = {
        'pargs': {
            'bin_file': {
                'help': 'binary file',
            },
        },
        'oargs': {
            'rsrc_file': {
                'flags': ['-o'],
                'help': f'binary resource file (default: {DATA_FILE})',
            }
        }
    }

    def run(self, args):

        if args.rsrc_file is not None: rsrc_file = args.rsrc_file
        else: rsrc_file = DATA_FILE

        bin_f = Path(args.bin_file).resolve()
        if not bin_f.is_file():
            print(f'{PROG_NAME}: cannot find binary file {bin_f}')
            sys.exit(1)

        bin_file = BinFile(bin_f)
        rsrc_file = RsrcFile(rsrc_file, bin_file)
        rsrc_file.open()
        rsrc_file.write()


class BinFile:

    def __init__(self, bin_file): # Path
        # bin_file exists, tested by caller
        try:
            with bin_file.open('br') as f:
                data = f.read()
        except:
            print(f"{PROG_NAME}: cannot read {bin_file}")
            sys.exit(1)
        self._data = data

    @property
    def data(self):
        return self._data

    @property
    def size(self):
        return len(self._data)


class RsrcFile:

    def __init__(self, file_name, bin_file):
        self._file = Path(file_name).resolve()
        self._bin_file = bin_file

    def open(self):
        try:
            self._fd = self._file.open('wb')
        except:
            print(f'{PROG_NAME}: cannot create resource file {self._file}')
            sys.exit(1)

    def write(self):
        size = self._bin_file.size
        padding = size % 4
        try:
            with self._fd as f:
                f.write(struct.pack('<L', size))
                f.write(self._bin_file.data)
                for i in range(padding):
                    f.write(struct.pack('B', 0))
        except:
            print(f'{PROG_NAME}: error writing resource file {self._file}')
            sys.exit(1)

def main():

    platform = sys.platform
    if platform != MACOS and platform != WINDOWS:
        print(f'{platform} is not supported')
        sys.exit(1)

    main_cmd = MainCmd()

    parser = commands.Parser(prog = PROG_NAME)
    parser.add_args(main_cmd)
    # for cmd_name, cmd_def in cmds.items():
    #     parser.add_sub_command(cmd_name, cmd_def)

    args = parser.parse()
    args.func(args)

if __name__ == '__main__':
    main()
