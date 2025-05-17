MODULE RuntimeErrors;
(**
  Oberon RTK Framework v2.1
  --
  Exception handling: run-time errors and faults
  Multi-core
  --
  * Error: run-time errors, including ASSERT, triggered by SVC calls in software
  * Fault: hardware faults, triggered by MCU hardware
  --
  MCU: RP2350
  --
  NOTE:
    * for Secure, privileged code
    * implications of other MOs to be identified
  --
  IMPORTANT:
    * 'EnableFaults' needs to called from the core whose faults shall be enabled.
    * See modules InitCoreOne and MultiCore.
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, LEDext, Memory;

  CONST
    NumCores* = MCU.NumCores;
    TraceDepth* = 16;

    (* register offsets from stacked r0 *)
    PCoffset = 24;

    (* register numbers *)
    SP = 13;

    (* PPB_SHCSR bits *)
    SECUREFAULTENA  = 19;
    USGFAULTENA     = 18;
    BUSFAULTENA     = 17;
    MEMFAULTENA     = 16;

    (* EXC_RETURN bits *)
    (*EXC_RET_S     = 6;*)  (* = 1: secure stack frame, faulty code was running in secure domain *)
    (*EXC_RET_DCRS  = 5;*)  (* = 0: all CPU regs stacked by hardware, extended state context *)
    (*EXC_RET_FType = 4;*)  (* = 0: all FPU regs stacked by hardware, extended FPU context *)
    EXC_RET_Mode  = 3;  (* = 1: thread mode, faulty code was running in thread mode *)
    EXC_RET_SPSEL = 2;  (* = 1: PSP used for stacking *)
    (*EXC_RET_ES    = 0;*)  (* = 1: exception running in secure domain *)

    (* MCU.PPB_ICSR bits *)
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
    CONST FaultCodeBase = 2; R11 = 11;
    VAR
      cid, excNo, stackframeBase, excRetAddr, excRetVal, retAddr: INTEGER;
      b0, b1: BYTE; icsr: SET;
      er: ErrorDesc;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    excRetAddr := SYSTEM.REG(SP) + 56; (* addr of EXC_RETURN value on stack *)
    SYSTEM.GET(excRetAddr, excRetVal);
    IF EXC_RET_SPSEL IN BITS(excRetVal) THEN (* PSP used for stacking *)
      SYSTEM.EMIT(MCU.MRS_R11_PSP);
      stackframeBase := SYSTEM.REG(R11)
    ELSE (* MSP used *)
      stackframeBase := excRetAddr + 4;
    END;
    SYSTEM.GET(stackframeBase + PCoffset, retAddr);
    SYSTEM.EMIT(MCU.MRS_R11_XPSR);
    er.xpsr := SYSTEM.REG(R11);
    er.core := cid;
    er.excRetVal := excRetVal;
    er.errAddr := retAddr;
    er.stackframeBase := stackframeBase;

    SYSTEM.EMIT(MCU.MRS_R11_IPSR);
    excNo := SYSTEM.REG(R11);
    IF excNo = MCU.PPB_SVC_Exc THEN (* SVC exception *)
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
    SYSTEM.GET(MCU.PPB_ICSR, icsr);
    icsr := icsr + {PENDSVSET};
    SYSTEM.PUT(MCU.PPB_ICSR, icsr);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB);
  END excHandler;


  PROCEDURE errorHandler[0];
    VAR cid, leds, i: INTEGER; setMask: SET; er: ErrorDesc;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    er := ErrorRec[cid];

    (* set LEDs to indicate error *)
    leds := LSL(er.core, 7); (* [7]: core 0 or 1 *)
    leds := leds + LSL((er.errType) DIV 2, 6); (* [6]: error or fault *)
    leds := leds + er.errCode;
    i := 0; setMask := {};
    WHILE i < 8 DO
      IF i IN BITS(leds) THEN
        INCL(setMask, LEDext.LED[i])
      END;
      INC(i)
    END;
    SYSTEM.PUT(LEDext.LCLR, LEDext.LEDx);
    SYSTEM.PUT(LEDext.LSET, setMask); (* [5:0]: error/fault code *)

    (* blink nervously *)
    REPEAT
      SYSTEM.PUT(LEDext.LXOR, {LEDext.LEDpico});
      i := 0;
      WHILE i < 1000000 DO INC(i) END
    UNTIL FALSE
  END errorHandler;


  PROCEDURE* install(vectAddr: INTEGER; p: PROCEDURE);
  BEGIN
    INCL(SYSTEM.VAL(SET, p), 0); (* thumb code *)
    SYSTEM.PUT(vectAddr, p)
  END install;


  PROCEDURE InstallErrorHandler*(cid: INTEGER; eh: PROCEDURE);
    VAR vectorTableBase: INTEGER;
  BEGIN
    vectorTableBase := Memory.DataMem[cid].dataStart;
    install(vectorTableBase + MCU.PendSVhandlerOffset, eh);
  END InstallErrorHandler;


  PROCEDURE EnableFaults*;
  (* call from code running on core 0 AND on core 1*)
    VAR x: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_SHCSR, x);
    x := x + {MEMFAULTENA, BUSFAULTENA, USGFAULTENA, SECUREFAULTENA};
    SYSTEM.PUT(MCU.PPB_SHCSR, x);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END EnableFaults;


  PROCEDURE Init*;
    CONST Core0 = 0;
    VAR i, addr, vectorTableBase, vectorTableTop: INTEGER;
  BEGIN
    i := 0;
    WHILE i < NumCores DO
      (* set core 0 VTOR register to core 0 SRAM bottom *)
      IF i = Core0 THEN
        (* VTOR of core 1 will be set by core 1 wake-up sequence *)
        SYSTEM.PUT(MCU.PPB_VTOR, Memory.DataMem[Core0].dataStart)
      END;

      (* initialise vector table *)
      (* install exception handlers for all errors and faults as implemented in the MCU *)
      vectorTableBase := Memory.DataMem[i].dataStart;
      vectorTableTop := vectorTableBase + MCU.VectorTableSize;
      install(vectorTableBase + MCU.NMIhandlerOffset, excHandler);
      install(vectorTableBase + MCU.HardFaultHandlerOffset, excHandler);
      install(vectorTableBase + MCU.MemMgmtFaultHandlerOffset, excHandler);
      install(vectorTableBase + MCU.BusFaultHandlerOffset, excHandler);
      install(vectorTableBase + MCU.UsageFaultHandlerOffset, excHandler);
      install(vectorTableBase + MCU.SecureFaultHandlerOffset, excHandler);
      install(vectorTableBase + MCU.SVChandlerOffset, excHandler);
      install(vectorTableBase + MCU.DebugMonitorOffset, excHandler);
      (* install default error handler *)
      install(vectorTableBase + MCU.PendSVhandlerOffset, errorHandler);

      (* install faultHandler across the rest of the vector table *)
      (* will catch any exception with a missing handler *)
      addr := vectorTableBase + MCU.SysTickHandlerOffset;
      WHILE addr < vectorTableTop DO
        install(addr, excHandler); INC(addr, 4)
      END;
      INC(i)
    END
  END Init;

BEGIN
  Init
END RuntimeErrors.


(**
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  Copyright (c) 2008-2023 CFB Software, https://www.astrobe.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**)
