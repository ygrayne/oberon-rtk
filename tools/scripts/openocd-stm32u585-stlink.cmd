@echo off
rem OpenOCD for STM32U585 via on-board ST-LINK/V3E (SWD)
rem xPack OpenOCD
rem GDB port: 3333
if not defined RTK_OPENOCD_XPACK set "RTK_OPENOCD_XPACK=C:\xPack\xpack-openocd-0.12.0-7\bin\openocd.exe"
"%RTK_OPENOCD_XPACK%" ^
  -f "C:\Users\gray\Projects\oberon\dev\oberon-rtk-claude\tools\config\OpenOCD\stlink-swd.cfg" ^
  -f target/stm32u5x.cfg ^
  -c "adapter speed 3300" ^
  -c "stm32u5x.cpu configure -event reset-end {adapter speed 3300}"
