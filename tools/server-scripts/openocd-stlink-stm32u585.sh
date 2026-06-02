#!/bin/bash
# OpenOCD for STM32U585 via on-board ST-LINK/V3E (SWD)
# xPack OpenOCD
# GDB port: 3333
: "${RTK_OPENOCD_XPACK:?RTK_OPENOCD_XPACK not set}"
: "${RTK_REPO_ROOT:?RTK_REPO_ROOT not set}"
"$RTK_OPENOCD_XPACK" \
  -f "$RTK_REPO_ROOT/tools/server-scripts/openocd/stlink-swd.cfg" \
  -f target/stm32u5x.cfg \
  -c "adapter speed 3300" \
  -c "stm32u5x.cpu configure -event reset-end {adapter speed 3300}"
