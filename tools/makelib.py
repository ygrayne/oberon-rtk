#!/usr/bin/env python3

# Create and maintain a program-local framework library.
# --
# Supported platforms: Windows, macOS
# --
# Run python -m makelib -h for help.
# --
# Copyright (c) 2025 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import sys, stat, re, os
import shutil
from pathlib import Path
import pylib.commands as commands

## constants
WINDOWS = 'win32'
MACOS = 'darwin'

PROG_NAME = 'makelib'
LIB_DIR = 'rtk-lib'
SKIP_DIR = 'ignored'
BUILD_MOD = 'Build.mod'
BOOT2_BIN = 'boot2.bin'


## commands
class MainCmd(commands.Command):

    def run(self, args):
        print(f"{PROG_NAME}: use a command, type '{PROG_NAME} -h' for a list of commands.")


class UpdateCmd(commands.Command):
    _defs = {
        'help': "update local framework library directory",
        'pargs': {
            'cfg_file': {
                'help': 'config file name (.ini)',
            },
            'mod_file': {
                'help': 'module file name (.mod)'
            }
        },
        'oargs': {
            'avar': {
                'flags': ['-f'],
                'help': 'Astrobe search path variable value (default: none)',
            },
            'libdir': {
                'flags': ['-l'],
                'help': f'name of framework library directory (default: {LIB_DIR})'
            },
            'all': {
                'flags': ['-a'],
                'help': f'copy all library modules, sans the customised ones',
                'action': 'store_true',
            },
            'pat': {
                'flags': ['-p'],
                'help': f'file path pattern to filter included module files'
            },
            'verbose': {
                'flags': ['-v'],
                'help': 'verbose, print feedback (lots!)',
                'action': 'store_true',
            }
        }

    }

    def run(self, args):

        if args.avar is not None: avar = args.avar
        else: avar = ''
        if args.libdir is not None: libdir = args.libdir
        else: libdir = LIB_DIR
        if args.pat is not None: file_pat = args.pat
        else: file_pat = ''

        # ensure module file exists
        mod_f = Path(args.mod_file).resolve()
        if not mod_f.is_file():
            print(f'{PROG_NAME}: cannot find program module file {mod_f}')
            sys.exit(1)

        # curent working dir is parent of module file
        cwd = mod_f.parent

        # check if Astrobe path variable is a valid directory
        if avar != '':
            if not Path(avar).is_dir():
                print(f'{PROG_NAME}: Astrobe search path variable {avar} is not an existing directory')
                sys.exit(1)

        # look for config file
        # absolute file path wins, then look
        # - in current project dir, then
        # - using Astrobe search path var
        # ensure cfg file exists
        cfg_f = Path(args.cfg_file)
        if not cfg_f.is_absolute():
            cfg_f = cwd.joinpath(args.cfg_file) # look in project dir
            if not cfg_f.is_file():
                cfg_f = Path(avar).joinpath(args.cfg_file) # look using Astrobe variable
        if not cfg_f.is_file():
            print(f'{PROG_NAME}: cannot find config file {args.cfg_file}')
            sys.exit(1)

        # check if Astrobe path variable is a valid directory
        if avar != '':
            if not Path(avar).is_dir():
                print(f'{PROG_NAME}: Astrobe search path variable {avar} is not an existing directory')
                sys.exit(1)

        # convert relative library dir to absolute if necessary
        # create library dir if necessary
        # cannnot overwrite an existing file or link with the same name
        libdir = Path(libdir)
        if not libdir.is_absolute():
            libdir = cwd.joinpath(libdir)
        if not libdir.exists() or libdir.is_dir():
            libdir.mkdir(exist_ok = True)
        else:
            print(f'{PROG_NAME}: a file {libdir} exists, cannot create directory')
            sys.exit(1)

        # create config and module objects
        cfg_file = CfgFile(cfg_f, cwd, libdir, avar)
        mod_file = ModFile(mod_f, cfg_file)

        # ensure module is a program main module
        if not 'Main.mod' in mod_file.imp_filenames:
            print(f'{PROG_NAME}: {mod_file.name} is not a program main module, must import \'Main\'')
            sys.exit(1)

        if args.verbose:
            print("raw search path strings from config file:")
            for s in reversed(cfg_file.path_strings):
                print(f"  {s}")
            print("resolved search path directories:")
            for s in cfg_file.path_directories:
                print(f"  {s}")

        if not libdir in cfg_file.path_directories:
            print(f"{PROG_NAME}: framework library directory {libdir} not found in config file (\'-l\')")
            if libdir.is_dir():
                try: libdir.rmdir()
                except: pass
            sys.exit(1)

        if not args.all:
            # collector lists for imports
            all_imp_files = [] # collect all imports as full file path
            lib_imp_files = [] # collect framework lib imports as full file path
            skip_lib_files = [] # collect double framework lib files
            all_lib_names = [] # collect framework lib file names
            # recursively get all imports
            mod_file.get_imports(all_imp_files, lib_imp_files, skip_lib_files, all_lib_names)
            # assign for copying and stuff
            lib_copy_files = lib_imp_files
            lib_copy_skip_files = skip_lib_files
        else:
            # collect all framework modules as full file path
            # omit duplicates deeper down in library hierarchy
            # collector lists
            all_lib_files = []
            skip_lib_files = []
            # get the files
            cfg_file.get_all_lib_files(all_lib_files, skip_lib_files)
            # assign for copying and stuff
            lib_copy_files = all_lib_files
            lib_copy_skip_files = skip_lib_files

        # handle that pesky binary boot2 file for RP2040
        boot_file, boot_file_copy = cfg_file.find_boot_file()
        if boot_file_copy:
            lib_copy_files.append(boot_file_copy)

        # copy selected module files to libdir
        # overwrites any changes to the local lib by design
        # in general, the local lib modules are not be changed
        # but this allows to experiment with local lib, then reverse on update
        lib_imp_names = []
        existing_files = []
        added_files = []
        lib_copy_files0 = []
        # apply file path pattern
        for f in lib_copy_files:
            if file_pat == '':
                lib_copy_files0.append(f)
            else:
                if file_pat in str(f):
                    lib_copy_files0.append(f)
        for f in lib_copy_files0:
            # housekeeping
            lib_f = libdir.joinpath(f.name)
            if lib_f.is_file():
                existing_files.append(lib_f)
                if lib_f.suffix == '.bin': # boot2 file is read-only
                    lib_f.chmod(stat.S_IWRITE) # must be writable to overwrite
            else:
                added_files.append(f)
            # copy
            try:
                shutil.copy(f, lib_f) # copy contents
                shutil.copystat(f, lib_f) # copy modification date etc.
                lib_f.with_suffix('.arm').unlink(missing_ok = True) # delete to force compilation
            except:
                print(f'{PROG_NAME}: cannot copy {f} to {libdir}')
                sys.exit(1)
            # keep module file names for removing unused files, below
            lib_imp_names.append(f.stem)


        # keep ignored module files in sub-dir of libdir
        # empty ignored dir
        skip_dir = libdir.joinpath(SKIP_DIR)
        if skip_dir.is_dir():
            for f in skip_dir.iterdir():
                if f.is_file():
                    f.unlink(missing_ok = True)
            # skip_dir.rmdir()
            try: skip_dir.rmdir()
            except: pass

        skipped_files = []
        if lib_copy_skip_files != []:
            skip_dir.mkdir(exist_ok = True)
            for f in lib_copy_skip_files:
                skip_f = skip_dir.joinpath(f.name)
                if skip_f.is_file(): # make file name unique
                    skip_f = skip_f.with_name(f'{f.stem}-{k}{f.suffix}')
                skipped_files.append(f)
                try:
                    shutil.copy(f, skip_f)
                    shutil.copystat(f, skip_f)
                except:
                    print(f'{PROG_NAME}: cannot copy {f} to {skip_dir}')
                    sys.exit(1)

        # remove any unused files in libdir
        removed_files = []
        for f in libdir.iterdir():
            if not f.stem in lib_imp_names:
                if f.is_file():
                    if f.suffix == '.bin': # boot file is read-only
                        f.chmod(stat.S_IWRITE)
                    f.unlink(missing_ok = True)
                    removed_files.append(f)

        if args.verbose:
            if len(existing_files) > 0:
                print(f'modules updated in {cwd.name}{os.sep}{libdir.name}:')
                for i, f in enumerate(existing_files):
                    print(f"  = {i:3d} {f.name}")
            if len(added_files) > 0:
                print(f'modules added to {cwd.name}{os.sep}{libdir.name}:')
                for i, f in enumerate(added_files):
                    print(f"  + {i:3d} {f}")
            if len(removed_files):
                print(f'files removed from {cwd.name}{os.sep}{libdir.name}:')
                for i, f in enumerate(removed_files):
                    print(f"  - {i:3d} {f.name}")
            if len(skipped_files):
                print(f'modules ignored, see {cwd.name}{os.sep}{libdir.name}{os.sep}{skip_dir.name}:')
                for i, f in enumerate(skipped_files):
                    print(f"  > {i:3d} {f}")

        # non-verbose output
        removed_modules = []
        for f in removed_files:
            if f.suffix == '.mod' or f.name == BOOT2_BIN:
                removed_modules.append(f)
        if args.all: all_val = 'true'
        else: all_val = 'false'
        if file_pat == '': file_pat = 'none'
        print(f"program module: {mod_f}")
        print(f"config file: {cfg_f}")
        print(f"Astrobe var: {avar}")
        print(f"file pattern: {file_pat}")
        print(f"'all' option: {all_val}")
        print(f'project lib: {cwd.name}{os.sep}{libdir.name}')
        print(f'modules updated: {len(existing_files):3d}')
        print(f'modules added:   {len(added_files):3d}')
        print(f'modules removed: {len(removed_modules):3d}')
        print(f'files removed:   {len(removed_files):3d}')
        print(f'modules ignored: {len(skipped_files):3d}')


