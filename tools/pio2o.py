#!/usr/bin/env python3

# Create an Oberon source module for PIO assembly code
# --
# Run with option -h for help.
# --
# Binary 'pioasm' must be on the $PATH.
# Tested on Windows and macOS.
# --
# Copyright (c) 2024-2025 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import sys, json
import subprocess
from pathlib import PurePath

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
    prog_names = []
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
                if line.startswith(".program"):
                    line_el = line.split()
                    prog_names.append(line_el[1])
        if not (begin_ok and end_ok):
            pio_lines = []
    else: # .pio
        for in_line in in_lines:
            pio_lines.append(in_line.strip("\n"))
            line = in_line.strip()
            if line.startswith(".program"):
                line_el = line.split()
                prog_names.append(line_el[1])
    return pio_lines, prog_names


def extract_pio_data_json(pio_data_json):
    pio_data = []
    programs = pio_data_json['programs']
    i = 0
    for p in programs:
        pio_data.append({})
        pio_data[i]['prog_name'] = p['name']
        pio_data[i]['wrap_target'] = str(p['wrapTarget'])
        pio_data[i]['wrap'] = str(p['wrap'])
        pio_data[i]['code'] = []
        for instr in p['instructions']:
            pio_data[i]['code'].append(f"0{instr['hex']}H")
        i = i + 1
    # print(pio_data)
    return pio_data


def write_oberon_file(file, mod_name, pio_lines, pio_data):
# from pio_data
    try:
        with open(file, "w") as modf:
            modf.write("MODULE " + mod_name + ";\r\n")
            modf.write("(**\r\n")
            modf.write("  Oberon RTK Framework\r\n")
            modf.write("  Generated module from PIO assembly code.\r\n")
            modf.write("  Assembly programs:\r\n")
            for line in pio_lines:
                modf.write(line + "\r\n")
            modf.write("**)\r\n\r\n")
            modf.write("  PROCEDURE GetCode*(progName: ARRAY OF CHAR; VAR code: ARRAY OF INTEGER; VAR numInstr, wrapTarget, wrap: INTEGER);\r\n")
            modf.write("  BEGIN\r\n")
            p = 0
            num_progs = len(pio_data)
            prog_num = 0
            for p in pio_data:
                if prog_num == 0:
                    modf.write("    IF progName = \"" + p['prog_name'] + "\" THEN\r\n")
                else:
                    modf.write("    ELSIF progName = \"" + p['prog_name'] + "\" THEN\r\n")
                ix = 0
                for c in p['code']:
                    modf.write("      code[" + str(ix) + "] := ")
                    modf.write(c + ";\r\n")
                    ix = ix + 1
                modf.write("      numInstr := " + str(ix) + ";\r\n")
                modf.write("      wrapTarget := " + p['wrap_target'] + ";\r\n")
                modf.write("      wrap := " + p['wrap'] + ";\r\n")
                prog_num = prog_num + 1
                if prog_num == num_progs:
                    modf.write("    END;\r\n")
            modf.write("  END GetCode;\r\n")
            modf.write("END " + mod_name + ".\r\n")
            return True
    except:
        return False

def main():
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
    parser.add_argument('-o', dest='module', help="output module name (Oberon)")
    parser.add_argument('-v', dest='version', help="pioasm version (0 or 1, default: 0)")
    parser.add_argument('ifn', help="input file (.mod or .pio)")

    args = parser.parse_args()
    if args.module is None:
        mod_name = str(PurePath(args.ifn).stem) + "Pio"
    else:
        mod_name = args.module

    if args.version is None:
        version = 0
    else:
        version = args.version

    # the files
    outf_base = PurePath(args.ifn)
    inf_ext = outf_base.suffix
    tmpf_stem = str(outf_base.stem) + ".pio"
    pio_file = outf_base.with_name("_" + tmpf_stem + ".pio")
    c_file = outf_base.with_name("_" + tmpf_stem + ".h")
    json_file = outf_base.with_name("_" + tmpf_stem + ".json")
    mod_file = outf_base.with_name(mod_name + ".mod")

    if inf_ext != ".mod" and inf_ext != ".pio":
        print(f"Error: input file must be '.mod' or '.pio': {args.ifn}")
        sys.exit()

    if args.verbose:
        print(f"Output module name: {mod_name}")
        print(f"Input file: {outf_base}")
        print(f"Output file: {mod_file}")
        print(f"'pioasm' version: {version}")

    in_lines = read_file_lines(args.ifn)
    if in_lines == []:
        print(f"Error: could not open and read input file {args.ifn}")
        sys.exit()

    if args.verbose:
        print(f"Extracting PIO assembly source from {args.ifn}...")

    pio_lines, prog_names = extract_pio_lines(in_lines, inf_ext)
    if pio_lines == []:
        print(f"Error: no {PIOBEGIN} .. {PIOEND} block found in input file {args.ifn}")
        sys.exit()
    if prog_names == []:
        print(f"Error: no PIO programs found in input file {args.ifn}")
        sys.exit()

    if args.verbose:
        for pn in prog_names:
            print("  found program: " + pn)

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

    pio_data2 = extract_pio_data_json(pio_data_json)

    # create Oberon module
    if args.verbose:
        print(f"Writing Oberon module file {mod_file}...")

    ok = write_oberon_file(mod_file, mod_name, pio_lines, pio_data2)

    if not ok:
        print(f"Error: could not create output file {mod_file}")
        sys.exit()

    print(f"pio2o has created Oberon module {mod_name} ({mod_file}) in {str(outf_base.parent)}")
    sys.exit(0)

if __name__ == '__main__':
    main()
