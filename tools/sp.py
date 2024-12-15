#!/usr/bin/env python3

# Replace the library directory search path in an Astrobe
# config .ini file with a corresponding list from a text file.
# In the text file, put one directory per line.
# Silly, yes. But the limited view inside Astrobe's dialog,
# both regarding width and height, is cumbersone for more
# complex definitions.
# --
# Copyright (c) 2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

import sys
from pathlib import Path
import pylib.commands as commands

PROG_NAME = 'sp'
MAX_PATH_ENTRIES = 10

class MainCmd(commands.Command):
    _defs = {
        'pargs': {
            'path_file': {
                'help': 'search path file (.txt)'
            },
            'config_file': {
                'help': 'config file (.ini)'
                }
            },
        }
    def run(self, args):
        path_file_name = args.path_file
        path_file = Path(path_file_name)
        self._path_file = PathFile(path_file)
        self._path_file.read()
        self._path_file.adjust()
        cfg_file_name = args.config_file
        cfg_file = Path(cfg_file_name)
        self._cfg_file = CfgFile(cfg_file)
        self._cfg_file.read()
        self._cfg_file.reverse()
        self._cfg_file.copy()
        self._cfg_file.append(self._path_file.lines)
        self._cfg_file.re_reverse()
        self._cfg_file.write()


class File:
    def __init__(self, file):
        self._file = file
        self._lines = []

    def read(self):
        if not self._file.exists():
            print("{}: cannot find {}".format(PROG_NAME, self._file))
            sys.exit(1)
        try:
            with self._file.open('r') as f:
                lines = f.readlines()
                for l in lines:
                    l = l.strip()
                    if l != '' and not l.startswith('#'):
                        self._lines.append(l)
        except:
            print("{}: cannot read {}".format(PROG_NAME, self._file))
            sys.exit(1)

        # for l in self._lines:
        #     print(l)


class PathFile(File):
    def adjust(self):
        if len(self._lines) < MAX_PATH_ENTRIES:
            for _ in range(len(self._lines), MAX_PATH_ENTRIES):
                self._lines.append('')
        else:
            for _ in range(MAX_PATH_ENTRIES, len(self._lines)):
                del self._lines[-1]

    @property
    def lines(self):
        return self._lines


class CfgFile(File):
    def reverse(self):
        self._lines_rev = reversed(self._lines)
        # for l in self._lines_rev:
        #     print(l)

    def copy(self):
        self._new_lines = []
        for l in self._lines_rev:
            if not l.startswith('LibPathName'):
                self._new_lines.append(l)
        # for l in self._new_lines:
        #     print(l)

    def append(self, lines):
        i = 0
        for l in lines:
            l = 'LibPathName' + str(i) + ' = ' + l
            self._new_lines.append(l)
            i = i + 1
        # for l in self._new_lines:
        #     print(l)

    def re_reverse(self):
        self._lines_out = reversed(self._new_lines)
        # for l in self._lines_out:
        #     print(l)

    def write(self):
        try:
            with self._file.open('w') as f:
                for l in self._lines_out:
                    print(l)
                    f.write(l + '\n')
                #f.writelines(self._lines_out)
        except:
            print("{}: cannot write {}".format(PROG_NAME, self._file))
            sys.exit(1)

def main():
    main_cmd = MainCmd()
    parser = commands.Parser(prog = PROG_NAME)
    parser.add_args(main_cmd)

    args = parser.parse()
    args.func(args)

if __name__ == '__main__':
    main()