class CleanCmd(commands.Command):
    _defs = {
        'help': 'clean local module library directory',
        'pargs': {
            'mod_file': {
                'help': 'module file name (.mod)'
            }
        },
        'oargs': {
            'libdir': {
                'flags': ['-l'],
                'help': f'name of framework library directory (default: {LIB_DIR})'
            },
            'deep': {
                'flags': ['-d'],
                'help': 'deep cleaning, including all symbol files',
                'action': 'store_true',

            },
            'verbose': {
                'flags': ['-v'],
                'help': 'verbose, print feedback',
                'action': 'store_true',
            }
        }
    }

    def run(self, args):

        rm_sfx = ['.arm', '.lst']

        if args.libdir is not None: libdir = args.libdir
        else: libdir = LIB_DIR

        # ensure module file exists
        mod_f = Path(args.mod_file).resolve()
        if not mod_f.is_file():
            print(f'{PROG_NAME}: cannot find {mod_f}')
            sys.exit(1)

        # curent working dir is parent of module file
        cwd = mod_f.parent

        # get valid libdir
        libdir = Path(libdir)
        if not libdir.is_absolute():
            libdir = cwd.joinpath(libdir)
        if not libdir.is_dir():
            print(f'{PROG_NAME}: cannot find {libdir}')
            sys.exit(1)

        rmf = []
        for f in libdir.iterdir():
            if f.is_file():
                if f.suffix in rm_sfx:
                    f.unlink()
                    rmf.append(f)
                if f.suffix == '.smb':
                    if f.with_suffix('.mod').is_file():
                        if args.deep:
                            f.unlink()
                            rmf.append(f)
                    else:
                        f.unlink()
                        rmf.append(f)
        if len(rmf) > 0 and args.verbose:
            print("removed files:")
            for i, f in enumerate(rmf):
                print(f"  - {i} {f}")

        # non verbose output
        print(f'files removed: {len(rmf)}')

