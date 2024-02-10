MODULE Messages;
(**
  Oberon RTK Framework
  Messages between threads on different cores
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Kernel, MultiCore, Config, Signals, Errors, Out;

  CONST
    BufSize = 4;
    MaxNumSndRcv = 4;
    NumCores = Config.NumCores;

    NoError* = 0;
    Failed* = 1;

    InBufOverrun* = 0;
    InBufEmpty* = 1;
    OutBufFull* = 0;

    Unsubscribed = 0;
    Subscribed = 1;

    FifoStackSize = 1024;

  TYPE

    Message* = ARRAY 4 OF BYTE;

    MessageBuffer* = RECORD
      data: ARRAY BufSize OF Message;
      wr, rd: INTEGER;
      flags: SET
    END;

    SndRcv* = POINTER TO SndRcvDesc;
    SndRcvDesc* = RECORD
      inb: MessageBuffer;
      outb: MessageBuffer;
      state: INTEGER;
      sndRdy: BOOLEAN;
      sigIn, sigOut: Signals.Signal
    END;

    CoreContext = POINTER TO CoreContextDesc;
    CoreContextDesc = RECORD
      sndRcv: ARRAY MaxNumSndRcv OF SndRcv;
      numSndRcv: INTEGER
    END;

  VAR
    coreCon: ARRAY NumCores OF CoreContext;


  PROCEDURE Subscribe*(srNo: INTEGER; VAR sr: SndRcv; VAR res: INTEGER);
    VAR cid: INTEGER; ctx: CoreContext;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    ASSERT(srNo < MaxNumSndRcv, Errors.Config);
    IF ctx.sndRcv[srNo].state = Unsubscribed THEN
      INC(ctx.numSndRcv);
      sr := ctx.sndRcv[srNo];
      sr.state := Subscribed;
      sr.inb.wr := 0; sr.inb.rd := 0;
      sr.outb.wr := 0; sr.outb.rd := 0;
      sr.inb.flags := {}; sr.outb.flags := {};
      res := NoError
    ELSE
      res := Failed
    END
  END Subscribe;


  PROCEDURE nextIndex(ci: INTEGER): INTEGER;
    RETURN (ci + 1) MOD BufSize
  END nextIndex;


  PROCEDURE SndAvail*(sr: SndRcv): BOOLEAN;
    RETURN nextIndex(sr.inb.wr) # sr.inb.rd
  END SndAvail;


  PROCEDURE RcvAvail*(sr: SndRcv): BOOLEAN;
    RETURN sr.inb.wr # sr.inb.rd
  END RcvAvail;


  PROCEDURE AwaitSnd*(sr: SndRcv);
  BEGIN
    IF nextIndex(sr.inb.wr) = sr.inb.rd THEN (* out buffer full *)
      Signals.Await(sr.sigOut)
    END
  END AwaitSnd;


  PROCEDURE AwaitRcv*(sr: SndRcv);
  BEGIN
    IF sr.inb.wr = sr.inb.rd THEN (* in buffer empty *)
      Signals.Await(sr.sigIn)
    END
  END AwaitRcv;


  PROCEDURE PutSnd*(sr: SndRcv; msg: Message; VAR flags: SET);
  BEGIN
    IF nextIndex(sr.inb.wr) # sr.inb.rd THEN (* not full *)
      sr.outb.data[sr.outb.wr] := msg;
      sr.outb.wr := nextIndex(sr.outb.wr);
      sr.sndRdy := TRUE;
      flags := {}
    ELSE
      INCL(flags, OutBufFull)
    END
  END PutSnd;


  PROCEDURE GetRcv*(sr: SndRcv; VAR msg: Message; VAR flags: SET);
  BEGIN
    flags := sr.inb.flags;
    IF sr.inb.wr # sr.inb.rd THEN (* not empty *)
      msg := sr.inb.data[sr.inb.rd];
      flags := sr.inb.flags;
      sr.inb.rd := nextIndex(sr.inb.rd);
    ELSE
      INCL(flags, InBufEmpty)
    END;
    sr.inb.flags := {}
  END GetRcv;

  (* fifo handler thread code *)

  PROCEDURE fifoc;
    VAR cid, srNo: INTEGER; sr: SndRcv; ctx: CoreContext; msg: Message;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    ctx := coreCon[cid];
    REPEAT
      srNo := 0;
      (* send *)
      WHILE srNo < ctx.numSndRcv DO
        sr := ctx.sndRcv[srNo];
        IF sr.state = Subscribed THEN
          WHILE sr.sndRdy & MultiCore.Ready() DO
            MultiCore.Send(sr.outb.data[sr.outb.rd]);
            sr.outb.rd := nextIndex(sr.outb.rd);
            sr.sndRdy := sr.outb.rd # sr.outb.wr; (* not empty *)
            Signals.Send(sr.sigOut) (* multiple signal sends OK *)
          END
        END;
        INC(srNo)
      END;
      (* receive *)
      WHILE MultiCore.Valid() DO
        MultiCore.Receive(msg);
        sr := ctx.sndRcv[msg[0]];
        IF nextIndex(sr.inb.wr) # sr.inb.rd THEN (* not full *)
          sr.inb.data[sr.inb.wr] := msg;
          sr.inb.wr := nextIndex(sr.inb.wr);
          sr.inb.flags := {}
        ELSE
          INCL(sr.inb.flags, InBufOverrun)
        END;
        Signals.Send(sr.sigIn) (* multiple signal sends OK *)
      END;
      Kernel.Next
    UNTIL FALSE
  END fifoc;


  PROCEDURE Install*(period, prio: INTEGER);
    VAR i, cid, tid, res: INTEGER; ctx: CoreContext; t: Kernel.Thread;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);

    (* core context data structure *)
    NEW(coreCon[cid]); ASSERT(coreCon[cid] # NIL, Errors.HeapOverflow);
    ctx := coreCon[cid];
    ctx.numSndRcv := 0;

    (* sender/receivers *)
    i := 0;
    WHILE i < MaxNumSndRcv DO
      NEW(ctx.sndRcv[i]); ASSERT(ctx.sndRcv[i] # NIL, Errors.HeapOverflow);
      ctx.sndRcv[i].state := Unsubscribed;
      ctx.sndRcv[i].sndRdy := FALSE;
      (* signals *)
      NEW(ctx.sndRcv[i].sigIn); ASSERT(ctx.sndRcv[i].sigIn # NIL, Errors.HeapOverflow);
      Signals.Init(ctx.sndRcv[i].sigIn);
      NEW(ctx.sndRcv[i].sigOut); ASSERT(ctx.sndRcv[i].sigOut # NIL, Errors.HeapOverflow);
      Signals.Init(ctx.sndRcv[i].sigOut);
      INC(i)
    END;

    (* send/receive thread at the fifo *)
    Kernel.Allocate(fifoc, FifoStackSize, t, tid, res); ASSERT(res = Kernel.NoError, Errors.Config);
    Kernel.SetPeriod(t, period, 0);
    Kernel.SetPrio(t, prio);
    Kernel.Enable(t)
  END Install;

END Messages.

