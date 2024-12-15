MODULE Config;
(**
  Oberon RTK Framework v2
  --
  Memory configuration and link data
  --
  This module extends Astrobe's module LinkOptions with configuration settings
  for dual-core programs. LinkOptions reflects the values in the Astrobe config
  settings and files, which do not offer memory settings for both cores.
  --
  * MCU: RP2040
  * Board: Pico
  --
  See:
  * https://oberon-rtk.org/lib/rp-any/config/
  * the Astrobe config files for specific settings
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
  --
  Memory map SRAM:
  +---------------------------+
  |    core 1 stack           | CoreOneStackStart
  |                           |
 ~~~                         ~~~
  |                           |
  |    core 1 heap            | CoreOneHeapStart
  +---------------------------+
  |    core 1 vector table    | CoreZeroDataEnd = CoreOneDataStart = LinkOptions.DataEnd
  +---------------------------+
  |                           |
  |    module data (shared)   | shared as per MODULE
  |                           | separation/encapsulation
  +---------------------------+
  |    core 0 stack           | LinkOptions.StackStart
  |                           |
 ~~~                         ~~~
  |                           |
  |    core 0 heap            | CoreZeroHeapStart = LinkOptions.HeapStart
  +---------------------------+
  |    core 0 vector table    | CoreZeroDataStart = LinkOptions.DataStart
  +---------------------------+

  Memory map flash memory (XIP):
                                CodeEnd = LinkOptions.CodeEnd
  +---------------------------+
  |                           |
  |                           |
 ~~~   code (shared)         ~~~
  |                           |
  |                           | CodeStart = LinkOptions.CodeStart
  +---------------------------+
**)

  IMPORT LinkOptions, MCU := MCU2; (* LinkOptions must be first in list *)

  CONST
    (* core 1 base settings *)
    CoreOneStackStart* = MCU.SRAM_MAIN_TOP - 04H;
    CoreOneHeapLimit*  = 0;

    (* extended SRAM blocks 4k *)
    CoreZeroRamExtStart* = MCU.SRAM_EXT0;
    CoreZeroRamExtEnd* = CoreZeroRamExtStart + 01000H;
    CoreOneRamExtStart* = MCU.SRAM_EXT1;
    CoreOneRamExtEnd* = CoreOneRamExtStart + 01000H;

  VAR
    (* core 0 storage parameters, collected from LinkOptions *)
    CoreZeroDataStart*: INTEGER;
    CoreZeroDataEnd*: INTEGER;
    CoreZeroStackStart*: INTEGER;
    CoreZeroHeapStart*: INTEGER;
    CoreZeroHeapLimit*: INTEGER;

    (* core 1 storage parameters, derived from core 0 values *)
    CoreOneDataStart*: INTEGER;
    CoreOneHeapStart*: INTEGER;

    (* core 0 and 1 shared code space in flash, collected from LinkOptions *)
    CodeStart*: INTEGER;
    CodeEnd*: INTEGER;

    (* Resources block at the end of the program *)
    ResourceStart*: INTEGER;

    (* module data space *)
    ModuleDataStart*: INTEGER;
    ModuleDataEnd*: INTEGER;

  PROCEDURE* init;
  BEGIN
    (* core zero *)
    CoreZeroDataStart := LinkOptions.DataStart;
    CoreZeroDataEnd := LinkOptions.DataEnd;
    CoreZeroHeapStart := LinkOptions.HeapStart;
    CoreZeroStackStart := LinkOptions.StackStart;
    CoreZeroHeapLimit := LinkOptions.HeapLimit;
    (* core 1, see also relevant CONSTs above *)
    CoreOneDataStart := CoreZeroDataEnd;
    CoreOneHeapStart := CoreOneDataStart + (CoreZeroHeapStart - CoreZeroDataStart);
    (* code and resources *)
    CodeStart := LinkOptions.CodeStart;
    CodeEnd := LinkOptions.CodeEnd;
    ResourceStart := LinkOptions.ResourceStart;
    (* module data *)
    ModuleDataStart := CoreZeroStackStart + 04H;
    ModuleDataEnd := CoreZeroDataEnd
  END init;

BEGIN
  init
END Config.
