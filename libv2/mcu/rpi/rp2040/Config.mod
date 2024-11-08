MODULE Config;
(**
  Oberon RTK Framework v2
  --
  Configurations and options
  --
  This module extends the Astrobe settings for memory allocation, which is reflected
  via module LinkOptions, for both cores, since the current versions of Astrobe
  don't offer memory settings for both cores.
  --
  * MCU: RP2040
  * Board: Pico
  Note: other boards with the RP2040 may offer more flash memory
  --
  Copyright (c) 2023-2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
  --
  The following settings in Astrobe regarding Data Range, Heap Start, and Heap Limit
  apply for core 0 only. The corresponding values for core 1 are defined as CONST below.
  * Data Range: 020000000H, 020030000H
  * Heap Start: 020000200H
  * Heap Limit: 000000000H
  The code range settings apply for both cores.
  * Code Range: 010000100H, 010200000H
  --
  Memory map SRAM:
  +---------------------------+
  |    core 1 stack           | 020040000H - 04H = CoreOneStackStart
  |                           |
 ~~~                         ~~~
  |                           |
  |    core 1 heap            | 020030200H = CoreOneHeapStart
  +---------------------------+
  |                           |
  |    core 1 vector table    | 020030000H = CoreOneDataStart = LinkOptions.DataEnd
  +---------------------------+
  |    module data (shared)   | shared as per MODULE separation/encapsulation
  |                           |
  +---------------------------+
  |    core 0 stack           | LinkOptions.StackStart
  |                           |
 ~~~                         ~~~
  |                           |
  |    core 0 heap            | 020000200H = LinkOptions.HeapStart
  +---------------------------+
  |                           |
  |    core 0 vector table    | 020000000H = LinkOptions.DataStart
  +---------------------------+

  Memory map flash:
                                010200000H = LinkOptions.CodeEnd
  +---------------------------+
  |                           |
  |                           |
 ~~~   code (shared)         ~~~
  |                           |
  |                           | 010000100H = LinkOptions.CodeStart
  +---------------------------+
  |    boot code              | 010000000H
  +---------------------------+
**)

  IMPORT LinkOptions, MCU := MCU2; (* LinkOptions must be first in list *)

  CONST
    MaxNumThreads* = 16;
    MaxNumProcs* = MaxNumThreads; (* legacy support *)
    NumCores* = MCU.NumCores;

    (* in and out buffer for messaging across cores *)
    MessagesMaxNumSndRcv* = 4;
    MessagesBufferSize* = 4;

    (* core 1 base storage parameters *)
    CoreOneDataStart*   = 020020000H;
    CoreOneHeapStart*   = 020020200H;
    CoreOneStackStart*  = 020040000H - 04H; (* use same semantics as Astrobe *)
    CoreOneHeapLimit*   = 0;

    CoreZeroMainStackSize* = 1024;
    CoreOneMainStackSize* = 1024;

    CoreZeroRamExtStart* = 020040000H;
    CoreZeroRamExtEnd* = CoreZeroRamExtStart + 01000H;
    CoreOneRamExtStart* = 020041000H;
    CoreOneRamExtEnd* = CoreOneRamExtStart + 01000H;

  VAR
    (* core 0 base storage parameters, collected from LinkOptions *)
    CoreZeroDataStart*: INTEGER;
    CoreZeroStackStart*: INTEGER;
    CoreZeroHeapStart*: INTEGER;
    CoreZeroHeapLimit*: INTEGER;

    (* core 0 and 1 shared code space in flash, collected from LinkOptions *)
    CodeStart*: INTEGER;
    CodeEnd*: INTEGER;

  PROCEDURE* init;
  BEGIN
    CoreZeroDataStart := LinkOptions.DataStart;
    CoreZeroStackStart := LinkOptions.StackStart;
    CoreZeroHeapStart := LinkOptions.HeapStart;
    CoreZeroHeapLimit := LinkOptions.HeapLimit;
    CodeStart := LinkOptions.CodeStart;
    CodeEnd := LinkOptions.CodeEnd
  END init;

BEGIN
  init
END Config.