## Files

class ModFile:
    """Oberon module file"""

    def __init__(self, mod_file, cfg_file): # Path
        self._mod_file = mod_file # exists, tested by caller
        self._cfg_file = cfg_file # exists, tested by caller

        try:
            with self._mod_file.open('r', encoding='utf-8') as f:
                text = f.read()
        except:
            print(f"{PROG_NAME}: cannot read {self._mod_file}")
            sys.exit(1)

        self._text = StripComments(text).strip() # comments trip up regex
        self._extract_imp_filenames()
        self._find_imp_files() # create self._lib_imp_files, self._all_imp_files

    @property
    def name(self):
        return self._mod_file.name

    @property
    def imp_filenames(self):
        return self._imp_filenames


    def get_imports(self, all_imp_files, lib_imp_files, skip_lib_files, skip_lib_names):
        """The recursive imports collector."""

        # collect library import files
        for f in self._lib_imp_files:
            if not f in lib_imp_files:
                lib_imp_files.append(f)

        # collect all import files
        # drive recursion
        for f in self._all_imp_files:
            if not f in all_imp_files:
                all_imp_files.append(f)
                skip_lib_names.append(f.name)
                mod_file = ModFile(f, self._cfg_file)
                mod_file.get_imports(all_imp_files, lib_imp_files, skip_lib_files, skip_lib_names)
            else:
                if f.name in skip_lib_names:
                    if not f in all_imp_files:
                        if not f in skip_lib_files:
                            skip_lib_files.append(f)


    def _extract_imp_filenames(self):
        """Get module file names from IMPORT list."""

        # captures IMPORTs as one string
        imp_pat = r'\bIMPORT\s+([a-zA-Z][\s\w,:=]+?);'

        imp_filenames = []
        imp_re = re.compile(imp_pat)
        m = imp_re.search(self._text)
        if m is not None:
            name_string = m.group(1)
            imp_names0 = name_string.split(',')
            imp_names0 = [name.strip() for name in imp_names0]
            for name in imp_names0:
                if name != 'SYSTEM':
                    if ":=" in name:
                        n = name.split(':=')
                        imp_filenames.append(f'{n[1].strip()}.mod')
                    else:
                        imp_filenames.append(f'{name}.mod')

        self._imp_filenames = imp_filenames


    def _find_imp_files(self):
        """Find imported module files top->down the search path."""
        self._all_imp_files = [] # all imported module files as Path
        self._lib_imp_files = [] # module files imported from library as Path
        for f in self._imp_filenames:
            imp_file, lib_imp_file = self._cfg_file.find_mod_file(f, self._mod_file)
            self._all_imp_files.append(imp_file)
            # lib_imp_file = False if f not imported from library
            if lib_imp_file:
                self._lib_imp_files.append(imp_file)

