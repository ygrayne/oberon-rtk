#!/bin/bash
# ============================================================
#  Oberon RTK -- Environment Setup (bash)
# ============================================================
#
#  STATUS (2026-05-07):
#    This is a STUB. None of the tool paths are filled in
#    yet -- no dev tools have been installed on the target
#    macOS system, so concrete example values would be
#    misleading. The export lines below are commented out
#    as placeholders showing what each variable needs.
#    Fill them in (and uncomment) as you install each tool,
#    then `source` this file from ~/.bashrc (or ~/.zshrc).
#
#    The file can be sourced safely as-is -- it just won't
#    set any RTK_* vars until the lines are uncommented.
#
#  WHAT THIS DOES (when completed):
#    Exports all RTK_* environment variables that the
#    framework's tools, scripts, and VS Code launch
#    configurations expect.
#
#  WINDOWS USERS:
#    On Windows, use the sibling set-rtk-env.cmd. It is
#    complete (with example Windows paths) and persists via
#    setx so the values are visible to VS Code, Cortex-Debug,
#    and any tool launched from Start menu / Explorer (not
#    just from a shell). Git Bash inherits those values
#    automatically. This .sh exists as a portable sibling
#    for macOS setups.
#
#  Q: WHICH VARS DO I NEED?
#  A: Each var is read only by the tool that uses it.
#     Uncomment only the export lines for tools you actually
#     use; leave the rest commented out.
#
#     The "derived" sections below (SVD files, ARM ELF
#     attribute config, RP2040 boot2) follow RTK_REPO_ROOT
#     automatically; no edit needed there beyond uncommenting.
#
#     Levels:
#
#     Getting started, no debugging
#         Don't run this script. Use the Astrobe IDE to
#         build, drag-drop UF2 to your RP board (or vendor
#         flasher for STM32), observe via serial. No
#         RTK_* vars needed.
#
#     Build scripts
#         Uncomment:
#           RTK_REPO_ROOT
#           RTK_ASTROBE_*       for the Astrobe product(s)
#                               you build with (RP2350
#                               product builds RP2350 +
#                               STM32; RP2040 product builds
#                               RP2040)
#           RTK_ARM_ATTR_CFG    (derived)
#           RTK_BOOT2           (derived; for RP2040 builds
#                                via make-elf --boot2)
#         Enables single-image and S/NS builds for RP2040 /
#         RP2350 via the framework's build scripts. No
#         debugger yet -- run programs and observe via
#         serial as in the previous level.
#
#     With debugging
#         Additionally uncomment:
#           RTK_GDB, RTK_OBJDUMP
#           RTK_OPENOCD_RPI, RTK_OPENOCD_RPI_SCRIPTS  (RP)
#           RTK_SVD_RP2040, RTK_SVD_RP2350            (derived)
#         Covers manual OpenOCD via tools/server-scripts/,
#         manual gdb, and Cortex-Debug in VS Code on RP.
#
#     STM32 (alongside or instead of RP):
#         Uncomment RTK_OPENOCD_XPACK (U585), RTK_OPENOCD_STM
#         (_SCRIPTS) (H573), and RTK_SVD_STM32U585 / _H573
#         (the latter two only for debugging).
#
#     Bash build scripts on macOS:
#         Uncomment RTK_EXERUN (set to "mono").
#
#     Test engines (elftestengine / gdbtestengine):
#         Uncomment RTK_GDB_HOST.
#
#     check-elf:
#         Uncomment RTK_READELF.
#
#  HOW TO USE (when completed):
#    1. Open this file in an editor.
#    2. Adjust paths in the [EDIT] sections below to match
#       your installation. Sections without [EDIT] derive
#       from earlier vars and rarely need changes.
#    3. Save the file.
#    4. Add this line to ~/.bashrc (or ~/.zshrc on macOS
#       zsh) so the vars are exported in every new
#       interactive shell:
#         source <path-to-this-file>/set-rtk-env.sh
#       Then either open a new shell or run:
#         source ~/.bashrc
#    5. Verify with:    env | grep '^RTK_'
#
#  PROCESS-INHERITANCE NOTE:
#    Sourcing from .bashrc re-runs this script in every new
#    interactive shell, so each fresh shell picks up the
#    current values. But: a child process spawned from an
#    existing shell inherits that shell's env -- so if you
#    edit paths here and want them in already-running
#    shells, source again or restart them.
#
#  See "Environment Variables" in the RTK docs for what each
#  variable means.
# ============================================================


# === [EDIT] oberon-rtk repo location ========================
# Absolute path to your checkout of the oberon-rtk repo.
# Used by build scripts and debug-server scripts to compose
# paths to in-repo resources without hardcoding.

# export RTK_REPO_ROOT="<path-to-your-oberon-rtk-checkout>"


