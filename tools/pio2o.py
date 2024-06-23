#!/usr/bin/env python3

# Create an Oberon source module for PIO assembly code
# My second ever Python program, so... hacks ahead, probably.
# --
# Run with option -h for help.
# --
# Put into a directory on the PYTHONPATH, and run as
# 'python -m  pio2o ...'
# No idea if that's the right way, but it works.
# --
# Copyright (c) 2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/


import argparse
import sys
import os
import subprocess
from pathlib import PureWindowsPath

parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", dest="verbose", help="print feedback")
parser.add_argument("ifn", help="input file (pioasm)")

args = parser.parse_args()

of_base = PureWindowsPath(args.ifn)
mod_name = str(PureWindowsPath(args.ifn).stem) + "Pio"
tmpf_stem = str(PureWindowsPath(args.ifn).stem) + ".pio"

pio_file = of_base.with_name(tmpf_stem + ".pio")
hex_file = of_base.with_name(tmpf_stem + ".hex")
mod_file = of_base.with_name(mod_name + ".mod")

# print(of_base)
# print(mod_name)
# print(tmpf_stem)
# print(pio_file)
# print(hex_file)
# print(mod_file)

try:
    inf = open(args.ifn, "r")
    in_lines = [line.strip("\n") for line in inf.readlines()]
except:
    sys.exit("Could not open and read input file '{}'".format(args.ifn))

i = 0
while i < len(in_lines):
    line = in_lines[i].strip()
    if line.startswith("PIO;"):
        break
    i = i + 1
if i == len(in_lines):
    sys.exit("PIO; keyword not found")

i = i + 1
pio_lines = []
while i < len(in_lines):
    line = in_lines[i].strip()
    if line.startswith("PIO."):
        break
    pio_lines.append(in_lines[i])
    i = i + 1
if i == len(in_lines):
    sys.exit("PIO. keyword not found")

try:
    with open(pio_file, "w") as piof:
        for line in pio_lines:
            piof.write(line + "\n")
except:
    sys.exit("Could not write PIO assembly source file '{}'".format(pio_file))

if args.verbose:
    print("output file:", mod_file)

args = "pioasm -o hex".split() + [pio_file] + [hex_file]
popen = subprocess.Popen(args)
popen.wait()

try:
    hexf = open(hex_file, "r")
    hex_lines = [line.strip() for line in hexf.readlines()]
except:
    sys.exit("Could not read PIO assembly code file.")

try:
    with open(mod_file, "w") as modf:
        modf.write("MODULE " + mod_name + ";\n")
        modf.write("(**\n")
        modf.write("  Oberon RTK Framework\n")
        modf.write("  Generated module from PIO assembly code.\n")
        modf.write("  Assembly program:\n")
        for line in pio_lines:
            modf.write(line + "\n")
        modf.write("**)\n\n")
        modf.write("  PROCEDURE GetCode*(VAR code: ARRAY OF INTEGER; VAR n: INTEGER);\n")
        modf.write("  BEGIN\n")
        ix = 0
        for line in hex_lines:
            modf.write("    code[" + str(ix) + "] := ")
            modf.write("0" + line.upper() + "H;\n")
            ix = ix + 1
        modf.write("    n := " + str(ix) + "\n")
        modf.write("  END GetCode;\n")
        modf.write("END " + mod_name + ".")
        modf.write('\n')

except:
    sys.exit("Could not create output file '{}'".format(ofn))

inf.close()
modf.close()
piof.close()
hexf.close()
