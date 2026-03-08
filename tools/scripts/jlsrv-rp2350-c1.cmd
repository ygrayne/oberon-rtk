@echo off
rem JLink GDB Server for RP2350 Core 1 via J-Link probe (SWD)
rem GDB port: 3334
if not defined RTK_JLINK set "RTK_JLINK=C:\Program Files\SEGGER\JLink_V876\JLinkGDBServerCL.exe"
"%RTK_JLINK%" ^
  -device RP2350_M33_1 ^
  -if SWD ^
  -port 3334 ^
  -speed 4000 ^
  -silent ^
  -nogui
