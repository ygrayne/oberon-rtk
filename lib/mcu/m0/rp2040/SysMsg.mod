MODULE SysMsg;
(**
  Oberon RTK Framework
  System messages via inter-core FIFO
  Prototype
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MultiCore, Out;

  CONST
    (* message types *)
    MsgWatchdog* = 0;

    (* message receivers *)
    RecSystem* = 0FFH;

  TYPE
    MsgData = ARRAY 4 OF BYTE;


  PROCEDURE Send*(msgType, toThread, fromThread, data: BYTE);
    VAR m: MsgData;
  BEGIN
    m[3] := msgType;
    m[2] := toThread;
    m[1] := fromThread;
    m[0] := data;
    MultiCore.Send(m)
  END Send;


  PROCEDURE Receive*(VAR msgType, toThread, fromThread, data: BYTE);
    VAR m: MsgData;
  BEGIN
    MultiCore.Receive(m);
    msgType := m[3];
    toThread := m[2];
    fromThread := m[1];
    data := m[0]
  END Receive;


  PROCEDURE SendAvailable*(): BOOLEAN;
    RETURN MultiCore.Ready()
  END SendAvailable;


  PROCEDURE ReceiveAvailable*(): BOOLEAN;
    RETURN MultiCore.Valid()
  END ReceiveAvailable;


  PROCEDURE init;
  BEGIN
    MultiCore.Flush
  END init;

BEGIN
  init
END SysMsg.

