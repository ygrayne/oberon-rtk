#!/bin/bash
# OpenOCD for STM32U585 via J-Link probe (SWD)
# xPack OpenOCD — Raspberry Pi fork does not have J-Link driver
# GDB port: 3333
: "${RTK_OPENOCD_XPACK:?RTK_OPENOCD_XPACK not set}"
: "${RTK_REPO_ROOT:?RTK_REPO_ROOT not set}"
"$RTK_OPENOCD_XPACK" \
  -f "$RTK_REPO_ROOT/tools/server-scripts/openocd/jlink-swd.cfg" \
  -f target/stm32u5x.cfg \
  -c "adapter speed 5000"
