@echo off
rem OpenOCD for STM32U585 via J-Link probe (SWD)
rem xPack OpenOCD — Raspberry Pi fork does not have J-Link driver
rem GDB port: 3333
if not defined RTK_OPENOCD_XPACK (echo RTK_OPENOCD_XPACK not set & exit /b 1)
if not defined RTK_REPO_ROOT (echo RTK_REPO_ROOT not set & exit /b 1)
"%RTK_OPENOCD_XPACK%" ^
  -f "%RTK_REPO_ROOT%\tools\server-scripts\openocd\jlink-swd.cfg" ^
  -f target/stm32u5x.cfg ^
  -c "adapter speed 5000"
