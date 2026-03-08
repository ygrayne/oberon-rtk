@echo off
rem OpenOCD for STM32U585 via J-Link probe (SWD)
rem xPack OpenOCD — Raspberry Pi fork does not have J-Link driver
rem GDB port: 3333
if not defined RTK_OPENOCD_XPACK set "RTK_OPENOCD_XPACK=C:\xPack\xpack-openocd-0.12.0-7\bin\openocd.exe"
"%RTK_OPENOCD_XPACK%" ^
  -f "C:\Users\gray\Projects\oberon\dev\oberon-rtk-claude\tools\config\OpenOCD\jlink-swd.cfg" ^
  -f target/stm32u5x.cfg ^
  -c "adapter speed 5000"
