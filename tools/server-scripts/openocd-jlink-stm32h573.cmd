@echo off
rem OpenOCD for STM32H573 via J-Link probe (SWD)
rem Uses ST's OpenOCD from STM32CubeIDE (xPack lacks stm32h5x target)
rem GDB port: 3333
set ST_OPENOCD=C:\ST\STM32CubeIDE_2.0.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.openocd.win32_2.4.300.202509300731\tools\bin\openocd.exe
set ST_SCRIPTS=C:\ST\STM32CubeIDE_2.0.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.debug.openocd_2.3.200.202510310951\resources\openocd\st_scripts
if not defined RTK_OPENOCD_CFG_JLINK (echo RTK_OPENOCD_CFG_JLINK not set & exit /b 1)
"%ST_OPENOCD%" ^
  -s "%ST_SCRIPTS%" ^
  -f "%RTK_OPENOCD_CFG_JLINK%" ^
  -c "set CONNECT_UNDER_RESET 1"^
  -f target/stm32h5x.cfg ^
  -c "adapter speed 5000"
