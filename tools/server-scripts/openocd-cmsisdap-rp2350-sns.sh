#!/bin/bash
# OpenOCD for RP2350 S/NS via CMSIS-DAP probe (Picoprobe/debugprobe)
# Raspberry Pi OpenOCD fork
# Adds virtual flash bank at 0x10400000 for NS debugging with address translation
# GDB port: 3333
: "${RTK_OPENOCD_RPI:?RTK_OPENOCD_RPI not set}"
: "${RTK_OPENOCD_RPI_SCRIPTS:?RTK_OPENOCD_RPI_SCRIPTS not set}"
"$RTK_OPENOCD_RPI" \
  -s "$RTK_OPENOCD_RPI_SCRIPTS" \
  -f interface/cmsis-dap.cfg \
  -f target/rp2350.cfg \
  -c "adapter speed 5000" \
  -c "flash bank rp2350.ns_flash virtual 0x10400000 0 0 0 rp2350.cm0 rp2350.flash"
