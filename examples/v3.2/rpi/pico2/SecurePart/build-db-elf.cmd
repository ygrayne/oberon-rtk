@echo off
rem Build script for Secure7: RP2350 S/NS, dual image, partition table.
rem Includes DWARF debug data (use with Cortex-Debug or manual gdb).
rem For a non-debug build, see build-elf.cmd in this directory.
rem Run from this project directory. Stops on first failed step.

rem === Required env vars ===
if not defined RTK_ASTROBE_BUILD_2350 (echo RTK_ASTROBE_BUILD_2350 not set & exit /b 1)
if not defined RTK_ASTROBE_LINK_2350 (echo RTK_ASTROBE_LINK_2350 not set & exit /b 1)
if not defined RTK_ASTROBE_FOLDER_2350 (echo RTK_ASTROBE_FOLDER_2350 not set & exit /b 1)


rem === Variables (paths relative to this directory) ===

rem Tools
set ASTROBE_BUILD=%RTK_ASTROBE_BUILD_2350%
set ASTROBE_LINK=%RTK_ASTROBE_LINK_2350%
set ASTROBE_FOLDER=%RTK_ASTROBE_FOLDER_2350%

rem Secure
set S_INI=sec\v31-rp2350-pico2-securepart-s.ini
set S_MOD=sec\S.mod
set S_MAP=sec\S.map
set S_BIN=sec\S.bin
set S_RDB=sec\rdb
set S_ADDR=10000100
set S_SYM=S

rem Non-secure
set NS_INI=nonsec\v31-rp2350-pico2-securepart-ns.ini
set NS_MOD=nonsec\NS.mod
set NS_MAP=nonsec\NS.map
set NS_BIN=nonsec\NS.bin
set NS_RDB=nonsec\rdb
set NS_ADDR=10000000
set NS_SYM=NS

rem gen-secure
set NSC_BIN=sec\nsc\NSC.bin
set NSC_ADDR=1007E000
set NSC_DIR=sec/nsc
set NS_OUT_DIR=nonsec\ns_
set CONST_LEAF=BASE

rem gen-secure & sec-epilogue
set NSC_MODULES=sec\S0.mod

rem make-elf flags (--debug or empty)
set DEBUG=--debug

rem sec-epilogue flags (--no-clear or empty)
set NOCLEAR=--no-clear


rem === Build sequence ===
rem AstrobeBuild and AstrobeLink require absolute paths; converted inline via %CD%\.
rem Other tools accept relative paths.
rem
rem Two-pass S compile (initial / final) is required because
rem sec-epilogue needs fresh .lst files to compute the BXNS
rem epilogue, and modifies the .mod source to insert it. The
rem final compile re-builds only the touched modules. If
rem Astrobe ever supports S compilation natively, this two-pass
rem dance becomes unnecessary.
rem
rem No build-clean step: RP2350 uses a single BASE module for
rem both S and NS, so framework artefacts are reusable across
rem the two builds (in contrast to STM32, where S and NS use
rem different BASE variants and need cross-side cleaning).
rem
rem AstrobeBuild and AstrobeLink stdout is suppressed: their
rem output is useful interactively but doesn't suit a build-
rem script context. Echo lines below trace the sequence so
rem progress is visible.

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
python -m gen-rdb %S_MAP% --rdb-dir %S_RDB% --nsc-dir %NSC_DIR%  || exit /b
python -m make-elf %S_BIN%:%S_ADDR% %NSC_BIN%:%NSC_ADDR% --image-def --rdb-dir %S_RDB% %DEBUG% --sym-prefix %S_SYM% || exit /b

echo Compile NS ...
"%ASTROBE_BUILD%" "%ASTROBE_FOLDER%" "%CD%\%NS_INI%" "%CD%\%NS_MOD%"   >nul 2>&1   || ( echo AstrobeBuild NS failed & exit /b 1 )
echo Link NS ...
"%ASTROBE_LINK%" "%ASTROBE_FOLDER%" "%CD%\%NS_INI%" "%CD%\%NS_MOD%"   >nul 2>&1   || ( echo AstrobeLink NS failed & exit /b 1 )
python -m gen-rdb %NS_MAP% --rdb-dir %NS_RDB%  || exit /b
python -m make-elf %NS_BIN%:%NS_ADDR% --rdb-dir %NS_RDB% %DEBUG% --sym-prefix %NS_SYM%  || exit /b

echo.
echo Build complete: sec\S.elf, nonsec\NS.elf
