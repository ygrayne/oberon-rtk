MODULE MultiCore;
(**
  Oberon RTK Framework v2
  --
  Multi-core handling
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Memory;

  CONST
    (* fifo bits *)
    (* ST_ROE = 3; *)
    (* ST_WOF = 2; *)
    ST_RDY = 1;
    ST_VLD = 0;

    SEV = 0BF40H;

  TYPE
    FifoValue* = ARRAY 4 OF BYTE; (* compatible with any 4-byte data structure, incl. basic types *)

  VAR
    runInit, runStart: PROCEDURE;

  PROCEDURE* CPUid*(): INTEGER;
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, x);
    RETURN x
  END CPUid;


  PROCEDURE* Send*(value: FifoValue);
  BEGIN
    SYSTEM.PUT(MCU.SIO_FIFO_WR, value)
  END Send;


  PROCEDURE* Receive*(VAR value: FifoValue);
  BEGIN
    SYSTEM.GET(MCU.SIO_FIFO_RD, value)
  END Receive;


  PROCEDURE* Valid*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.SIO_FIFO_ST, ST_VLD)
  END Valid;


  PROCEDURE* Ready*(): BOOLEAN;
    RETURN SYSTEM.BIT(MCU.SIO_FIFO_ST, ST_RDY)
  END Ready;


  PROCEDURE Flush*;
  (* flush read channel *)
    VAR x: INTEGER;
  BEGIN
    WHILE SYSTEM.BIT(MCU.SIO_FIFO_ST, ST_VLD) DO
      SYSTEM.GET(MCU.SIO_FIFO_RD, x)
    END
  END Flush;


  PROCEDURE InitCoreOne*(startProc: PROCEDURE; stkPtr, vtor: INTEGER);
  (* get core 1 initially up and running *)
  (* core 1 is WFE-ing in its bootloader, awaiting the sequence below in the FIFO *)
    VAR cmd: ARRAY 6 OF INTEGER; i, x: INTEGER;
  BEGIN
    cmd[0] := 0; cmd[1] := 0; cmd[2] := 1; (* magic numbers *)
    cmd[3] := vtor; cmd[4] := stkPtr;
    cmd[5] := SYSTEM.VAL(INTEGER, startProc);
    INCL(BITS(cmd[5]), 0); (* thumb code *)
    i := 0;
    Flush;
    REPEAT
      SYSTEM.EMITH(SEV);
      (* send value *)
      REPEAT UNTIL Ready();
      Send(cmd[i]);
      SYSTEM.EMITH(SEV);
      (* receive value *)
      REPEAT UNTIL Valid();
      Receive(x);
      (* echo-ed correctly? *)
      IF x = cmd[i] THEN
        INC(i) (* OK, go ahead *)
      ELSE
        i := 0 (* oops, start over *)
      END
    UNTIL i = LEN(cmd)
  END InitCoreOne;


  PROCEDURE init;
  BEGIN
    IF runInit # NIL THEN
      runInit
    END;
    runStart
  END init;


  PROCEDURE StartCoreOne*(startProc, initProc: PROCEDURE);
    CONST Core1 = 1;
  BEGIN
    runInit := initProc;
    runStart := startProc;
    InitCoreOne(init, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart)
  END StartCoreOne;

END MultiCore.
