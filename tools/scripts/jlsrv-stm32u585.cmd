@echo off
rem JLink GDB Server for STM32U585 via J-Link probe (SWD)
rem GDB port: 3333
if not defined RTK_JLINK set "RTK_JLINK=C:\Program Files\SEGGER\JLink_V876\JLinkGDBServerCL.exe"
"%RTK_JLINK%" ^
  -device STM32U585AI ^
  -if SWD ^
  -port 3333 ^
  -speed 4000 ^
  -silent ^
  -nogui