class CfgFile:
    """Astrobe config file"""

    def __init__(self, cfg_file, cwd, libdir, avar): # Path
        self._cfg_file = cfg_file # exists, tested by caller

        try:
            with self._cfg_file.open('r', encoding='utf-8') as f:
                self._text = f.read()
        except:
            print(f'{PROG_NAME}: cannot read {self._cfg_file}')
            sys.exit(1)

        self._cwd = cwd
        self._libdir = libdir
        self._extract_path_strings()
        self._create_valid_search_path(avar)

    @property
    def path_strings(self):
        return self._search_path_strings

    @property
    def path_directories(self):
        return self._path_seg

    def _extract_path_strings(self):
        """Only extract the search path from cfg file."""

        # captures LibPathName entries
        path_pat = r'^LibPathName\d+\s+=\s+(.+)'
        path_re = re.compile(path_pat)

        lines = self._text.splitlines()
        sps = []
        for l in lines:
            m = path_re.match(l)
            if m is not None:
                sps.append(m.group(1))

        self._search_path_strings = sps # list of strings


    def _create_valid_search_path(self, avar_val):
        """ Create a list of valid absolute search directories from search path.
            Relative earch dir specs are only resolved with respect to the project directory.
        """

        # captures 'AstrobeRP2040' etc. variables
        avar_pat = r'(^[%]Astrobe[\w\d]+[%])(.+)'
        avar_re = re.compile(avar_pat)

        path_seg = []
        avar_name = ''
        path_seg.append(self._cwd)
        for sps in reversed(self._search_path_strings):
            m = avar_re.match(sps) # catch %Astrobe...% prefix
            if m is not None:
                avar_name = m.group(1)
                dir_string = avar_val + m.group(2)
            else:
                dir_string = sps
            if avar_name != '' and avar_val == '':
                print(f'{PROG_NAME}: {avar_name} is used in search path, but no value given (\'-f\')')
                sys.exit(1)
            if dir_string != '':
                dir_path = Path(dir_string)
                if not dir_path.is_absolute():
                    dir_path = self._cwd.joinpath(dir_string)
                dir_path = dir_path.resolve()
                if dir_path.is_dir():
                    path_seg.append(dir_path)

        self._path_seg = path_seg


    def find_mod_file(self, file_name, mod_file):
        """Find module file along search path."""

        copy = False
        for fp in self._path_seg:
            if fp.samefile(self._libdir):
                copy = True
            else:
                f = fp.joinpath(file_name)
                if f.is_file():
                    return f, copy and f
        # if found we'll not pass here (yes, return from a loop. ugly)
        print(f'{PROG_NAME}: cannot find source file for module {f.stem}, IMPORT in module {mod_file.stem}')
        sys.exit(1)


    def find_boot_file(self):
        copy = False
        for fp in self._path_seg:
            if fp.samefile(self._libdir):
                copy = True
            else:
                f = fp.joinpath(BOOT2_BIN)
                if f.is_file():
                    return f, copy and f
        return False, False


    def get_all_lib_files(self, all_lib, skip_lib):

        skip_pat = r'^_+[a-zA-z]\w*'
        skip_re = re.compile(skip_pat)

        lib_names = []

        copy = False
        for fp in self._path_seg:
            if fp.is_dir():
                if fp.samefile(self._libdir):
                    copy = True
                else:
                    if copy:
                        for f in fp.iterdir():
                            if not f.is_dir():
                                if f.suffix == '.mod' and not f.name == BUILD_MOD and not skip_re.match(f.name):
                                    # skip over Astrobe's Build.mod and file names starting with '_'
                                    if not f.name in lib_names:
                                        all_lib.append(f)
                                        lib_names.append(f.name)
                                    else:
                                        # already found a module with this name
                                        skip_lib.append(f)

class StripComments:
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
            # raise an exception as flow control?! -- a super weird Python thing
            raise StopIteration


## main
def main():

    platform = sys.platform
    if platform != MACOS and platform != WINDOWS:
        print(f'{platform} is not supported')
        sys.exit(1)

    cmds = {
        'update': UpdateCmd(),
        'clean': CleanCmd(),
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
