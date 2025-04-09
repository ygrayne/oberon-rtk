MODULE SysCall;
(**
  Oberon RTK Framework v2
  --
  SVC handling.
  For example/test program:
    https://oberon-rtk.org/examples/v2/syscall
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, RuntimeErrors, Errors, Exceptions;

  CONST
    EXC_RET_SPSEL = 2;
    SP = 13;
    LR = 14;
    PCoffset = 24;
    MaxErrorNo = Errors.MaxErrNo;

    (* MCU.PPB_ICSR bits *)
    PENDSVSET = 28;

    IntNo0 = MCU.PPB_SPAREIRQ_IRQ0;
    IntNo1 = MCU.PPB_SPAREIRQ_IRQ1;
    SVCvalIRQ0* = 192;
    SVCvalIRQ1* = 193;


  PROCEDURE svch[0];
    VAR icsr, stackframeAddr, retAddr: INTEGER; svcVal: BYTE;
  BEGIN
    (* get base address of exception stack frame *)
    IF EXC_RET_SPSEL IN BITS(SYSTEM.REG(LR)) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP); (* get PSP via r11 *)
      stackframeAddr := SYSTEM.REG(11)
    ELSE (* MSP used for stacking *)
      stackframeAddr := SYSTEM.REG(SP) + 20; (* +20: local vars and lr *)
    END;
    (* get imm svc value *)
    SYSTEM.GET(stackframeAddr + PCoffset, retAddr); (* return address *)
    SYSTEM.GET(retAddr - 2, svcVal); (* svc instr is two bytes, imm value is lower byte *)

    (* finally, act on svc value *)
    (* general error handling via RuntimeErrors *)
    IF svcVal <= MaxErrorNo THEN
      SYSTEM.GET(MCU.PPB_ICSR, icsr);
      icsr := ORD(BITS(icsr) + {PENDSVSET});
      SYSTEM.PUT(MCU.PPB_ICSR, icsr); (* set PendSV pending *)
      SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);

    (* program/application specific *)
    ELSE (* sys calls: set ints pending *)
      IF svcVal = SVCvalIRQ0 THEN
        SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo0 DIV 32) * 4), {IntNo0 MOD 32});
        SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
      ELSIF svcVal = SVCvalIRQ1 THEN
        SYSTEM.PUT(MCU.PPB_NVIC_ISPR0 + ((IntNo1 DIV 32) * 4), {IntNo1 MOD 32});
        SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
      END;
    END
  END svch;


  PROCEDURE Init*;
    VAR p0, p1: PROCEDURE;
  BEGIN
    (* prep vectors *)
    p0 := svch; INCL(SYSTEM.VAL(SET, p0), 0);
    p1 := RuntimeErrors.ErrorHandler; INCL(SYSTEM.VAL(SET, p1), 0);
    (* patch vector table *)
    Exceptions.InstallSysExcHandler(MCU.PPB_SVC_Exc, p0);
    Exceptions.InstallSysExcHandler(MCU.PPB_PendSV_Exc, p1)
  END Init;

END SysCall.
