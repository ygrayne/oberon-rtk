#!/bin/bash
# OpenOCD for STM32U585 via on-board ST-LINK/V3E (SWD)
# xPack OpenOCD
# GDB port: 3333
OPENOCD="${RTK_OPENOCD_XPACK:-C:/xPack/xpack-openocd-0.12.0-7/bin/openocd.exe}"
"$OPENOCD" \
  -f "C:/Users/gray/Projects/oberon/dev/oberon-rtk/tools/config/OpenOCD/stlink-swd.cfg" \
  -f target/stm32u5x.cfg \
  -c "adapter speed 3300" \
  -c "stm32u5x.cpu configure -event reset-end {adapter speed 3300}"
