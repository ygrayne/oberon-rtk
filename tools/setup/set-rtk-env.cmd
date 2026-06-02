@echo off
rem ============================================================
rem  Oberon RTK -- Environment Setup (Windows / cmd)
rem ============================================================
rem
rem  WHAT THIS DOES:
rem    Sets all RTK_* environment variables that the framework's
rem    tools, scripts, and VS Code launch configurations expect.
rem    Persists them via setx to your user environment
rem    (HKCU\Environment), so they survive across cmd sessions.
rem
rem  NOTE:
rem    The paths below are EXAMPLES from one development setup.
rem    Tool versions, install locations, and the user-account
rem    layout will likely differ on your machine -- treat every
rem    path here as a placeholder until you have verified it.
rem    Astrobe, xPack, and STM32CubeIDE in particular embed
rem    version numbers in their install paths (e.g., "Astrobe
rem    RP2350 v10.0.2", "xpack-openocd-0.12.0-7", "openocd.
rem    win32_2.4.300.202509300731") that will not match yours.
rem
rem  Q: WHICH VARS DO I NEED?
rem  A: This script ships configured for "Build scripts":
rem     command-line builds for RP2040, RP2350, and (with the
rem     STM32 additions below) STM32 -- enough to compile and
rem     link single-image and S/NS programs. No debugger
rem     toolchain is set up yet.
rem
rem     Each var is read only by the tool that uses it.
rem     Commenting out unused vars (rem-prefixed `set` AND
rem     corresponding `setx` lines) keeps your environment
rem     clean.
rem
rem     Levels:
rem
rem     Getting started, no debugging
rem         Don't run this script. Use the Astrobe IDE to
rem         build, drag-drop UF2 to your RP board (or vendor
rem         flasher for STM32), observe via serial. No
rem         RTK_* vars needed.
rem
rem     Build scripts                                   [SHIPPED]
rem         The active vars below: RTK_REPO_ROOT,
rem         RTK_ASTROBE_*, plus the derived RTK_ARM_ATTR_CFG
rem         and RTK_BOOT2 (RP2040 stage-2 boot loader).
rem         Enables single-image and S/NS builds for
rem         RP2040 / RP2350 via the framework's build
rem         scripts. No debugger yet -- run programs and
rem         observe via serial as in the previous level.
rem
rem     With debugging
rem         Uncomment, in addition:
rem           RTK_GDB, RTK_OBJDUMP
rem           RTK_OPENOCD_RPI, RTK_OPENOCD_RPI_SCRIPTS  (RP)
rem           RTK_SVD_RP2040, RTK_SVD_RP2350            (derived)
rem         Covers manual OpenOCD via tools/server-scripts/,
rem         manual gdb, and Cortex-Debug in VS Code on RP.
rem
rem     STM32 (alongside or instead of RP):
rem         Uncomment RTK_OPENOCD_XPACK (U585), RTK_OPENOCD_STM
rem         (_SCRIPTS) (H573), and RTK_SVD_STM32U585 / _H573
rem         (the latter two only for debugging).
rem
rem     Bash build scripts on macOS:
rem         Uncomment RTK_EXERUN (set to "mono") in the .sh.
rem
rem     Test engines (elftestengine / gdbtestengine):
rem         Uncomment RTK_GDB_HOST.
rem
rem     check-elf:
rem         Uncomment RTK_READELF.
rem
rem  HOW TO USE:
rem    1. Open this file in an editor.
rem    2. Adjust paths in the [EDIT] sections below to match
rem       your installation. Sections without [EDIT] derive from
rem       earlier vars and rarely need changes.
rem    3. Save the file.
rem    4. Open a regular (NOT admin) cmd window and run:
rem         tools\setup\set-rtk-env.cmd
rem    5. CLOSE every open terminal (cmd, Git Bash, Windows
rem       Terminal) and any app that needs the vars (VS Code,
rem       etc.). Then launch fresh from the Start menu, a
rem       desktop shortcut, or Win+R.
rem
rem       Why: a process inherits its environment from its
rem       parent. setx writes to the registry and broadcasts
rem       a refresh, but only Explorer reliably acts on the
rem       broadcast. So:
rem         - new cmd from Start / Win+R / shortcut  -> fresh env (parent = Explorer)
rem         - new cmd / bash from an existing cmd    -> stale env (inherits parent)
rem         - new tab in a running terminal app      -> stale env (inherits app)
rem         - VS Code reload                         -> stale (host process unchanged)
rem         - VS Code fully quit + reopen            -> fresh env
rem         - log out + log back in                  -> always fresh (nuclear)
rem
rem    6. Verify with:    set RTK_
rem
rem  TO CHANGE OR REMOVE A VAR LATER:
rem    Edit this file and re-run, or remove a single var with:
rem      reg delete HKCU\Environment /v RTK_FOO /f
rem
rem  See "Environment Variables" in the RTK docs for what each
rem  variable means.
rem ============================================================


rem === [EDIT] oberon-rtk repo location =========================
rem  Absolute path to your checkout of the oberon-rtk repo.
rem  Used by build scripts and debug-server scripts to compose
rem  paths to in-repo resources (config/, lib/, tools/...,
rem  targets/svd/) without hardcoding install locations.

set RTK_REPO_ROOT=%USERPROFILE%\Projects\oberon\dev\oberon-rtk


rem === RTK_EXERUN: empty on Windows, "mono" on macOS ===========
rem  Prefix used by bash build scripts to wrap Windows .exe
rem  calls so the same script content runs on both platforms:
rem    ${RTK_EXERUN} "${RTK_ASTROBE_BUILD_2350}" ...
rem  On Windows: empty (no wrapping needed).
rem  On macOS:   "mono" (set in set-rtk-env.sh).

rem set RTK_EXERUN=


rem === [EDIT] Astrobe products =================================
rem  The _2350 / _2040 suffix is the Astrobe PRODUCT name, not
rem  the target MCU:
rem    - Astrobe for RP2350 (M33 product) -- builds RP2350 + STM32
rem    - Astrobe for RP2040 (M0+ product) -- builds RP2040
rem
rem  RTK_ASTROBE_FOLDER_x is the value of the %AstrobeRP2350%
rem  (or %AstrobeRP2040%) substitution token as used in your
rem  Astrobe configuration files (.ini lib search paths).
rem  Whatever directory you have configured as the "Astrobe
rem  folder" in your setup goes here.

set RTK_ASTROBE_BUILD_2350=C:\Program Files\Astrobe RP2350 v10.0.2\AstrobeBuild.exe
set RTK_ASTROBE_LINK_2350=C:\Program Files\Astrobe RP2350 v10.0.2\AstrobeLink.exe
set RTK_ASTROBE_FOLDER_2350=%USERPROFILE%\Projects\oberon\dev

set RTK_ASTROBE_BUILD_2040=C:\Program Files\Astrobe RP2040 v9.0.0\AstrobeBuild.exe
set RTK_ASTROBE_LINK_2040=C:\Program Files\Astrobe RP2040 v9.0.0\AstrobeLink.exe
set RTK_ASTROBE_FOLDER_2040=%USERPROFILE%\Projects\oberon\dev


rem === [EDIT] ARM toolchain (xPack arm-none-eabi-gcc) ==========
rem  GDB and objdump are used by Cortex-Debug; readelf by the
rem  check-elf tool.

rem set RTK_GDB=C:\dev-tools\xPack\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin\arm-none-eabi-gdb-py3.exe
rem set RTK_OBJDUMP=C:\dev-tools\xPack\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin\arm-none-eabi-objdump.exe
rem set RTK_READELF=C:\dev-tools\xPack\xpack-arm-none-eabi-gcc-14.2.1-1.1\bin\arm-none-eabi-readelf.exe


rem === [EDIT] OpenOCD servers ==================================
rem  Three OpenOCD variants, each from a different source:
rem    XPACK -- xPack OpenOCD; used for STM32 (ST-LINK + J-Link)
rem    RPI   -- Raspberry Pi fork; required for RP2350 target
rem    STM   -- ST OpenOCD (from STM32CubeIDE); required for STM32H5

rem set RTK_OPENOCD_XPACK=C:\dev-tools\xPack\xpack-openocd-0.12.0-7\bin\openocd.exe
rem set RTK_OPENOCD_RPI=C:\dev-tools\RPI\openocd\openocd.exe
rem set RTK_OPENOCD_STM=C:\dev-tools\STM\STM32CubeIDE_2.0.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.externaltools.openocd.win32_2.4.300.202509300731\tools\bin\openocd.exe

rem  Vendor-bundled scripts directories (passed via OpenOCD's -s):
rem set RTK_OPENOCD_RPI_SCRIPTS=C:\dev-tools\RPI\openocd\scripts
rem set RTK_OPENOCD_STM_SCRIPTS=C:\dev-tools\STM\STM32CubeIDE_2.0.0\STM32CubeIDE\plugins\com.st.stm32cube.ide.mcu.debug.openocd_2.3.200.202510310951\resources\openocd\st_scripts


rem === SVD files (in-repo; derived from RTK_REPO_ROOT) =========
rem  No edit needed if RTK_REPO_ROOT above is correct.

rem set RTK_SVD_RP2040=%RTK_REPO_ROOT%\targets\svd\rp2040-merged.svd.xml
rem set RTK_SVD_RP2350=%RTK_REPO_ROOT%\targets\svd\rp2350-merged.svd.xml
rem set RTK_SVD_STM32U585=%RTK_REPO_ROOT%\targets\svd\STM32U585-merged.svd.xml
rem set RTK_SVD_STM32H573=%RTK_REPO_ROOT%\targets\svd\STM32H573-merged.svd.xml


rem === ARM ELF attribute config (in-repo; derived) =============

set RTK_ARM_ATTR_CFG=%RTK_REPO_ROOT%\targets\arm\arm-elf-attr.cfg


rem === RP2040 stage-2 boot loader (in-repo; derived) ===========
rem  Used by make-elf --boot2 for RP2040 ELF builds.

set RTK_BOOT2=%RTK_REPO_ROOT%\tools\boot2\boot2.bin


rem === GDB host (default; rarely changed) ======================
rem  Used by elftestengine and gdbtestengine when connecting to
rem  the GDB server. Override only if your GDB server runs on a
rem  non-default host:port.
rem
rem  Note: Cortex-Debug (VS Code) does NOT consult this variable.
rem  Its GDB-server connection is configured per-project in
rem  launch.json (gdbTarget, etc.) and is independent of
rem  RTK_GDB_HOST.

rem set RTK_GDB_HOST=localhost:3333


rem ============================================================
rem  Persist values to user environment (HKCU\Environment).
rem  Output suppressed; only errors will surface.
rem ============================================================

setx RTK_REPO_ROOT             "%RTK_REPO_ROOT%"             >nul
rem setx RTK_EXERUN                "%RTK_EXERUN%"                >nul
setx RTK_ASTROBE_BUILD_2350    "%RTK_ASTROBE_BUILD_2350%"    >nul
setx RTK_ASTROBE_LINK_2350     "%RTK_ASTROBE_LINK_2350%"     >nul
setx RTK_ASTROBE_FOLDER_2350   "%RTK_ASTROBE_FOLDER_2350%"   >nul
setx RTK_ASTROBE_BUILD_2040    "%RTK_ASTROBE_BUILD_2040%"    >nul
setx RTK_ASTROBE_LINK_2040     "%RTK_ASTROBE_LINK_2040%"     >nul
setx RTK_ASTROBE_FOLDER_2040   "%RTK_ASTROBE_FOLDER_2040%"   >nul
rem setx RTK_GDB                   "%RTK_GDB%"                   >nul
rem setx RTK_OBJDUMP               "%RTK_OBJDUMP%"               >nul
rem setx RTK_READELF               "%RTK_READELF%"               >nul
rem setx RTK_OPENOCD_XPACK         "%RTK_OPENOCD_XPACK%"         >nul
rem setx RTK_OPENOCD_RPI           "%RTK_OPENOCD_RPI%"           >nul
rem setx RTK_OPENOCD_STM           "%RTK_OPENOCD_STM%"           >nul
rem setx RTK_OPENOCD_RPI_SCRIPTS   "%RTK_OPENOCD_RPI_SCRIPTS%"   >nul
rem setx RTK_OPENOCD_STM_SCRIPTS   "%RTK_OPENOCD_STM_SCRIPTS%"   >nul
rem setx RTK_SVD_RP2040            "%RTK_SVD_RP2040%"            >nul
rem setx RTK_SVD_RP2350            "%RTK_SVD_RP2350%"            >nul
rem setx RTK_SVD_STM32U585         "%RTK_SVD_STM32U585%"         >nul
rem setx RTK_SVD_STM32H573         "%RTK_SVD_STM32H573%"         >nul
setx RTK_ARM_ATTR_CFG          "%RTK_ARM_ATTR_CFG%"          >nul
setx RTK_BOOT2                 "%RTK_BOOT2%"                 >nul
rem setx RTK_GDB_HOST              "%RTK_GDB_HOST%"              >nul

echo.
echo RTK environment variables persisted to HKCU\Environment.
echo.
echo To use them: close every open terminal and launch fresh
echo from the Start menu / shortcut (NOT from this or any
echo other already-running terminal). See header of this
echo script for the inheritance rules.
echo.
echo Verify with:  set RTK_
