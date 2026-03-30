@echo off
rem OpenOCD for STM32U585 via on-board ST-LINK/V3E (SWD)
rem xPack OpenOCD
rem GDB port: 3333
if not defined RTK_OPENOCD_XPACK (echo RTK_OPENOCD_XPACK not set & exit /b 1)
if not defined RTK_OPENOCD_CFG_STLINK (echo RTK_OPENOCD_CFG_STLINK not set & exit /b 1)
"%RTK_OPENOCD_XPACK%" ^
  -f "%RTK_OPENOCD_CFG_STLINK%" ^
  -f target/stm32u5x.cfg ^
  -c "adapter speed 3300" ^
  -c "stm32u5x.cpu configure -event reset-end {adapter speed 3300}"
