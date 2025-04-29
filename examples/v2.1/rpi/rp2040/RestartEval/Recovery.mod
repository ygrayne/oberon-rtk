MODULE Recovery;
(**
  Oberon RTK Framework v2
  --
  Run-time error handler for test/example program RestartEval.
  --
  MCU: RP2040
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Errors, Exceptions, StartUp, Watchdog, LEDext;

  CONST
    EXC_RET_SPSEL = 2;
    SP = 13;
    LR = 14;
    PCoffset = 24;
    MaxErrorNo = Errors.MaxErrNo;

    Key = 05FA0000H;

    AIRCRreset = FALSE;
    SysReset = MCU.PSM_RESET;


  PROCEDURE svch[0];
    VAR stackframeAddr, retAddr: INTEGER; svcVal: BYTE;
  BEGIN
    (* get base address of exception stack frame *)
    IF EXC_RET_SPSEL IN BITS(SYSTEM.REG(LR)) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP); (* get PSP via r11 *)
      stackframeAddr := SYSTEM.REG(11)
    ELSE (* MSP used for stacking *)
      stackframeAddr := SYSTEM.REG(SP) + 16; (* +16: local vars and lr *)
    END;

    (* get imm svc value *)
    SYSTEM.GET(stackframeAddr + PCoffset, retAddr); (* return address *)
    SYSTEM.GET(retAddr - 2, svcVal); (* svc instr is two bytes, imm value is lower byte *)

    (* handle svc value *)
    IF svcVal <= MaxErrorNo THEN
      IF AIRCRreset THEN
        SYSTEM.PUT(LEDext.LSET, {LEDext.LED6});
        SYSTEM.PUT(MCU.PPB_AIRCR, Key + 4);
        REPEAT UNTIL FALSE
      ELSE
        StartUp.SetPowerOnWatchdogResets(SysReset);
        Watchdog.Trigger;
        REPEAT UNTIL FALSE
      END
    END
  END svch;


  PROCEDURE Init*;
  BEGIN
    Exceptions.InstallSysExcHandler(MCU.PPB_SVC_Exc, svch)
  END Init;

END Recovery.
