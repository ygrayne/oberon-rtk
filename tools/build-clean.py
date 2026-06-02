#!/usr/bin/env python3
"""
build-clean -- Delete generated build artefacts along the lib search path.
--
Walks the library search path defined in an Astrobe configuration file
and deletes generated build artefacts (object files, listings, debug
data, etc.) from each directory on the path, plus the source file's
own directory. Same positional-argument shape as AstrobeBuild, so it
slots into build scripts as a parallel call.

Used in S/NS build chains where shared library modules need to be
recompiled between the S and NS builds — avoids "wrong version"
linker errors caused by stale .arm files compiled against the other
side's symbols.

No dependency checking, no consistency checking. Just delete by
extension. AstrobeBuild handles dependency-driven recompilation on
the next build.
--
Usage:
    python build-clean.py <astrobeFolder> <configFile> <sourceFile> [--deep]

    astrobeFolder  parent dir for %AstrobeRP2350% / %AstrobeRP2040% etc.
                   substitution in the .ini lib search paths
                   (same value as passed to AstrobeBuild)
    configFile     Astrobe .ini config file
    sourceFile     program source module (.mod) -- used to resolve
                   relative search paths against its parent directory
    --deep         also delete .smb (symbol) files

Example:
    python build-clean.py "C:\\Users\\gray\\Projects\\oberon\\dev" \\
        sec\\v31-rp2350-pico2-secure6-s.ini sec\\S.mod

    python build-clean.py %ASTROBE_FOLDER% %S_INI% %S_MOD% --deep
--
File extensions deleted (default):
    .arm, .map, .lst, .drf, .ref, .s, .asm, .uf2, .alst
With --deep, also:
    .smb
Filenames never deleted:
    boot2.bin
    FPU.smb, FPU.arm, FPU.lst
    MAU.smb, MAU.arm, MAU.lst

These lists are hardwired (matches the Sublime IDE plugin's
OberonDevCleanCommand convention).
--
Copyright (c) 2026 Gray, gray@grayraven.org
https://oberon-rtk.org/licences/
"""

import sys
import re
import argparse
from pathlib import Path

PROG_NAME = 'build-clean'

# File extensions to delete in default mode.
CLEAN_FILE_EXTS = [
    '.arm', '.map', '.lst', '.drf', '.ref',
    '.s', '.asm', '.uf2', '.alst',
]

# Filenames to never delete (regardless of extension).
CLEAN_FILES_EXCLUDED = [
    'boot2.bin',
    'FPU.smb', 'FPU.arm', 'FPU.lst',
    'MAU.smb', 'MAU.arm', 'MAU.lst',
]

# Extensions added by --deep mode.
CLEAN_FILE_EXTS_DEEP = CLEAN_FILE_EXTS + ['.smb']

# Astrobe substitution variables: %AstrobeRP2350%, %AstrobeRP2040%, etc.
SUB_VAR_RE = re.compile(r'%[A-Za-z][A-Za-z0-9_]*%')

# Lib path lines in the .ini: 'LibPathName0 = <path>', etc.
LIB_PATH_RE = re.compile(r'^LibPathName\d+\s*=\s*(.*)$')


def error(msg):
    print(f'{PROG_NAME}: {msg}', file=sys.stderr)
    sys.exit(1)


def parse_lib_search_path(cfg_file):
    """Read .ini and return list of non-empty LibPathName values.

    Returns the raw string values: substitution variables not yet
    expanded, paths not yet resolved.
    """
    try:
        text = cfg_file.read_text(encoding='utf-8', errors='replace')
    except OSError as e:
        error(f'cannot read config file {cfg_file}: {e}')
    paths = []
    for line in text.splitlines():
        m = LIB_PATH_RE.match(line.strip())
        if m:
            value = m.group(1).strip()
            if value:
                paths.append(value)
    return paths


def expand_path(raw_path, astrobe_folder, source_dir):
    """Expand %XXX% substitution variables and resolve relative paths.

    Returns a Path. May or may not exist on disk.
    """
    # Use a callable as the replacement so re.sub does NOT interpret
    # backslash sequences in astrobe_folder (Windows paths contain \U,
    # \g etc. which re.sub would otherwise treat as regex back-refs).
    expanded = SUB_VAR_RE.sub(lambda m: astrobe_folder, raw_path)
    p = Path(expanded)
    if not p.is_absolute():
        p = source_dir / p
    return p


def clean_directory(directory, exts, excluded):
    """Delete files in `directory` whose suffix is in `exts`,
    skipping filenames in `excluded`. Non-recursive.

    Returns count of files deleted.
    """
    if not directory.is_dir():
        return 0
    deleted = 0
    for entry in directory.iterdir():
        if entry.is_dir():
            continue
        if entry.name in excluded:
            continue
        if entry.suffix in exts:
            try:
                entry.unlink()
                deleted += 1
            except OSError as e:
                print(f'{PROG_NAME}: warning: cannot delete {entry}: {e}',
                      file=sys.stderr)
    return deleted


def main():
    parser = argparse.ArgumentParser(
        prog=PROG_NAME,
        description='Delete generated build artefacts along the lib search path.',)
    parser.add_argument('astrobe_folder', type=str,
        help='parent dir for %%AstrobeRPxxxx%% substitution (same value '
             'as passed to AstrobeBuild)')
    parser.add_argument('config_file', type=Path,
        help='Astrobe .ini config file')
    parser.add_argument('source_file', type=Path,
        help='program source module (.mod) -- used to resolve relative '
             'search paths against its parent directory')
    parser.add_argument('--deep', action='store_true',
        help='also delete .smb (symbol) files')

    args = parser.parse_args()

    if not args.config_file.is_file():
        error(f'config file not found: {args.config_file}')

    source_dir = args.source_file.absolute().parent
    astrobe_folder = args.astrobe_folder
    exts = CLEAN_FILE_EXTS_DEEP if args.deep else CLEAN_FILE_EXTS

    # Collect directories: each path on the lib search path that resolves
    # to an existing directory, plus the source file's own directory.
    dirs = []
    raw_paths = parse_lib_search_path(args.config_file)
    for raw in raw_paths:
        d = expand_path(raw, astrobe_folder, source_dir)
        if d.is_dir():
            dirs.append(d.resolve())
    if source_dir.is_dir():
        dirs.append(source_dir.resolve())

    # Deduplicate while preserving order (different .ini entries may
    # resolve to the same physical directory).
    seen = set()
    unique_dirs = []
    for d in dirs:
        key = str(d)
        if key not in seen:
            seen.add(key)
            unique_dirs.append(d)

    total = 0
    for d in unique_dirs:
        total += clean_directory(d, exts, CLEAN_FILES_EXCLUDED)

    print(f'{PROG_NAME}: deleted {total} file(s)')


if __name__ == '__main__':
    main()
