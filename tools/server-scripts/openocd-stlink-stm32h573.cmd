@echo off
rem OpenOCD for STM32H573 via on-board ST-LINK/V3E (SWD)
rem Uses ST's OpenOCD from STM32CubeIDE (xPack lacks stm32h5x target)
rem GDB port: 3333
if not defined RTK_OPENOCD_STM (echo RTK_OPENOCD_STM not set & exit /b 1)
if not defined RTK_OPENOCD_STM_SCRIPTS (echo RTK_OPENOCD_STM_SCRIPTS not set & exit /b 1)
"%RTK_OPENOCD_STM%" ^
  -s "%RTK_OPENOCD_STM_SCRIPTS%" ^
  -f interface/stlink-dap.cfg ^
  -c "set CONNECT_UNDER_RESET 1"^
  -f target/stm32h5x.cfg ^
  -c "adapter speed 3300"
