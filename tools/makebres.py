#!/usr/bin/env python3

# Create a plain binary Astrobe resource file from a binary file.
# --
# Supported platforms: Windows, macOS
# --
# Run python -m makebres -h for help.
# --
# Copyright (c) 2025 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import sys, struct
from pathlib import Path
import pylib.commands as commands

## constants
WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'makebres'
DATA_FILE = 'bres.res'

## commands
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
            print(f"{PROG_NAME}: cannot read {self._file}")
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

## main
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
