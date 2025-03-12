#!/usr/bin/env python3

# Create an Oberon source module for PIO assembly code
# --
# Run with option -h for help.
# --
# Binary 'pioasm' must be on the $PATH.
# 'pioasm' must be v2.x
# --
# Supported platforms: Windows, macOS
# --
# Copyright (c) 2024-2025 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

import sys, json
import subprocess
from pathlib import Path

# supported platforms
WINDOWS = 'win32'
MACOS = 'darwin'

# define PIO block delimiter keywords
PIOBEGIN = "PIOBEGIN"
PIOEND = "PIOEND"

def read_file_lines(file):
# in_ln: a list of lines as strings
    try:
        with open(file, "r") as inf:
            in_ln = [line for line in inf.readlines()]
            return in_ln
    except:
        return []

def write_file_lines(file, lines):
# write from list of lines as strings
    try:
        with open(file, "w") as piof:
            for line in lines:
                piof.write(line + "\n")
        return True
    except:
        return False

def extract_pio_lines(in_lines, inf_ext):
# pio_lines: a list of pio code lines from input file lines
    pio_lines = []
    if inf_ext == ".mod":
        copy_line = False
        begin_ok = False
        end_ok = False
        for in_line in in_lines:
            line = in_line.strip()
            if line.startswith(PIOBEGIN):
                copy_line = True
                begin_ok = True
            elif line.startswith(PIOEND):
                if not begin_ok:
                    # no begin
                    break
                copy_line = False
                end_ok = True
                # begin and end
                break
            elif (begin_ok and line.endswith("*)")):
                # no end
                break
            elif copy_line:
                pio_lines.append(in_line.strip("\n"))
        if not (begin_ok and end_ok):
            pio_lines = []
    else: # .pio
        for in_line in in_lines:
            pio_lines.append(in_line.strip("\n"))
    return pio_lines


def extract_pio_data_json(pio_data_json):
    pio_data = []
    programs = pio_data_json['programs']
    for i, p in enumerate(programs):
        pio_data.append({})
        pio_data[i]['name'] = p['name']
        pio_data[i]['wrapTarget'] = p['wrapTarget']
        pio_data[i]['wrap'] = p['wrap']
        pio_data[i]['origin'] = p['origin']
        pio_data[i]['sideset'] = p['sideset']
        pio_data[i]['instructions'] = []
        for instr in p['instructions']:
           pio_data[i]['instructions'].append(f"0{instr['hex']}H")
        pio_data[i]['numInstr'] = len(pio_data[i]['instructions'])
        pio_data[i]['publicSymbols'] = {}
        pio_data[i]['publicSymbols']['local'] = p['publicSymbols']
        pio_data[i]['publicSymbols']['global'] = pio_data_json['publicSymbols']
        pio_data[i]['publicLabels'] = p['publicLabels']

    # print(pio_data)
    return pio_data

def write_oberon_file(file, mod_name, pio_lines, pio_data):
# from pio_data

    # line delimiters
    if sys.platform == WINDOWS:
        eol = '\n'
    else:
        eol = '\r\n'

    try:
        with open(file, "w") as modf:
            modf.write(f"MODULE {mod_name};{eol}")
            modf.write(f"(**{eol}")
            modf.write(f"  Oberon RTK Framework{eol}")
            modf.write(f"  Generated module from PIO assembly code.{eol}")
            modf.write(f"  --{eol}")
            modf.write(f"  PIO assembly listing:{eol}")
            for line in pio_lines:
                modf.write(f"{line}{eol}")
            modf.write(f"**){eol}{eol}")
            modf.write(f"  IMPORT PIO;{eol}{eol}")
            modf.write(f"  PROCEDURE GetCode*(progName: ARRAY OF CHAR; VAR prog: PIO.Program);{eol}")
            modf.write(f"    VAR i: INTEGER;{eol}")
            modf.write(f"  BEGIN{eol}")
            num_progs = len(pio_data)
            for p_num, p in enumerate(pio_data):
                if p_num == 0:
                    modf.write(f"    IF progName = \"{p['name']}\" THEN{eol}")
                else:
                    modf.write(f"    ELSIF progName = \"{p['name']}\" THEN{eol}")
                modf.write(f"      prog.name := \"{p['name']}\";{eol}")
                modf.write(f"      prog.wrapTarget := {p['wrapTarget']};{eol}")
                modf.write(f"      prog.wrap := {p['wrap']};{eol}")
                modf.write(f"      prog.origin := {p['origin']};{eol}")
                modf.write(f"      prog.sideset.size := {p['sideset']['size']};{eol}")
                modf.write(f"      prog.sideset.optional := {str(p['sideset']['optional']).upper()};{eol}")
                modf.write(f"      prog.sideset.pindirs := {str(p['sideset']['pindirs']).upper()};{eol}")
                for cx, c in enumerate(p['instructions']):
                    modf.write(f"      prog.instr[{cx}] := {c};{eol}")
                modf.write(f"      prog.numInstr := {p['numInstr']};{eol}")
                i = 0
                for name, value in p['publicLabels'].items():
                    modf.write(f"      prog.pubLabels[{i}].name := \"{name}\";{eol}")
                    modf.write(f"      prog.pubLabels[{i}].value := {value};{eol}")
                    i = i + 1
                modf.write(f"      prog.numPubLabels := {len(p['publicLabels'])};{eol}")
                i = 0
                for name, value in p['publicSymbols']['global'].items():
                    modf.write(f"      prog.pubSymbols.global[{i}].name := \"{nname}\";{eol}")
                    modf.write(f"      prog.pubSymbols.global[{i}].value := {value};{eol}")
                    i = i + 1
                modf.write(f"      prog.pubSymbols.numGlobals := {len(p['publicSymbols']['global'])};{eol}")
                i = 0
                for name, value in p['publicSymbols']['local'].items():
                    modf.write(f"      prog.pubSymbols.local[{i}].name := \"{name}\";{eol}")
                    modf.write(f"      prog.pubSymbols.local[{i}].value := {value};{eol}")
                    i = i + 1
                modf.write(f"      prog.pubSymbols.numLocals := {len(p['publicSymbols']['local'])};{eol}")
                modf.write(f"      i := prog.numPubLabels;{eol}")
                modf.write(f"      WHILE i < PIO.NumDefs DO;{eol}")
                modf.write(f"        CLEAR(prog.pubLabels[i]); INC(i){eol}")
                modf.write(f"      END;{eol}")
                modf.write(f"      i := prog.pubSymbols.numGlobals;{eol}")
                modf.write(f"      WHILE i < PIO.NumDefs DO;{eol}")
                modf.write(f"        CLEAR(prog.pubSymbols.global[i]); INC(i){eol}")
                modf.write(f"      END;{eol}")
                modf.write(f"      i := prog.pubSymbols.numLocals;{eol}")
                modf.write(f"      WHILE i < PIO.NumDefs DO;{eol}")
                modf.write(f"        CLEAR(prog.pubSymbols.local[i]); INC(i){eol}")
                modf.write(f"      END{eol}")
            modf.write(f"    END{eol}")
            modf.write(f"  END GetCode;{eol}")
            modf.write(f"END {mod_name}.{eol}")
            return True
    except:
        return False


