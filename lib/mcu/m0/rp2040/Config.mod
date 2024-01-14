MODULE Config;
(**
  Oberon RTK Framework
  Configurations and options
  Extending LinkOptions for two cores
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2023 Gray, gray@grayraven.org
  --
  Settings for Astrobe:
  * Data Range: 020000000H, 020030000H
  * Code Range: 010000100H, 010200000H
  * Heap Start: 020000200H
  * Heap Limit: 000000000H
  These values are collected from LinkOptions.
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
  |                           |
 ~~~                         ~~~
  |                           |
  |                           |
  |    core 0 heap            | 020000200H = LinkOptions.HeapStart
  +---------------------------+
  |                           |
  |    core 0 vector table    | 020000000H = LinkOptions.DataStart
  +---------------------------+

  Memory map FLASH:
                                010200000H = LinkOptions.CodeEnd
  +---------------------------+
  |                           |
  |                           |
 ~~~   code (shared)         ~~~
  |                           |
  |                           | 010000100H = LinkOptions.CodeStart
  +---------------------------+
  |    boot code phase 2      | 010000000H
  +---------------------------+
**)

  IMPORT LinkOptions, MCU := MCU2; (* LinkOptions must be first in list *)

  CONST
    MaxNumThreads* = 16;
    MaxNumProcs* = MaxNumThreads; (* legacy support *)
    NumCores* = MCU.NumCores;

    (* core one base storage parameters *)
    CoreOneDataStart* = 020030000H;
    CoreOneStackStart* = 020040000H - 04H;
    CoreOneHeapStart*  = 020030200H;
    CoreOneHeapLimit* = 0;

    CoreZeroMainStackSize* = 1024;
    CoreOneMainStackSize* = 1024;

  VAR
    CoreZeroDataStart*: INTEGER;
    CoreZeroStackStart*: INTEGER;
    CoreZeroHeapStart*: INTEGER;
    CoreZeroHeapLimit*: INTEGER;

    CodeStart*: INTEGER;
    CodeEnd*: INTEGER;

  PROCEDURE init;
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
