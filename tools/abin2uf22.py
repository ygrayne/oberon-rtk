#!/usr/bin/env python3

# Translate an Astrobe .bin file to UF2 format for Pico2.
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

if args.ofn == None: ofn = os.path.splitext(args.ifn)[0] + ".uf2"
else: ofn = args.ofn

try:
    ifile = open(args.ifn, "rb")
    idata = ifile.read()
except:
    sys.exit("Could not open and read input file '{}'".format(args.ifn))

if args.verbose:
    print("output file:", ofn)

BYTES_PER_BLOCK = 256
numblocks = ((len(idata) + BYTES_PER_BLOCK - 1) // BYTES_PER_BLOCK)
if args.verbose:
    print("bin file:", len(idata), "bytes")
    print("number of code blocks in bin file:", numblocks)
numblocks = numblocks + 1 # +1 for metadata block

# chip and board Pico2
FLASH_ADDR = 0x10000000
MAX_FLASH_ADDR = FLASH_ADDR + 0x400000
SRAM_ADDR = 0x20000000
MAX_SRAM_ADDR = SRAM_ADDR + 0x80000 # sans SRAM8 and SRAM9
CODE_ADDR = FLASH_ADDR + 0x100
MAX_CODE_ADDR = MAX_FLASH_ADDR

# UF2 headers
RP2040_FAMID = 0xE48BFF56
RP2350_ARM_S_FAMID = 0xE48BFF59
ABS_FAMID = 0xE48BFF57

UF2_BLOCK_BEGIN = struct.pack("<L", 0x0A324655)   # UF2\n
UF2_MAGIC_BEGIN = struct.pack("<L", 0x9E5D5157)
UF2_FLAGS       = struct.pack("<L", 0x00002000)
# UF2_ADDR: address
UF2_DATASIZE    = struct.pack("<L", BYTES_PER_BLOCK)
# UF2_BLOCKNO: block number
# UF2_NUMBLOCKS: number of blocks
# UF2_FAMID: familiy ID
UF2_MAGIC_END   = struct.pack("<L", 0x0AB16F30)         # magic
UF2_BLOCK_LEN = 0x200

# error E10 meta block
UF2_ADDR_E10      = struct.pack("<L", 0x10FFFF00)
UF2_BLOCKNO_E10   = struct.pack("<L", 0)
UF2_NUMBLOCKS_E10 = struct.pack("<L", 2)
UF2_FAMID_E10     = struct.pack("<L", ABS_FAMID)

# meta and code blocks
UF2_ADDR_META = struct.pack("<L", FLASH_ADDR)
UF2_BLOCKNO_META = struct.pack("<L", 0)
UF2_NUMBLOCKS = struct.pack("<L", numblocks)
UF2_FAMID = struct.pack("<L", RP2350_ARM_S_FAMID)
# UF2_FAMID = struct.pack("<L", RP2040_FAMID)

# meta data block
UF2_META_BLOCK_BEGIN  = struct.pack("<L", 0xFFFFDED3)
UF2_META_IMAGE_DEF    = struct.pack("<L", 0x10210142)  # item size = 1 word
UF2_META_VECT_TABLE   = struct.pack("<L", 0x00000203)  # item size = 2 words
UF2_META_LAST_ITEM    = struct.pack("<L", 0x000003FF)  # all items size = 3 words
UF2_META_LINK_SELF    = struct.pack("<L", 0x00000000)
UF2_META_BLOCK_END    = struct.pack("<L", 0xAB123579)

msp = struct.unpack("<L", idata[0:4])[0]
entry = struct.unpack("<L", idata[4:8])[0]

# meta = open("boot2.bin", "wb")

if args.verbose:
    if msp >= SRAM_ADDR and msp < MAX_SRAM_ADDR: msg0 = "(in SRAM range)"
    else: msg0 = "(NOT in SRAM range)"
    if entry >= FLASH_ADDR and entry < MAX_FLASH_ADDR: msg1 = "(in FLASH range for Pico2 (4MB))"
    else: msg1 = "(NOT in FLASH range for Pico2 (4MB))"
    print("MSP value:", hex(msp), msg0)
    print("entry address", hex(entry), msg1)

try:
    with open(ofn, "wb") as ofile:
        # # E10 meta data block
        # ofile.write(UF2_BLOCK_BEGIN)
        # ofile.write(UF2_MAGIC_BEGIN)
        # ofile.write(UF2_FLAGS)
        # ofile.write(UF2_ADDR_E10)
        # ofile.write(UF2_DATASIZE)
        # ofile.write(UF2_BLOCKNO_E10)
        # ofile.write(UF2_NUMBLOCKS_E10)
        # ofile.write(UF2_FAMID_E10)
        # for _ in range(0x20, 0x120):
        #     ofile.write(struct.pack("B", 0xEF))
        # for _ in range(0x120, 0x1FC):
        #     ofile.write(struct.pack("B", 0))
        # ofile.write(UF2_MAGIC_END)

        # meta data block
        ofile.write(UF2_BLOCK_BEGIN)
        ofile.write(UF2_MAGIC_BEGIN)
        ofile.write(UF2_FLAGS)
        ofile.write(UF2_ADDR_META)
        ofile.write(UF2_DATASIZE)
        ofile.write(UF2_BLOCKNO_META)
        ofile.write(UF2_NUMBLOCKS)
        ofile.write(UF2_FAMID)
        ofile.write(UF2_META_BLOCK_BEGIN)
        ofile.write(UF2_META_IMAGE_DEF)
        ofile.write(UF2_META_VECT_TABLE)
        ofile.write(struct.pack("<L", CODE_ADDR))
        ofile.write(UF2_META_LAST_ITEM)
        ofile.write(UF2_META_LINK_SELF)
        ofile.write(UF2_META_BLOCK_END)
        for _ in range(0x3C, 0x1FC):
            ofile.write(struct.pack("B", 0))
        ofile.write(UF2_MAGIC_END)

        # meta.write(UF2_META_BLOCK_BEGIN)
        # meta.write(UF2_META_IMAGE_DEF)
        # meta.write(UF2_META_VECT_TABLE)
        # meta.write(struct.pack("<L", CODE_ADDR))
        # meta.write(UF2_META_LAST_ITEM)
        # meta.write(UF2_META_LINK_SELF)
        # meta.write(UF2_META_BLOCK_END)
        # for _ in range(0x1C, 0x100):
        #     meta.write(struct.pack("B", 0))

        # code & resources blocks
        for offs, block, addr in zip(range(0, len(idata), 256), range(1, numblocks, 1), range(CODE_ADDR, MAX_CODE_ADDR, 256)):
            ofile.write(UF2_BLOCK_BEGIN)
            ofile.write(UF2_MAGIC_BEGIN)
            ofile.write(UF2_FLAGS)
            ofile.write(struct.pack("<L", addr))
            ofile.write(UF2_DATASIZE)
            ofile.write(struct.pack("<L", block))
            ofile.write(UF2_NUMBLOCKS)
            ofile.write(UF2_FAMID)
            chunk = idata[offs:min(offs + 256, len(idata))]
            ofile.write(chunk)
            chunk_size = len(chunk)
            for _ in range(chunk_size, 0x1FC - 32):
                ofile.write(struct.pack("B", 0))
            ofile.write(UF2_MAGIC_END)
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
    print("program code and resources size: {} bytes".format(full_blocks_size + chunk_size))

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
