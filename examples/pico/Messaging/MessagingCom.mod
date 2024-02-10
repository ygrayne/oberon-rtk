MODULE MessagingCom;
(**
  Oberon RTK Framework
  Example program, multi-threaded, multi-core
  Description: https://oberon-rtk.org/examples/messaging/
  --
  Shared module for message data and protocol: this module
  Program for core 0: 'MessagingC0'
  Program for core 1: 'MessagingC1'
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT Messages, Out;


  CONST
    BufferSize = 8;

    (* sender/receivers *)
    Asr* = 0;  (* SndRcv number for thread 'A', on core 0 *)
    Bsr* = 1;  (* SndRcv number for thread 'B', on core 0 *)

    Csr* = 0;  (* SndRcv number for thread 'C', on core 1 *)
    Dsr* = 1;  (* SndRcv number for thread 'D', on core 1 *)

    (* message numbers *)
    Wakeup0* = 0;
    Wakeup1* = 1;
    Wakeup2* = 2;

    DataReady* = 20;
    DataReceived* = 21;

  VAR
    data: ARRAY BufferSize OF INTEGER; (* access must be synchronised among threads *)

  (* message data *)

  PROCEDURE Put*(i, value: INTEGER);
  BEGIN
    data[i] := value
  END Put;

  PROCEDURE Get*(i: INTEGER): INTEGER;
    RETURN data[i]
  END Get;

  (* message protocol *)

  PROCEDURE Send*(sr: Messages.SndRcv; receiver, message: BYTE; sender: CHAR; data: BYTE; VAR flags: SET);
    VAR msg: Messages.Message;
  BEGIN
    msg[0] := receiver;
    msg[1] := message;
    msg[2] := ORD(sender);
    msg[3] := data;
    Messages.PutSnd(sr, msg, flags)
  END Send;


  PROCEDURE Receive*(sr: Messages.SndRcv; VAR receiver, message: BYTE; VAR sender: CHAR; VAR data: BYTE; VAR flags: SET);
    VAR msg: Messages.Message;
  BEGIN
    Messages.GetRcv(sr, msg, flags);
    receiver := msg[0];
    message := msg[1] ;
    sender := CHR(msg[2]);
    data := msg[3]
  END Receive;


  PROCEDURE Await*(sr: Messages.SndRcv);
  BEGIN
    Messages.AwaitRcv(sr)
  END Await;

  (* output helpers *)

  PROCEDURE WriteThreadInfo*(tid, cid: INTEGER);
  BEGIN
    Out.String("c"); Out.Int(cid, 0);
    Out.String("-t"); Out.Int(tid, 0)
  END WriteThreadInfo;


  PROCEDURE WriteMsgData*(msg: BYTE; sender: CHAR; data: BYTE);
  BEGIN
    Out.String(" rec msg: "); Out.Int(msg, 0);
    Out.String(" sender: "); Out.Char(sender);
    Out.String(" data: "); Out.Int(data, 0)
  END WriteMsgData;

END MessagingCom.

