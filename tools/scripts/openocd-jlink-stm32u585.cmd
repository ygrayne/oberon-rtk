@echo off
rem OpenOCD for STM32U585 via J-Link probe (SWD)
rem xPack OpenOCD — Raspberry Pi fork does not have J-Link driver
rem GDB port: 3333
if not defined RTK_OPENOCD_XPACK (echo RTK_OPENOCD_XPACK not set & exit /b 1)
if not defined RTK_OPENOCD_CFG_JLINK (echo RTK_OPENOCD_CFG_JLINK not set & exit /b 1)
"%RTK_OPENOCD_XPACK%" ^
  -f "%RTK_OPENOCD_CFG_JLINK%" ^
  -f target/stm32u5x.cfg ^
  -c "adapter speed 5000"
