MODULE MessagingC1;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/messaging/
  --
  Program for core 1: this module
  Program for core 0: 'MessagingC0'
  Message data and protocol: 'MessagingCom'
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT
    Main, Kernel, Out, MultiCore, Errors, Messages, Com := MessagingCom;

  CONST
    MillisecsPerTick  = 10;
    ThreadStackSize = 1024;

  VAR
    t0, t1: Kernel.Thread;
    tid0, tid1: INTEGER;


  PROCEDURE t0c;
  (* periodic, drives all other threads *)
    CONST
      Me = "C";
      SRno = Com.Csr;
      Worker0 = Com.Asr;
      Worker1 = Com.Bsr;
      Wakeup0 = Com.Wakeup0;
      Wakeup1 = Com.Wakeup1;
      Wakeup2 = Com.Wakeup2;
    VAR
      tid, cid, cnt, res: INTEGER; sr: Messages.SndRcv; flags: SET;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    Messages.Subscribe(SRno, sr, res); ASSERT(res = Messages.NoError, Errors.Config);
    REPEAT
      Kernel.Next;
      Com.WriteThreadInfo(tid, cid);
      Out.Int(cnt, 8); Out.String(" send wake up"); Out.Ln;
      Com.Send(sr, Worker0, Wakeup0, Me, cnt, flags);
      IF cnt MOD 2 = 0 THEN
        Com.Send(sr, Worker1, Wakeup2, Me, cnt, flags);
      END;
      Com.Send(sr, Worker0, Wakeup1, Me, cnt * 2, flags);
      INC(cnt)
    UNTIL FALSE
  END t0c;


  PROCEDURE t1c;
    CONST
      Me = "D";
      SRno = Com.Dsr;
      DataFrom = Com.Dsr;
      DataReady = Com.DataReady;
      DataReceived = Com.DataReceived;
    VAR
      tid, cid, cnt, res, i: INTEGER; sr: Messages.SndRcv;
      msg, rcv, numData: BYTE; sender: CHAR; flags: SET;
  BEGIN
    cid := MultiCore.CPUid();
    tid := Kernel.Tid();
    cnt := 0;
    Messages.Subscribe(SRno, sr, res); ASSERT(res = Messages.NoError, Errors.Config);
    REPEAT
      (* essential *)
      Com.Await(sr); (* await data ready in buffer *)
      Com.Receive(sr, rcv, msg, sender, numData, flags);

      (* demo checks and output *)
      ASSERT(rcv = SRno, Errors.Config);
      ASSERT(msg = DataReady, Errors.Config);
      ASSERT(sender = "B", Errors.Config);
      Com.WriteThreadInfo(tid, cid); Out.Int(cnt, 8);
      Com.WriteMsgData(msg, sender, numData);
      Out.String(" data ready");
      Out.Ln;

      (* essential *)
      i := 0;
      WHILE i < numData DO
        Out.Int(Com.Get(i), 4);
        INC(i)
      END;
      Out.Ln;
      Com.Send(sr, DataFrom, DataReceived, Me, 0, flags); (* send data received *)
      INC(cnt)
    UNTIL FALSE
  END t1c;


  PROCEDURE Run*;
    CONST MsgHandlerPeriod = 50; MsgHandlerPrio = 0;
    VAR res: INTEGER;
  BEGIN
    Kernel.Install(MillisecsPerTick);
    Messages.Install(MsgHandlerPeriod, MsgHandlerPrio);
    Kernel.Allocate(t0c, ThreadStackSize, t0, tid0, res); ASSERT(res = Kernel.NoError, Errors.Config);
    Kernel.SetPeriod(t0, 1000, 0); Kernel.Enable(t0);
    Kernel.Allocate(t1c, ThreadStackSize, t1, tid1, res); ASSERT(res = Kernel.NoError, Errors.Config);
    Kernel.Enable(t1);
    Kernel.Run
    (* we'll not return here *)
  END Run;

END MessagingC1.

