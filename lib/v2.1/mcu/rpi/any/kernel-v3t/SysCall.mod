MODULE SysCall;
(**
  Oberon RTK Framework v2.1
  --
  Multi-threading kernel-v3t.
  SysCall via trap.
  --
  MCU: RP2350
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    SYSTEM, MCU := MCU2, Types, ReadyQueue, MessageQueue, ActorQueue, MessagePool, Exceptions, Out;


  CONST
    TrapIntNo = MCU.PPB_SPAREIRQ_IRQ5;
    TrapIntPrio = MCU.PPB_ExcPrio1;
    StateContextSize = 8 * 4;
    FPcontextSize = 18 * 4;
    ExtFPcontextSize = 16 * 4;
    EXC_RET_FType = 4;  (* = 0: all FPU regs stacked by hardware, extended FPU context *)
    FPCCR_TS  = 26;
    PSRoffset = 28;

    AQgetSysCallNo = 0;
    AQputSysCallNo = 1;
    MQgetSysCallNo = 2;
    MQputSysCallNo = 3;
    RQgetSysCallNo = 4;
    RQputSysCallNo = 5;
    MPgetSysCallNo = 6;
    MPputSysCallNo = 7;

    SysCalls = {0 .. 7};


  PROCEDURE* argsAddr(stackframeBase, excRetVal: INTEGER): INTEGER;
    CONST StackAlign = 9; (* in stacked PSR *)
    VAR addr: INTEGER;
  BEGIN
    addr := stackframeBase + StateContextSize;
    IF ~(EXC_RET_FType IN BITS(excRetVal)) THEN (* FP context *)
      addr := addr + FPcontextSize;
      IF SYSTEM.BIT(MCU.PPB_FPCCR, FPCCR_TS) THEN
        addr := addr + ExtFPcontextSize (* extended FP context *)
      END
    END;
    IF SYSTEM.BIT(stackframeBase + PSRoffset, StackAlign) THEN
      INC(addr, 4)
    END
    RETURN addr
  END argsAddr;


  PROCEDURE trapHandler[0];
    CONST SP = 13; LR = 14;
    VAR argsBase, f, p0, p1, x: INTEGER;
  BEGIN
    argsBase := argsAddr(SYSTEM.REG(SP) + 56, SYSTEM.REG(LR));
    SYSTEM.GET(argsBase, f);        (* sys call function number *)
    SYSTEM.GET(argsBase + 8, p0);   (* parameter 0, some queue/pool, value parameter *)
    SYSTEM.GET(argsBase + 12, p1);  (* parameter 1, actor or message, value or variable par *)
    IF f IN SysCalls THEN
      IF f = AQgetSysCallNo THEN
        SYSTEM.GET(p1, x); (* load var parameter value *)
        ActorQueue.Get(SYSTEM.VAL(Types.ActorQueue, p0), SYSTEM.VAL(Types.Actor, x));
        SYSTEM.PUT(p1, x) (* store var parameter value *)
      ELSIF f = AQputSysCallNo THEN
        ActorQueue.Put(SYSTEM.VAL(Types.ActorQueue, p0), SYSTEM.VAL(Types.Actor, p1))
      ELSIF f = MQgetSysCallNo THEN
        SYSTEM.GET(p1, x);
        MessageQueue.Get(SYSTEM.VAL(Types.MessageQueue, p0), SYSTEM.VAL(Types.Message, x));
        SYSTEM.PUT(p1, x)
      ELSIF f = MQputSysCallNo THEN
        MessageQueue.Put(SYSTEM.VAL(Types.MessageQueue, p0), SYSTEM.VAL(Types.Message, p1))
      ELSIF f = RQgetSysCallNo THEN
        SYSTEM.GET(p1, x);
        ReadyQueue.Get(SYSTEM.VAL(Types.ReadyQueue, p0), SYSTEM.VAL(Types.Actor, x));
        SYSTEM.PUT(p1, x)
      ELSIF f = RQputSysCallNo THEN
        ReadyQueue.Put(SYSTEM.VAL(Types.ReadyQueue, p0), SYSTEM.VAL(Types.Actor, p1))
      ELSIF f = MPgetSysCallNo THEN
        SYSTEM.GET(p1, x);
        MessagePool.Get(SYSTEM.VAL(Types.MessagePool, p0), SYSTEM.VAL(Types.Message, x));
        SYSTEM.PUT(p1, x)
      ELSIF f = MPputSysCallNo THEN
        MessagePool.Put(SYSTEM.VAL(Types.MessagePool, p0), SYSTEM.VAL(Types.Message, p1))
      END
    ELSE
      ASSERT(FALSE) (* error handling missing *)
    END
  END trapHandler;


  PROCEDURE trap(sysCall: INTEGER);
  BEGIN
    Out.String("trap"); Out.Int(sysCall, 4); Out.Ln;
    SYSTEM.PUT(MCU.PPB_STIR, TrapIntNo);
    SYSTEM.EMIT(MCU.DSB); SYSTEM.EMIT(MCU.ISB)
  END trap;


  PROCEDURE AQget*(q: Types.ActorQueue; VAR act: Types.Actor);
  BEGIN
    trap(AQgetSysCallNo)
  END AQget;

  PROCEDURE AQput*(q: Types.ActorQueue; act: Types.Actor);
  BEGIN
    trap(AQputSysCallNo)
  END AQput;

  PROCEDURE MQget*(q: Types.MessageQueue; VAR msg: Types.Message);
  BEGIN
    trap(MQgetSysCallNo)
  END MQget;

  PROCEDURE MQput*(q: Types.MessageQueue; msg: Types.Message);
  BEGIN
    trap(MQputSysCallNo)
  END MQput;

  PROCEDURE RQget*(q: Types.ReadyQueue; VAR act: Types.Actor);
  BEGIN
    trap(RQgetSysCallNo)
  END RQget;

  PROCEDURE RQput*(q: Types.ReadyQueue; act: Types.Actor);
  BEGIN
    trap(RQputSysCallNo)
  END RQput;

  PROCEDURE MPget*(q: Types.MessagePool; VAR msg: Types.Message);
  BEGIN
    trap(MPgetSysCallNo)
  END MPget;

  PROCEDURE MPput*(q: Types.MessagePool; msg: Types.Message);
  BEGIN
    trap(MPputSysCallNo)
  END MPput;


  PROCEDURE install;
  BEGIN
    Exceptions.InstallIntHandler(TrapIntNo, trapHandler);
    Exceptions.SetIntPrio(TrapIntNo, TrapIntPrio);
    Exceptions.EnableInt(TrapIntNo)
  END install;

BEGIN
  install
END SysCall.
