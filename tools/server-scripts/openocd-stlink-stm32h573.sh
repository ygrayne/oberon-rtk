#!/bin/bash
# OpenOCD for STM32H573 via on-board ST-LINK/V3E (SWD)
# Uses ST's OpenOCD from STM32CubeIDE (xPack lacks stm32h5x target)
# GDB port: 3333
: "${RTK_OPENOCD_STM:?RTK_OPENOCD_STM not set}"
: "${RTK_OPENOCD_STM_SCRIPTS:?RTK_OPENOCD_STM_SCRIPTS not set}"
"$RTK_OPENOCD_STM" \
  -s "$RTK_OPENOCD_STM_SCRIPTS" \
  -f interface/stlink-dap.cfg \
  -c "set CONNECT_UNDER_RESET 1" \
  -f target/stm32h5x.cfg \
  -c "adapter speed 3300"
