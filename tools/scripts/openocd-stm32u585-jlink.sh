#!/bin/bash
# OpenOCD for STM32U585 via J-Link probe (SWD)
# xPack OpenOCD — Raspberry Pi fork does not have J-Link driver
# GDB port: 3333
OPENOCD="${RTK_OPENOCD_XPACK:-C:/xPack/xpack-openocd-0.12.0-7/bin/openocd.exe}"
"$OPENOCD" \
  -f "C:/Users/gray/Projects/oberon/dev/oberon-rtk/tools/config/OpenOCD/jlink-swd.cfg" \
  -f target/stm32u5x.cfg \
  -c "adapter speed 5000"
