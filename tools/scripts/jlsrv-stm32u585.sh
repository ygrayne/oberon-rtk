#!/bin/bash
# JLink GDB Server for STM32U585 via J-Link probe (SWD)
# GDB port: 3333
JLINK="${RTK_JLINK:-C:/Program Files/SEGGER/JLink_V876/JLinkGDBServerCL.exe}"
"$JLINK" \
  -device STM32U585AI \
  -if SWD \
  -port 3333 \
  -speed 4000 \
  -silent \
  -nogui
