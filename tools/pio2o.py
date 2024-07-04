#!/usr/bin/env python3

# Create an Oberon source module for PIO assembly code
# --
# Run with option -h for help.
# --
# Put into a directory on $PYTHONPATH, and run as
# 'python -m  pio2o ...'
# No idea if that's the right way, but it works.
# --
# Copyright (c) 2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import sys
import subprocess
from pathlib import PurePath

# define PIO block delimiter keywords
PIOBEGIN = "PIOBEGIN"
PIOEND = "PIOEND"

def read_file_lines(file):
# in_lines: a list of lines as strings
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

def extract_pio_data(c_lines, prog_names):
# pio_data: a list of dictionaries, one per program, from pioasm output as c_lines
    pio_data = []
    for prog_name in prog_names:
        pio_data.append({"prog_name": prog_name})

    p = 0; copy_code = False
    for c_line in c_lines:
        line = c_line.strip()
        if line.startswith("#define"):
            #print(line)
            def_el = line.split()
            #print(def_el)
            if def_el[1].endswith("_wrap_target"):
                pio_data[p]["wrap_target"] = def_el[2]
            else:
                pio_data[p]['wrap'] = def_el[2]
            # print(programs)
        elif line.startswith("static const uint16_t"):
            copy_code = True
            pio_data[p]["code"] = []
        elif copy_code and line.startswith("};"):
            copy_code = False
            p = p + 1
        elif copy_code:
            if not line.startswith("//"):
                line_el = line.split(", ")
                #print(line_el)
                hex_code = line_el[0].replace("0x", "0").upper() + "H"
                #print(hex_code)
                pio_data[p]["code"].append(hex_code)
    return pio_data

def write_oberon_file(file, mod_name, pio_lines, pio_data):
# from pio_data
    try:
        with open(file, "w") as modf:
            modf.write("MODULE " + mod_name + ";\n")
            modf.write("(**\n")
            modf.write("  Oberon RTK Framework\n")
            modf.write("  Generated module from PIO assembly code.\n")
            modf.write("  Assembly programs:\n")
            for line in pio_lines:
                modf.write(line + "\n")
            modf.write("**)\n\n")
            modf.write("  PROCEDURE GetCode*(progName: ARRAY OF CHAR; VAR code: ARRAY OF INTEGER; VAR numInstr, wrapTarget, wrap: INTEGER);\n")
            modf.write("  BEGIN\n")
            p = 0
            num_progs = len(pio_data)
            prog_num = 0
            for p in pio_data:
                if prog_num == 0:
                    modf.write("    IF progName = \"" + p['prog_name'] + "\" THEN\n")
                else:
                    modf.write("    ELSIF progName = \"" + p['prog_name'] + "\" THEN\n")
                ix = 0
                for c in p['code']:
                    modf.write("      code[" + str(ix) + "] := ")
                    modf.write(c + ";\n")
                    ix = ix + 1
                modf.write("      numInstr := " + str(ix) + ";\n")
                modf.write("      wrapTarget := " + p['wrap_target'] + ";\n")
                modf.write("      wrap := " + p['wrap'] + "\n")
                prog_num = prog_num + 1
                if prog_num == num_progs:
                    modf.write("    END;\n")
            modf.write("  END GetCode;\n")
            modf.write("END " + mod_name + ".\n")
            return True
    except:
        return False

def main():
    # arguments
    import argparse
    parser = argparse.ArgumentParser(
    prog = "pio2o",
    description="Create an Oberon module for PIO assembly code. 'pioasm' is used to assemble the \
        PIO code, which then can be accessed from the Oberon module." ,
    epilog = "PIO source code can be extracted from an Oberon module (.mod), \
        or read from a separate file (.pio). In the Oberon module, place \
        the code inside a comment and keywords {} and {}.".format(PIOBEGIN, PIOEND))
    parser.add_argument("-v", "--verbose", action="store_true", dest="verbose", help="print feedback")
    parser.add_argument("-o", dest="module", help="output module name (Oberon)")
    parser.add_argument("ifn", help="input file (.mod or .pio)")

    args = parser.parse_args()
    if args.module == None:
        mod_name = str(PurePath(args.ifn).stem) + "Pio"
    else:
        mod_name = args.module

    # the files
    outf_base = PurePath(args.ifn)
    inf_ext = outf_base.suffix
    tmpf_stem = str(outf_base.stem) + ".pio"
    pio_file = outf_base.with_name("_" + tmpf_stem + ".pio")
    c_file = outf_base.with_name("_" + tmpf_stem + ".h")
    mod_file = outf_base.with_name(mod_name + ".mod")

    if inf_ext != ".mod" and inf_ext != ".pio":
        print("Error: input file must be '.mod' or '.pio': {}".format(args.ifn))
        sys.exit()

    if args.verbose:
        print("Output module name: {}".format(mod_name))
        print("Input file: {}".format(outf_base))
        print("Output file: {}".format(mod_file))

    in_lines = read_file_lines(args.ifn)
    if in_lines == []:
        print("Error: could not open and read input file {}".format(args.ifn))
        sys.exit()

    if args.verbose:
        print("Extracting PIO assembly source from {}...".format(args.ifn))

    pio_lines, prog_names = extract_pio_lines(in_lines, inf_ext)
    if pio_lines == []:
        print("Error: no {} .. {} block found in input file {}".format(PIOBEGIN, PIOEND, args.ifn))
        sys.exit()
    if prog_names == []:
        print("Error: no PIO programs found in input file {}".format(args.ifn))
        sys.exit()

    if args.verbose:
        for pn in prog_names:
            print("  found program: " + pn)

    # create PIO assembly input file for piasm
    if args.verbose:
        print("Writing 'pioasm' input file {}...".format(pio_file))

    ok = write_file_lines(pio_file, pio_lines)
    if not ok:
        print("Error: could not write 'pioasm' input file {}".format(pio_file))
        sys.exit()

    # run piasm
    if args.verbose:
        print("Running 'pioasm' assembler...")

    ext_prog = "pioasm -o c-sdk".split() + [pio_file] + [c_file]
    popen = subprocess.Popen(ext_prog)
    popen.wait()

    # read piasm output (c-sdk format)
    c_lines = read_file_lines(c_file)
    if c_lines == []:
        print("Error: could not read 'pioasm' output file {}.".format(c_file))
        sys.exit()

    # extract data from piasm output
    if args.verbose:
        print("Extracting PIO program data from 'pioasm' output file {}...".format(c_file))

    pio_data = extract_pio_data(c_lines, prog_names)

    # create Oberon module
    if args.verbose:
        print("Writing Oberon module file {}...".format(mod_file))

    ok = write_oberon_file(mod_file, mod_name, pio_lines, pio_data)

    if not ok:
        print("Error: could not create output file {}".format(mod_file))
        sys.exit()

    print("pio2o has created Oberon module " + mod_name + " in " + str(outf_base.parent))
    sys.exit(0)

if __name__ == '__main__':
    main()