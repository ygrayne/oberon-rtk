#!/bin/bash
# OpenOCD for RP2350 via CMSIS-DAP probe (Picoprobe/debugprobe)
# Raspberry Pi OpenOCD fork
# GDB port: 3333
OPENOCD="${RTK_OPENOCD_RPI:-C:/RPI/openocd/openocd.exe}"
"$OPENOCD" \
  -s "$(dirname "$OPENOCD")/scripts" \
  -f interface/cmsis-dap.cfg \
  -f target/rp2350.cfg \
  -c "adapter speed 5000"