def main():
    # platform check
    if sys.platform != MACOS and sys.platform != WINDOWS:
        print(f"{platform} is not supported.")
        sys.exit(1)

    # arguments
    import argparse
    parser = argparse.ArgumentParser(
        prog = 'pio2o',
        description = """Create an Oberon module for PIO assembly code. 'pioasm' is used to assemble the
            PIO code, which then can be accessed from the Oberon module.""" ,
        epilog = f"""PIO source code can be extracted from an Oberon module (.mod),
            or read from a separate file (.pio). In the Oberon module, place
            the code inside a comment and keywords {PIOBEGIN} and {PIOEND}.""")
    parser.add_argument('--verbose', action='store_true', dest='verbose', help="print feedback")
    parser.add_argument('-o', dest='module', help="Oberon output module name")
    parser.add_argument('-v', dest='version', type=int, help="default pioasm version (0 or 1, default: 1)")
    parser.add_argument('ifn', help="input file (.mod or .pio)")

    args = parser.parse_args()
    if args.module is None:
        mod_name = str(Path(args.ifn).stem) + "Pio"
    else:
        mod_name = args.module

    if args.version is None:
        version = 1
    else:
        version = args.version

    # the files
    outf_base = Path(args.ifn)
    inf_ext = outf_base.suffix
    tmpf_stem = str(outf_base.stem) + ".pio"
    pio_file = outf_base.with_name("_" + tmpf_stem + ".pio")
    json_file = outf_base.with_name("_" + tmpf_stem + ".json")
    mod_file = outf_base.with_name(mod_name + ".mod")

    if inf_ext != ".mod" and inf_ext != ".pio":
        print(f"Error: input file must be '.mod' or '.pio': {args.ifn}")
        sys.exit()

    if args.verbose:
        print(f"Output module name: {mod_name}")
        print(f"Input file: {outf_base}")
        print(f"Output file: {mod_file}")
        print(f"Default 'pioasm' version: {version}")

    in_lines = read_file_lines(args.ifn)
    if in_lines == []:
        print(f"Error: could not open and read input file {args.ifn}")
        sys.exit()

    if args.verbose:
        print(f"Extracting PIO assembly source from {args.ifn}...")

    pio_lines = extract_pio_lines(in_lines, inf_ext)
    if pio_lines == []:
        print(f"Error: no {PIOBEGIN} .. {PIOEND} block found in input file {args.ifn}")
        sys.exit()

    # create PIO assembly input file for piasm
    if args.verbose:
        print(f"Writing 'pioasm' input file {pio_file}...")

    ok = write_file_lines(pio_file, pio_lines)
    if not ok:
        print(f"Error: could not write 'pioasm' input file {pio_file}")
        sys.exit()

    # run piasm
    if args.verbose:
        print("Running 'pioasm' assembler...")

    ext_prog = "pioasm -o json -v".split() + [f'{version}'] + [pio_file] + [json_file]
    done = subprocess.run(ext_prog)
    if done.returncode != 0:
        print("Error: 'pioasm' found problems");
        sys.exit()

    # read piasm output (json format)
    json_lines = read_file_lines(json_file)
    pio_data_json = json.loads("".join(json_lines))

    if args.verbose:
        print(f"Reading PIO program data from 'pioasm' output file {json_file}...")

    pio_data = extract_pio_data_json(pio_data_json)

    # create Oberon module
    if args.verbose:
        print(f"Writing Oberon module file {mod_file}...")

    ok = write_oberon_file(mod_file, mod_name, pio_lines, pio_data)

    if not ok:
        print(f"Error: could not create output file {mod_file}")
        sys.exit()

    print(f"Created Oberon module {mod_name}.mod in {str(outf_base.parent)}")
    sys.exit(0)

if __name__ == '__main__':
    main()
