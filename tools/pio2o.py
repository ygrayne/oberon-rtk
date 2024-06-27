#!/usr/bin/env python3

# Create an Oberon source module for PIO assembly code
# It works, but needs some structural work...
# --
# Run with option -h for help.
# --
# Put into a directory on $PYTHONPATH, and run as
# 'python -m  pio2o ...'
# No idea if that's the right way, but it works.
# --
# Copyright (c) 2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import argparse
import sys
import subprocess
from pathlib import PurePath

# define PIO block delimiter keywords
PIOBEGIN = "PIOBEGIN"
PIOEND = "PIOEND"

# command line parsing
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

# get the base of it all
try:
    with open(args.ifn, "r") as inf:
        in_lines = [line for line in inf.readlines()]
except:
    # Astrobe does not display the sys.exit messages
    print("Error: could not open and read input file {}".format(args.ifn))
    sys.exit()

# get PIO block and program names
if args.verbose:
    print("Extracting PIO assembly source from {}...".format(args.ifn))

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
        print("Error: no {} .. {} block found in input file {}".format(PIOBEGIN, PIOEND, args.ifn))
        sys.exit()
else:
    for in_line in in_lines:
        line = in_line.strip()
        pio_lines.append(in_line.strip("\n"))
        if line.startswith(".program"):
            line_el = line.split()
            prog_names.append(line_el[1])

if prog_names == []:
    print("Error: no PIO programs found in input file {}".format(args.ifn))
    sys.exit()

if args.verbose:
    for pn in prog_names:
        print("  found program: " + pn)

# print(prog_names)
# print(pio_lines)

# create PIO assembly file for piasm
if args.verbose:
    print("Writing 'pioasm' input file {}...".format(pio_file))
try:
    with open(pio_file, "w") as piof:
        for line in pio_lines:
            piof.write(line + "\n")
except:
    print("Error: could not write PIO assembly source file {}".format(pio_file))
    sys.exit()

# run piasm
if args.verbose:
    print("Running 'pioasm' assembler...")
ext_prog = "pioasm -o c-sdk".split() + [pio_file] + [c_file]
popen = subprocess.Popen(ext_prog)
popen.wait()

# read piasm output (c-sdk format)
try:
    with open(c_file, "r") as cf:
        c_lines = [line.strip() for line in cf.readlines()]
except:
    print("Error: could not read 'pioasm' output file {}.".format(c_file))
    sys.exit()

# programs list
programs = []
for prog_name in prog_names:
    programs.append({"prog_name": prog_name})

# print(programs)

# extract data from piasm output
if args.verbose:
    print("Extracting PIO program data from 'pioasm' output file {}...".format(c_file))
p = 0
copy_code = False
for c_line in c_lines:
    line = c_line.strip()
    if line.startswith("#define"):
        #print(line)
        def_el = line.split()
        #print(def_el)
        if def_el[1].endswith("_wrap_target"):
            programs[p]["wrap_target"] = def_el[2]
        else:
            programs[p]['wrap'] = def_el[2]
        # print(programs)
    elif line.startswith("static const uint16_t"):
        copy_code = True
        programs[p]["code"] = []
    elif copy_code and line.startswith("};"):
        copy_code = False
        p = p + 1
    elif copy_code:
        if not line.startswith("//"):
            line_el = line.split(", ")
            #print(line_el)
            hex_code = line_el[0].replace("0x", "0").upper() + "H"
            #print(hex_code)
            programs[p]["code"].append(hex_code)

# print(programs)

# create Oberon module
if args.verbose:
    print("Writing Oberon module file {}...".format(mod_file))
try:
    with open(mod_file, "w") as modf:
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
        num_progs = len(programs)
        prog_num = 0
        for p in programs:
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
except:
    print("Error: could not create output file {}".format(mod_file))
    sys.exit()

print("Created Oberon module " + mod_name + " in " + str(outf_base.parent))
sys.exit(0)