# === RTK_EXERUN: empty on Windows, "mono" on macOS ==========
# Prefix used by bash build scripts to wrap Windows .exe
# calls so the same script content runs on both platforms:
#   ${RTK_EXERUN} "${RTK_ASTROBE_BUILD_2350}" ...
# On macOS, set to "mono" so the .exe runs under the Mono
# framework. On Windows it is empty -- bash drops the prefix
# during word-splitting and the .exe runs directly.
# See "Astrobe on macOS" in the RTK docs for Mono setup.

# export RTK_EXERUN="mono"


# === [EDIT] Astrobe products ================================
# The _2350 / _2040 suffix is the Astrobe PRODUCT name, not
# the target MCU:
#   - Astrobe for RP2350 (M33 product) -- builds RP2350 + STM32
#   - Astrobe for RP2040 (M0+ product) -- builds RP2040
#
# On macOS, point these vars at where you have placed
# AstrobeBuild.exe / AstrobeLink.exe. Bash build scripts
# invoke them via the RTK_EXERUN prefix (defined above) so
# the same script content runs on Windows and macOS.
#
# RTK_ASTROBE_FOLDER_x is the value of the %AstrobeRP2350%
# (or %AstrobeRP2040%) substitution token as used in your
# Astrobe configuration files (.ini lib search paths).

# export RTK_ASTROBE_BUILD_2350="<path-to-AstrobeBuild>"
# export RTK_ASTROBE_LINK_2350="<path-to-AstrobeLink>"
# export RTK_ASTROBE_FOLDER_2350="<your astrobe folder>"

# export RTK_ASTROBE_BUILD_2040="<path-to-AstrobeBuild>"
# export RTK_ASTROBE_LINK_2040="<path-to-AstrobeLink>"
# export RTK_ASTROBE_FOLDER_2040="<your astrobe folder>"


# === [EDIT] ARM toolchain (xPack arm-none-eabi-gcc) =========
# GDB and objdump are used by Cortex-Debug; readelf by the
# check-elf tool.

# export RTK_GDB="<path-to>/arm-none-eabi-gdb-py3"
# export RTK_OBJDUMP="<path-to>/arm-none-eabi-objdump"
# export RTK_READELF="<path-to>/arm-none-eabi-readelf"


# === [EDIT] OpenOCD servers =================================
# Three OpenOCD variants, each from a different source:
#   XPACK -- xPack OpenOCD; used for STM32 (ST-LINK + J-Link)
#   RPI   -- Raspberry Pi fork; required for RP2350 target
#   STM   -- ST OpenOCD (from STM32CubeIDE); required for STM32H5

# export RTK_OPENOCD_XPACK="<path-to-xpack-openocd>/openocd"
# export RTK_OPENOCD_RPI="<path-to-rpi-fork>/openocd"
# export RTK_OPENOCD_STM="<path-to-st-openocd>/openocd"

# Vendor-bundled scripts directories (passed via OpenOCD's -s):
# export RTK_OPENOCD_RPI_SCRIPTS="<path>/scripts"
# export RTK_OPENOCD_STM_SCRIPTS="<path>/st_scripts"


# === SVD files (in-repo; derived from RTK_REPO_ROOT) ========
# Activate after RTK_REPO_ROOT is set above. No edit needed
# beyond uncommenting if the repo path is correct.

# export RTK_SVD_RP2040="$RTK_REPO_ROOT/targets/svd/rp2040-merged.svd.xml"
# export RTK_SVD_RP2350="$RTK_REPO_ROOT/targets/svd/rp2350-merged.svd.xml"
# export RTK_SVD_STM32U585="$RTK_REPO_ROOT/targets/svd/STM32U585-merged.svd.xml"
# export RTK_SVD_STM32H573="$RTK_REPO_ROOT/targets/svd/STM32H573-merged.svd.xml"


# === ARM ELF attribute config (in-repo; derived) ============

# export RTK_ARM_ATTR_CFG="$RTK_REPO_ROOT/targets/arm/arm-elf-attr.cfg"


# === RP2040 stage-2 boot loader (in-repo; derived) ==========
# Used by make-elf --boot2 for RP2040 ELF builds.

# export RTK_BOOT2="$RTK_REPO_ROOT/tools/boot2/boot2.bin"


# === GDB host (default; rarely changed) =====================
# Used by elftestengine and gdbtestengine when connecting to
# the GDB server. Override only if your GDB server runs on a
# non-default host:port.
#
# Note: Cortex-Debug (VS Code) does NOT consult this variable.
# Its GDB-server connection is configured per-project in
# launch.json (gdbTarget, etc.) and is independent of
# RTK_GDB_HOST.

# export RTK_GDB_HOST="localhost:3333"
