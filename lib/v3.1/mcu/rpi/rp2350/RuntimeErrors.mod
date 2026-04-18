MODULE RuntimeErrors;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  Exception handling: run-time errors and faults
  Multi-core
  --
  * Error: run-time errors, including ASSERT, triggered by SVC calls in software
  * Fault: hardware faults, triggered by MCU hardware
  --
  MCU: RP2350
  --
  Copyright (c) 2020-2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, PPB, EXC, LED, SIO := SIO_DEV, MemMap;

  CONST
    NumCores = MemMap.NumCoresUsed;

    (* register offsets from stacked r0 *)
    PCoffset = 24;

    (* register numbers *)
    SP = 13;

    (* SHCSR bits *)
    SECUREFAULTENA  = 19;
    USGFAULTENA     = 18;
    BUSFAULTENA     = 17;
    MEMFAULTENA     = 16;

    (* EXC_RETURN bits *)
    (*EXC_RET_S     = 6;*)  (* = 1: secure stack frame, faulty code was running in secure domain *)
    EXC_RET_DCRS  = 5;      (* = 0: all CPU regs stacked by hardware, extended state context *)
    (*EXC_RET_FType = 4;*)  (* = 0: all FPU regs stacked by hardware, extended FPU context *)
    EXC_RET_Mode  = 3;      (* = 1: thread mode, faulty code was running in thread mode *)
    EXC_RET_SPSEL = 2;      (* = 1: PSP used for stacking *)
    (*EXC_RET_ES    = 0;*)  (* = 1: exception running in secure domain *)

    (* stack context sizes *)
    ExtStateContextSize = 10 * 4;

    (* MCU.ICSR bits *)
    PENDSVSET = 28;


  TYPE
    (* data collected for an error/fault *)
    ErrorDesc* = RECORD
      core*: BYTE;       (* MCU core *)
      errCode*: BYTE;    (* error or fault code *)
      errType*: BYTE;    (* type of error: error or fault, handler or thread mode *)
      errAddr*: INTEGER; (* error/fault code address *)
      errLineNo*: INTEGER;      (* error source code line no, if available *)
      stackframeBase*: INTEGER; (* address of exception frame stack *)
      excRetVal*: INTEGER;
      xpsr*: INTEGER
    END;

  VAR
    ErrorRec*: ARRAY NumCores OF ErrorDesc;


  PROCEDURE excHandler[0];
    CONST FaultCodeBase = 2;
    VAR
      cid, excNo, stackframeBase, excRetAddr, excRetVal, retAddr: INTEGER;
      b0, b1: BYTE; icsr: SET;
      er: ErrorDesc;
  BEGIN
    SYSTEM.GET(SIO.SIO_CPUID, cid);
    excRetAddr := SYSTEM.REG(SP) + 56; (* addr of EXC_RETURN value on stack *)
    SYSTEM.GET(excRetAddr, excRetVal);
    IF EXC_RET_SPSEL IN BITS(excRetVal) THEN (* PSP used for stacking *)
      (* asm
        mrs r11, psp -> stackframeBase
      end asm *)
      (* +asm *)
      SYSTEM.EMIT(0F3EF8B09H);  (* mrs r11, PSP *)
      stackframeBase := SYSTEM.REG(11);  (* r11 -> stackframeBase *)
      (* -asm *)
    ELSE (* MSP used *)
      stackframeBase := excRetAddr + 4;
    END;
    IF ~(EXC_RET_DCRS IN BITS(excRetVal)) THEN
      stackframeBase := stackframeBase + ExtStateContextSize
    END;
    SYSTEM.GET(stackframeBase + PCoffset, retAddr);
    (* asm
      mrs r11, xpsr -> er.xpsr
    END asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8B03H);  (* mrs r11, XPSR *)
    er.xpsr := SYSTEM.REG(11);  (* r11 -> er.xpsr *)
    (* -asm *)
    er.core := cid;
    er.excRetVal := excRetVal;
    er.errAddr := retAddr;
    er.stackframeBase := stackframeBase;
    (* asm
      mrs r11, ipsr -> excNo
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3EF8B05H);  (* mrs r11, IPSR *)
    excNo := SYSTEM.REG(11);  (* r11 -> excNo *)
    (* -asm *)
    IF excNo = PPB.EXC_SVC THEN (* SVC exception *)
      (* get source line number *)
      SYSTEM.GET(retAddr + 1, b1);
      SYSTEM.GET(retAddr, b0);
      er.errLineNo := LSL(b1, 8) + b0;
      (* get imm svc value = error code *)
      SYSTEM.GET(retAddr - 2, er.errCode); (* svc instr is two bytes, imm value is lower byte *)
      (* type: 0 = error in handler mode, 1 = error in thread mode *)
      er.errType := BFX(excRetVal, EXC_RET_Mode);
    ELSE (* all others *)
      er.errLineNo := 0;
      er.errCode := excNo;
      (* type: 2 = fault in handler mode, 3 = fault in thread mode *)
      er.errType := FaultCodeBase + BFX(excRetVal, EXC_RET_Mode);
    END;
    ErrorRec[cid] := er;

    (* set PendSV pending to trigger error handler *)
    SYSTEM.GET(PPB.ICSR, icsr);
    icsr := icsr + {PENDSVSET};
    SYSTEM.PUT(PPB.ICSR, icsr);
    (* asm
      dsb
      isb
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3BF8F4FH);  (* dsb *)
    SYSTEM.EMIT(0F3BF8F6FH);  (* isb *)
    (* -asm *)
  END excHandler;


  PROCEDURE* errorHandler[0];
  (* default handler: simply blink LED *)
    VAR cid, cnt, i: INTEGER; er: ErrorDesc;
  BEGIN
    SYSTEM.GET(SIO.SIO_CPUID, cid);
    er := ErrorRec[cid];
    IF er.errType IN {0, 1} THEN
      cnt := 1000000
    ELSE
      cnt := 5000000
    END;
    REPEAT
      SYSTEM.PUT(LED.LXOR, {LED.Pico});
      i := 0;
      WHILE i < cnt DO INC(i) END
    UNTIL FALSE
  END errorHandler;


  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE InstallErrorHandler*(eh: PROCEDURE);
    VAR vectorTableBase: INTEGER;
  BEGIN
    SYSTEM.GET(PPB.VTOR, vectorTableBase);
    install(vectorTableBase + PPB.EXC_PendSV_Offset, eh);
  END InstallErrorHandler;


  PROCEDURE* EnableFaults*;
    VAR x: SET;
  BEGIN
    SYSTEM.GET(PPB.SHCSR, x);
    x := x + {MEMFAULTENA, BUSFAULTENA, USGFAULTENA, SECUREFAULTENA};
    SYSTEM.PUT(PPB.SHCSR, x);
    (* asm
      dsb
      isb
    end asm *)
    (* +asm *)
    SYSTEM.EMIT(0F3BF8F4FH);  (* dsb *)
    SYSTEM.EMIT(0F3BF8F6FH);  (* isb *)
    (* -asm *)
  END EnableFaults;


  PROCEDURE Install*;
  (* initialise vector table  *)
    VAR addr, vectorTableBase, vectorTableTop: INTEGER;
  BEGIN
    (* vector table address and range *)
    SYSTEM.GET(PPB.VTOR, vectorTableBase);
    vectorTableTop := vectorTableBase + EXC.VectorTableSize;
    (* install excHandler for all errors and faults *)
    install(vectorTableBase + PPB.EXC_NMI_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_HardFault_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_MemMgmtFault_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_BusFault_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_UsageFault_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_SecureFault_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_SVC_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_DebugMon_Offset, excHandler);
    install(vectorTableBase + PPB.EXC_SysTick_Offset, excHandler);
    (* install default errorhandler *)
    install(vectorTableBase + PPB.EXC_PendSV_Offset, errorHandler);
    (* install excHandler across the rest of the vector table *)
    (* will catch any exception with a missing handler *)
    addr := vectorTableBase + PPB.EXC_IRQ0_Offset;
    WHILE addr < vectorTableTop DO
      install(addr, excHandler); INC(addr, 4)
    END
  END Install;

END RuntimeErrors.
