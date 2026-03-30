#!/bin/bash
# OpenOCD for STM32U585 via on-board ST-LINK/V3E (SWD)
# xPack OpenOCD
# GDB port: 3333
: "${RTK_OPENOCD_XPACK:?RTK_OPENOCD_XPACK not set}"
: "${RTK_OPENOCD_CFG_STLINK:?RTK_OPENOCD_CFG_STLINK not set}"
"$RTK_OPENOCD_XPACK" \
  -f "$RTK_OPENOCD_CFG_STLINK" \
  -f target/stm32u5x.cfg \
  -c "adapter speed 3300" \
  -c "stm32u5x.cpu configure -event reset-end {adapter speed 3300}"
