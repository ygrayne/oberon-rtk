#!/bin/bash
# OpenOCD for STM32U585 via J-Link probe (SWD)
# xPack OpenOCD — Raspberry Pi fork does not have J-Link driver
# GDB port: 3333
: "${RTK_OPENOCD_XPACK:?RTK_OPENOCD_XPACK not set}"
: "${RTK_OPENOCD_CFG_JLINK:?RTK_OPENOCD_CFG_JLINK not set}"
"$RTK_OPENOCD_XPACK" \
  -f "$RTK_OPENOCD_CFG_JLINK" \
  -f target/stm32u5x.cfg \
  -c "adapter speed 5000"
