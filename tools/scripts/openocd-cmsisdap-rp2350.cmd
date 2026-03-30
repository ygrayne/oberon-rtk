@echo off
rem OpenOCD for RP2350 via CMSIS-DAP probe (Picoprobe/debugprobe)
rem Raspberry Pi OpenOCD fork
rem GDB port: 3333
if not defined RTK_OPENOCD_RPI (echo RTK_OPENOCD_RPI not set & exit /b 1)
for %%I in ("%RTK_OPENOCD_RPI%") do set "OPENOCD_SCRIPTS=%%~dpIscripts"
"%RTK_OPENOCD_RPI%" ^
  -s "%OPENOCD_SCRIPTS%" ^
  -f interface/cmsis-dap.cfg ^
  -f target/rp2350.cfg ^
  -c "adapter speed 5000"
