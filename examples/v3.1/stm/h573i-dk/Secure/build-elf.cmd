@echo off
rem Build script for Secure: STM32H573 (H573I-DK) S/NS, dual image.
rem Non-debug build (no DWARF, no rdb data, minimal ELF).
rem For a build with debug data, see build-db-elf.cmd in this directory.
rem Run from this project directory. Stops on first failed step.


rem === Required env vars ===
if not defined RTK_ASTROBE_BUILD_2350 (echo RTK_ASTROBE_BUILD_2350 not set & exit /b 1)
if not defined RTK_ASTROBE_LINK_2350 (echo RTK_ASTROBE_LINK_2350 not set & exit /b 1)
if not defined RTK_ASTROBE_FOLDER_2350 (echo RTK_ASTROBE_FOLDER_2350 not set & exit /b 1)


rem === Variables (paths relative to this directory) ===

rem Tools (Astrobe for RP2350 product, used for STM32 M33 builds too)
set ASTROBE_BUILD=%RTK_ASTROBE_BUILD_2350%
set ASTROBE_LINK=%RTK_ASTROBE_LINK_2350%
set ASTROBE_FOLDER=%RTK_ASTROBE_FOLDER_2350%

rem Secure
set S_INI=sec\v31-stm32h573-dk-secure-s.ini
set S_MOD=sec\S.mod
set S_MAP=sec\S.map
set S_BIN=sec\S.bin
set S_ADDR=0C000000

rem Non-secure
set NS_INI=nonsec\v31-stm32h573-dk-secure-ns.ini
set NS_MOD=nonsec\NS.mod
set NS_BIN=nonsec\NS.bin
set NS_ADDR=08100000

rem gen-secure
set NSC_BIN=sec\NSC.bin
set NSC_ADDR=0C0FE000
set NSC_DIR=sec
set NS_OUT_DIR=nonsec\ns_
set CONST_LEAF=BASE

rem gen-secure & sec-epilogue
set NSC_MODULES=sec\S0.mod

rem sec-epilogue flags (--no-clear or empty)
set NOCLEAR=--no-clear

rem build-clean flags (--deep or empty)
set DEEP=


rem === Build sequence ===
rem AstrobeBuild and AstrobeLink require absolute paths; converted inline via %CD%\.
rem Other tools accept relative paths.
rem
rem build-clean steps before S and before NS: STM32 dual-image
rem needs framework .arm files recompiled against the relevant
rem side's BASE (different for S and NS); without the clean,
rem AstrobeLink reports "wrong version" errors. The pre-S clean
rem removes any leftovers from a previous NS build of the same
rem project; the pre-NS clean removes the just-built S artefacts.
rem
rem Two-pass S compile (initial / final) is required because
rem sec-epilogue needs fresh .lst files to compute the BXNS
rem epilogue, and modifies the .mod source to insert it. The
rem final compile re-builds only the touched modules. If
rem Astrobe ever supports S compilation natively, this two-pass
rem dance becomes unnecessary.
rem
rem No gen-rdb step and no --debug / --rdb-dir / --sym-prefix
rem flags on make-elf: this is a non-debug build, so symbol
rem info and DWARF are not produced. The resulting ELFs carry
rem only the binary -- enough to flash and run, not enough for
rem source-level debugging.
rem
rem AstrobeBuild and AstrobeLink stdout is suppressed: their
rem output is useful interactively but doesn't suit a build-
rem script context. Echo lines below trace the sequence so
rem progress is visible.

python -m build-clean "%ASTROBE_FOLDER%" %S_INI% %S_MOD% %DEEP% || exit /b

echo Compile S (initial) ...
"%ASTROBE_BUILD%" "%ASTROBE_FOLDER%" "%CD%\%S_INI%" "%CD%\%S_MOD%"   >nul 2>&1   || ( echo AstrobeBuild S ^(initial^) failed & exit /b 1 )
python -m sec-epilogue %NOCLEAR% %NSC_MODULES% || exit /b
echo Compile S ...
"%ASTROBE_BUILD%" "%ASTROBE_FOLDER%" "%CD%\%S_INI%" "%CD%\%S_MOD%"   >nul 2>&1   || ( echo AstrobeBuild S failed & exit /b 1 )
echo Link S ...
"%ASTROBE_LINK%" "%ASTROBE_FOLDER%" "%CD%\%S_INI%" "%CD%\%S_MOD%"   >nul 2>&1   || ( echo AstrobeLink S failed & exit /b 1 )
rem temp workaround: clear stale gen-secure outputs (NS_*.*) before regenerating
del /q "%NS_OUT_DIR%\NS_*.*" 2>nul
python -m gen-secure %S_MAP% --nsc-addr %NSC_ADDR% --ns-dir %NS_OUT_DIR% --nsc-dir %NSC_DIR% --const-leaf %CONST_LEAF% %NSC_MODULES%   || exit /b
python -m make-elf %S_BIN%:%S_ADDR% %NSC_BIN%:%NSC_ADDR% || exit /b

python -m build-clean "%ASTROBE_FOLDER%" %NS_INI% %NS_MOD% %DEEP% || exit /b

echo Compile NS ...
"%ASTROBE_BUILD%" "%ASTROBE_FOLDER%" "%CD%\%NS_INI%" "%CD%\%NS_MOD%"   >nul 2>&1   || ( echo AstrobeBuild NS failed & exit /b 1 )
echo Link NS ...
"%ASTROBE_LINK%" "%ASTROBE_FOLDER%" "%CD%\%NS_INI%" "%CD%\%NS_MOD%"   >nul 2>&1   || ( echo AstrobeLink NS failed & exit /b 1 )
python -m make-elf %NS_BIN%:%NS_ADDR% || exit /b

echo.
echo Build complete (no debug data): sec\S.elf, nonsec\NS.elf
