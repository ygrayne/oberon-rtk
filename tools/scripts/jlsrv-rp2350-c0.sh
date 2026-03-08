#!/bin/bash
# JLink GDB Server for RP2350 Core 0 via J-Link probe (SWD)
# GDB port: 3333
JLINK="${RTK_JLINK:-C:/Program Files/SEGGER/JLink_V876/JLinkGDBServerCL.exe}"
"$JLINK" \
  -device RP2350_M33_0 \
  -if SWD \
  -port 3333 \
  -speed 4000 \
  -silent \
  -nogui
