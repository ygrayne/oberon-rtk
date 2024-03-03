MODULE MessagingC0;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/messaging/
  --
  Program for core 0: this module
  Program for core 1: 'MessagingC1'
  Message data and protocol: 'MessagingCom'
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT
    Main, Kernel, Out, MultiCore, Memory, Errors, GPIO, LED, Messages, MessagingC1, Com := MessagingCom, Random;

  CONST
    Core1 = 1;
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

  VAR
    t0, t1, t2: Kernel.Thread;
    tid0, tid1, tid2: INTEGER;


  PROCEDURE t0c;
  BEGIN
    GPIO.Set({LED.Green});
    REPEAT
      GPIO.Toggle({LED.Green});
      Kernel.Next
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    CONST
      Me = "A";
      SRno = Com.Asr;
      Wakeup0 = Com.Wakeup0;
      Wakeup1 = Com.Wakeup1;
    VAR
      tid, cid, cnt, res: INTEGER; sr: Messages.SndRcv;
      msg, rcv, data: BYTE; sender: CHAR; flags: SET;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    Messages.Subscribe(SRno, sr, res); ASSERT(res = Messages.NoError, Errors.ProgError);
    REPEAT
      (* essential *)
      Com.Await(sr); (* await wakeup *)
      Com.Receive(sr, rcv, msg, sender, data, flags);

      (* demo checks and output *)
      ASSERT(rcv = SRno, Errors.ProgError);
      ASSERT((msg = Wakeup0) OR (msg = Wakeup1), Errors.ProgError);
      ASSERT(sender = "C", Errors.ProgError);
      Com.WriteThreadInfo(tid, cid); Out.Int(cnt, 8);
      Com.WriteMsgData(msg, sender, data);
      Out.Ln;
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE t2c;
    CONST
      Me = "B";
      SRno = Com.Bsr;
      DataTo = Com.Dsr;
      Wakeup2 = Com.Wakeup2;
      DataReady = Com.DataReady;
      DataReceived = Com.DataReceived;
      DataLen = 4;
    VAR
      tid, cid, cnt, res, i, v: INTEGER; sr: Messages.SndRcv;
      msg, rcv, data: BYTE; sender: CHAR; flags: SET;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    Messages.Subscribe(SRno, sr, res); ASSERT(res = Messages.NoError, Errors.ProgError);
    REPEAT
      (* essential *)
      Com.Await(sr); (* await wakeup *)
      Com.Receive(sr, rcv, msg, sender, data, flags);

      (* demo checks and output *)
      ASSERT(rcv = SRno, Errors.ProgError);
      ASSERT(msg = Wakeup2, Errors.ProgError);
      ASSERT(sender = "C", Errors.ProgError);
      Com.WriteThreadInfo(tid, cid); Out.Int(cnt, 8);
      Com.WriteMsgData(msg, sender, data);
      Out.String(" wakeup");
      Out.Ln;

      (* essential *)
      i := 0;
      WHILE i < DataLen DO
        v := Random.Next(100);
        Com.Put(i, v);
        Out.Int(v, 4);
        INC(i)
      END;
      Out.Ln;
      Com.Send(sr, DataTo, DataReady, Me, DataLen, flags);
      Com.Await(sr); (* await confirmation data received *)
      Com.Receive(sr, rcv, msg, sender, data, flags);

      (* demo checks and output *)
      ASSERT(rcv = SRno, Errors.ProgError);
      ASSERT(msg = DataReceived, Errors.ProgError);
      ASSERT(sender = "D", Errors.ProgError);
      Com.WriteThreadInfo(tid, cid); Out.Int(cnt, 8);
      Com.WriteMsgData(msg, sender, data);
      Out.String(" data rec");
      Out.Ln;
      INC(cnt)
    UNTIL FALSE
  END t2c;


  PROCEDURE run;
    CONST MsgHandlerPeriod = 50; MsgHandlerPrio = Kernel.DefaultPrio;
    VAR res: INTEGER;
  BEGIN
    MultiCore.InitCoreOne(MessagingC1.Run, Memory.DataMem[Core1].stackStart, Memory.DataMem[Core1].dataStart);
    Kernel.Install(MillisecsPerTick);
    Messages.Install(MsgHandlerPeriod, MsgHandlerPrio);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.SetPeriod(t0, 500, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t1);
    Kernel.Allocate(t2c, ThreadStackSize, t2, tid2, res); ASSERT(res = Kernel.NoError, Errors.ProgError);
    Kernel.Enable(t2);
    Kernel.Run
    (* we'll not return here *)
  END run;

BEGIN
  run
END MessagingC0.
