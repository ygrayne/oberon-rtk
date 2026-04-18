#!/bin/bash
# OpenOCD for RP2350 via CMSIS-DAP probe (Picoprobe/debugprobe)
# Raspberry Pi OpenOCD fork
# GDB port: 3333
: "${RTK_OPENOCD_RPI:?RTK_OPENOCD_RPI not set}"
: "${RTK_OPENOCD_RPI_SCRIPTS:?RTK_OPENOCD_RPI_SCRIPTS not set}"
"$RTK_OPENOCD_RPI" \
  -s "$RTK_OPENOCD_RPI_SCRIPTS" \
  -f interface/cmsis-dap.cfg \
  -f target/rp2350.cfg \
  -c "adapter speed 5000"
