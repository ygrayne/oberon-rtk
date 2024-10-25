#!/usr/bin/env python3

# Translate an Astrobe .bin file to UF2 format for Pico.
# Optionally copy to Pico's "virtual drive".
# Tested with .bin files created by Astrobe v9.3 for Cortex-M0.
# --
# Run with option -h for help.
# --
# Put into a directory on $PYTHONPATH, together with the default
# bootstage 2 file, and run as 'python -m abin2uf2 ...'
# No idea if that's the right way, but it works.
# --
# Copyright (c) 2023-2024 Gray, gray@graraven.org
# https://oberon-rtk.org/licences/

# The accompanying 'boot2.uf2' binary is
# Copyright (c) 2019-2021 Raspberry Pi (Trading) Ltd.
# SPDX-Licence-Identifier: BSD-3-Clause


import argparse
import struct
import sys
import os
import shutil

parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", dest="verbose", help="print too much feedback")
parser.add_argument("ifn", help="input file (.bin)")
parser.add_argument("-o", "--ofn", help="output file (.uf2), default: ifn.uf2")
parser.add_argument("-l", "--lfn", help="bootstage 2 file (.uf2), default: 'boot2.uf2'")
parser.add_argument("-d", "--drive", dest="drv", help="install drive, eg. 'F:'")

args = parser.parse_args()

# The default bootstage 2 file is in the scripts directory
run_dir = os.path.dirname(os.path.realpath(sys.argv[0])) + "/"
if args.lfn == None: lfn = run_dir + "boot2.uf2"
else: lfn = args.lfn

if args.ofn == None: ofn = os.path.splitext(args.ifn)[0] + ".uf2"
else: ofn = args.ofn

try:
    ifile = open(args.ifn, "rb")
    idata = ifile.read()
except:
    sys.exit("Could not open and read input file '{}'".format(args.ifn))

try:
    lfile = open(lfn, "rb")
    ldata = lfile.read()
except:
    ifile.close()
    sys.exit("Could not open and read bootstage 2 file '{}'".format(lfn))

if args.verbose:
    print("bootstage 2 file:", lfn)
    print("output file:", ofn)

BYTES_PER_BLOCK = 256
numblocks = ((len(idata) + BYTES_PER_BLOCK - 1) // BYTES_PER_BLOCK)
if args.verbose:
    print("bin file:", len(idata), "bytes")
    print("number of code blocks in bin file:", numblocks)
numblocks = numblocks + 1 # +1 for bootloader block

# UF2 headers
RP2040_FAMID = 0xE48BFF56

header0 = struct.pack("<L", 0x0A324655)     # UF2\n
header1 = struct.pack("<L", 0x9E5D5157)     # magic
header3 = struct.pack("<L", 0x00002000)     # flags
header5 = struct.pack("<L", 256)            # data size
header7 = struct.pack("<L", numblocks)      # blocks
header8 = struct.pack("<L", RP2040_FAMID)   # family ID
header9 = struct.pack("<L", 0x0AB16F30)     # magic

# rp2040 & pico board
flashaddr = 0x10000000
max_flashaddr = 0x10200000
sramaddr = 0x20000000
max_sramaddr = sramaddr + 0x40000
codeaddr = 0x10000100
max_codeaddr = max_flashaddr

msp = struct.unpack("<L", idata[0:4])[0]
entry = struct.unpack("<L", idata[4:8])[0]

if args.verbose:
    if msp >= sramaddr and msp < max_sramaddr: msg0 = "(in SRAM range)"
    else: msg0 = "(NOT in SRAM range)"
    if entry >= flashaddr and entry < max_flashaddr: msg1 = "(in FLASH range for Pico (2MB))"
    else: msg1 = "(NOT in FLASH range for Pico (2MB))"
    print("MSP address:", hex(msp), msg0)
    print("entry address", hex(entry), msg1)

try:
    with open(ofn, "wb") as ofile:
        # bootloader block
        ldata0 = ldata[0:24]
        ldata2 = ldata[28:len(ldata)]
        ofile.write(ldata0)
        ofile.write(header7)
        ofile.write(ldata2)
        # code & resources blocks
        for offs, block, addr in zip(range(0, len(idata), 256), range(1, numblocks, 1), range(codeaddr, max_codeaddr, 256)):
            ofile.write(header0)
            ofile.write(header1)
            ofile.write(header3)
            ofile.write(struct.pack("<L", addr))
            ofile.write(header5)
            ofile.write(struct.pack("<L", block))
            ofile.write(header7)
            ofile.write(header8)
            chunk = idata[offs:min(offs + 256, len(idata))]
            ofile.write(chunk)
            chunk_size = len(chunk)
            for zeros in range(chunk_size, 476):
                ofile.write(struct.pack("B", 0))
            ofile.write(header9)
except:
    sys.exit("Could not create output file '{}'".format(ofn))

if chunk_size == 256:
    full_blocks_size = block * 256
    full_blocks = block
else:
    full_blocks_size = (block - 1) * 256
    full_blocks = block - 1

if args.verbose:
    print("full program code and resources blocks: {} x 256 bytes = {} bytes".format(full_blocks, full_blocks_size))
    print("last block: {} bytes".format(chunk_size))
    print("program code and resources size: {} bytes (without bootstage 2 code)".format(full_blocks_size + chunk_size))

if args.drv != None:
    try:
        shutil.copy(ofile.name, args.drv)
        if args.verbose:
            print("Installed {} on target drive {}".format(ofn, args.drv))
    except:
        print("Could not install {} on target drive '{}'. The Pico must be in BOOTSEL mode.".format(ofn, args.drv))
else:
    print("{} not installed. Use options -d or --drive to specify a target drive.".format(ofn))

ofile.close()
ifile.close()
lfile.close()
