#!/usr/bin/env python3

"""
picoload -- Load binaries onto Raspberry Pi microcontrollers via picotool.
--
Convenience wrapper around picotool for loading Astrobe-compiled programs.
Two subcommands:
  rp2040 -- upload a single binary file to a Pico board
  rp2350 -- upload one or more binary files to a Pico2 board, with optional
            partition targeting (file:partition syntax)
Requires picotool on PATH and the board in BOOTSEL mode.
--
Usage:
    python picoload.py rp2040 <file> [-v] [-x] [--quiet]
    python picoload.py rp2350 <file>[:<part>] ... [-v] [-x] [--quiet]

Example:
    python picoload.py rp2040 SignalSync.uf2
    python picoload.py rp2350 SignalSync.uf2
    python picoload.py rp2350 app.uf2:0 data.bin:1
--
Copyright (c) 2023-2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys, re, subprocess
from pathlib import Path
import pylib.commands as commands

WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'picoload'
PICOTOOL = 'picotool'

class MainCmd(commands.Command):
    _defs = {
        'prog': PROG_NAME,
    }

    def run(self, args):
        print(f'{PROG_NAME}: use a command, type \'{PROG_NAME} -h\' for a list of commands')


class RPcmd(commands.Command):
    """Common code for all sub-commands"""
    _defs = {}


class RP2040(commands.Command):
    """'rp2040' sub-command"""
    _defs = {
        'help': 'upload a binary file to Pico',
        'pargs': {
            'bin_file': {
                'help': 'binary file (.uf2)'
            }
        },
        'oargs': {
            'quiet': {
                'flags': ['--quiet'],
                'help': 'do not show output',
                'action': 'store_true',
            },
            'reboot': {
                'flags': ['-x'],
                'help': 'reboot the device after the file is loaded',
                'action': 'store_true',
            },
            'verify': {
                'flags': ['-v'],
                'help': 'verify loaded data',
                'action': 'store_true',
            },
        }
    }

    def run(self, args):
        check_picotool();
        file = Path(args.bin_file).resolve()
        if not file.is_file():
            print(f'{PROG_NAME}: cannot find file {file}')
            sys.exit(1)
        cmd = ['picotool'] + ['load']
        if args.verify:
            cmd = cmd + ['-v']
        cmd = cmd + [str(file)]
        if args.quiet:
            res = subprocess.run(cmd, stdout=subprocess.DEVNULL)
        else:
            res = subprocess.run(cmd)
        if res.returncode != 0:
            print(f'{PROG_NAME}: \'picotool\' error upon loading the image')
            sys.exit(1)
        # reboot
        if args.reboot:
            cmd = [PICOTOOL] + ['reboot']
            if args.quiet:
                subprocess.run(cmd, stdout=subprocess.DEVNULL)
            else:
                subprocess.run(cmd)
        if res.returncode != 0:
            print(f'{PROG_NAME}: \'picotool\' error upon rebooting')


class RP2350(commands.Command):
    """'rp2350' sub-command"""
    # single colon
    _file_pat0 = (r'^([A-Za-z]:[/\\](?:[^:]+[/\\])*[^:]*' +
                    r'|[A-Za-z]:[^/\\:]+' +
                    r'|/(?:[^:]+/)*[^:]*' +
                    r'|(?:\.\.?/)?[^:]+(?:/[^:]*)*' +
                    r'|[^/:]+)(?::(.+))?$')
    # double colon
    # _file_pat1 = r'^([A-Za-z]:[/\\](?:[^:]+[/\\])*[^:]*|/(?:[^:]+/)*[^:]*|(?:\.\.?/)?[^:]+(?:/[^:]*)*|[^/:]+)(?:::(.+))?$'

    _defs = {
        'help': 'upload one or more binary files to Pico2',
        'pargs': {
            'bin_files': {
                'help': 'binary files (.uf2, .bin)',
                'nargs': '+'
            },
        },
        'oargs': {
            'quiet': {
                'flags': ['--quiet'],
                'help': 'do not show output',
                'action': 'store_true',
            },
            'reboot': {
                'flags': ['-x'],
                'help': 'reboot the device after all files are loaded',
                'action': 'store_true',
            },
            'verify': {
                'flags': ['-v'],
                'help': 'verify loaded data',
                'action': 'store_true',
            },
        }
    }

    def run(self, args):
        check_picotool();
        file_re = re.compile(self._file_pat0)
        cmds = list()
        # collect commands
        for f in args.bin_files:
            m = file_re.match(f)
            if m:
                file = m.group(1)
                part = m.group(2)
                file = Path(file).resolve()
                if not file.is_file():
                    print(f'{PROG_NAME}: cannot find file {file}')
                    sys.exit(1)
                cmd = ['picotool'] + ['load']
                if part:
                    try:
                        partInt = int(part)
                    except:
                        print(f'{PROG_NAME}: specify a partition as decimal number: \'{part}\'')
                        sys.exit(1)
                    cmd = cmd + ['-p'] + [part]
                # if file.suffix != '.uf2':
                #     if not part:
                #         print(f'{PROG_NAME}: you must specify a partition with files other than \'.uf2\': {f}')
                #         sys.exit(1)
                if args.verify:
                    cmd = cmd + ['-v']
                cmd = cmd + [str(file)]
                cmds.append(cmd)
                # print(cmd)
            else:
                print(f'{PROG_NAME}: specify files as \'file_name[:part_num]\': \'{f}\'')
                sys.exit(1)
        # execute commands
        for cmd in cmds:
            if args.quiet:
                res = subprocess.run(cmd, stdout=subprocess.DEVNULL)
            else:
                res = subprocess.run(cmd)
            if res.returncode != 0:
                print(f'{PROG_NAME}: \'picotool\' error upon loading an image')
                sys.exit(1)
        # reboot
        if args.reboot:
            cmd = [PICOTOOL] + ['reboot']
            if args.quiet:
                res = subprocess.run(cmd, stdout=subprocess.DEVNULL)
            else:
                res = subprocess.run(cmd)
            if res.returncode != 0:
                print(f'{PROG_NAME}: \'picotool\' error upon rebooting')

def check_picotool():
    try:
        subprocess.run([PICOTOOL], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except:
        print(f'{PROG_NAME}: cannot run \'picotool\'')
        sys.exit(1)

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
