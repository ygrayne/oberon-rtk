#!/usr/bin/env python3

# Declarative command definitions
# Extend argparse.Parser to process the definitions
# --
# Copyright (c) 2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

import argparse

class Command:
    _defs = {}

    @property
    def name(self):
        return self._defs['name']

    @property
    def pargs(self) -> dict:
        pargs = {}
        if 'pargs' in self._defs:
            for parg, pdef in self._defs['pargs'].items():
                pargs[parg] = {}
                for option, odef in pdef.items():
                    pargs[parg][option] = odef
        return pargs

    @property
    def oargs(self):
        oargs = {}; oflags = {}
        if 'oargs' in self._defs:
            for oarg, odef in self._defs['oargs'].items():
                oargs[oarg] = {}
                oflags[oarg] = {}
                for option, odef in odef.items():
                    if option == 'flags':
                        oflags[oarg] = ', '.join(odef)
                    else:
                        oargs[oarg][option] = odef
        return oargs, oflags

    @property
    def help(self):
        return self._defs['help']

    def errors(self, errno):
        return self._defs['errors'][errno]

    def run(self, args):
        pass

class CommandCfg(Command):
    def __init__(self, cfg):
        self._cfg = cfg

class Parser(argparse.ArgumentParser):
    def __init__(self, prog):
        super().__init__(prog)
        self._subparser = None

    def parse(self):
        return self.parse_args()

    def add_args(self, cmd_def):
        pargs = cmd_def.pargs
        if pargs is not {}:
            for parg, pdef in pargs.items():
                self.add_argument(parg, **pdef)
        oargs, oflags = cmd_def.oargs
        if oargs is not {}:
            for oarg, odef in oargs.items():
                self.add_argument(oflags[oarg], dest = oarg, **odef)

    def add_sub_command(self, cmd_name, cmd_def, cmd_run):
        if self._subparser is None:
            self._subparser = self.add_subparsers(title = 'commands')
        cmdp = self._subparser.add_parser(name = cmd_name, help = cmd_def.help)
        pargs = cmd_def.pargs
        if pargs is not {}:
            for parg, pdef in pargs.items():
                cmdp.add_argument(parg, **pdef)
        oargs, oflags = cmd_def.oargs
        if oargs is not {}:
            for oarg, odef in oargs.items():
                cmdp.add_argument(oflags[oarg], dest = oarg, **odef)
        cmdp.set_defaults(func = cmd_run)
