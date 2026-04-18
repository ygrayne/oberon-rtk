MODULE ClockOut;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Clock out via GPIO.
  --
  Type: MCU
  --
  The GPIO pin and pad used must be configured by the client module or program.
  --
  MCU: RP2040, RP2350A, RP2350B
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, SYS := CLK_SYS, Errors;

  CONST
    COUT0* = 0; (* => pin 21 *)
    COUT1* = 1; (* => pin 23 *)
    COUT2* = 2; (* => pin 24 *)
    COUT3* = 3; (* => pin 25 *)
    ClocksOut = {COUT0 .. COUT3};


  PROCEDURE Start*(coutNo, auxSrc, freqDivInt, freqDivFrac: INTEGER);
    VAR x, addr: INTEGER;
  BEGIN
    ASSERT(coutNo IN ClocksOut, Errors.PreCond);
    addr := SYS.CLK_GPOUT0_CTRL + (coutNo * SYS.CLK_GPOUT_Offset);
    x := LSL(auxSrc, SYS.CLK_GPOUT_CTRL_AUXSRC_0);
    SYSTEM.PUT(addr, x);
    x := freqDivFrac;
    x := x + LSL(freqDivInt, SYS.CLK_GPOUT_DIV_INT_0);
    SYSTEM.PUT(addr + SYS.CLK_GPOUT_DIV_Offset, x);
    SYSTEM.PUT(addr + BASE.ASET, {SYS.CLK_GPOUT_CTRL_ENABLE})
  END Start;


  PROCEDURE Stop*(coutNo: INTEGER);
    VAR addr: INTEGER;
  BEGIN
    ASSERT(coutNo IN ClocksOut, Errors.ProgError);
    addr := SYS.CLK_GPOUT0_CTRL + (coutNo * SYS.CLK_GPOUT_Offset);
    SYSTEM.PUT(addr + BASE.ASET, {SYS.CLK_GPOUT_CTRL_ENABLE})
  END Stop;

END ClockOut.
