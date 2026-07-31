MODULE CS;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  CS = Components State
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT W, Errors;

  CONST
    (* toposort tokens -> see Systems' Manifests *)
    LedMeasuredId* = 0;
    LedSetpointLeaderId* = 1;
    LedSetpointFollowerId* = 2;
    BlinkConfigId* = 3;
    PrintCursorId* = 4;
    PrintBufId* = 5;
    HeartbeatStatusId* = 6;
    DrainBufId* = 7;  (* edge token: pure ID, no TYPE *)

    NumComponents* = 8;


  TYPE
    BlinkConfig* = RECORD
      period*: INTEGER;
      ticker*: INTEGER
    END;

    LedMeasured* = RECORD
      value*: INTEGER
    END;

    LedSetpoint* = RECORD
      value*: INTEGER
    END;

    PrintBuf* = RECORD
      seq*: INTEGER
    END;

    PrintCursor* = RECORD
      seqDone*: INTEGER
    END;

    HeartbeatStatus* = RECORD
      count*: INTEGER;
      last*: INTEGER
    END;

    Store* = POINTER TO StoreDesc;
    StoreDesc* = RECORD
      (* producer: SenseSystem -> token 0 *)
      (* consumers: CoupleSystem, ActuateSystem *)
      ledMeasuredLeader*: ARRAY W.Leader_Num OF LedMeasured;
      ledMeasuredFollower*: ARRAY W.Follower_Num OF LedMeasured;

      (* producer: BlinkSystem -> token 1 *)
      (* consumer: ActuateSystem *)
      ledSetpointLeader*: ARRAY W.Leader_Num OF LedSetpoint;

      (* producer: CoupleSystem -> token 2 *)
      (* consumer: ActuateSystem *)
      ledSetpointFollower*: ARRAY W.Follower_Num OF LedSetpoint;

      (* owned: BlinkSystem -> token 3 *)
      blinkConfig*: ARRAY W.Leader_Num OF BlinkConfig;

      (* owned: PrintSystem -> token 4 *)
      printCursor*: ARRAY W.Printer_Num OF PrintCursor;

      (* producers: HeartbeatSystem, TickMonitorSystem -> token 5 *)
      (* consumer: PrintSystem *)
      printBuf*: ARRAY W.Printer_Num OF PrintBuf;

      (* owned: HeartbeatSystem -> token 6 *)
      heartbeatStatus*: HeartbeatStatus
    END;

  VAR
    S*: Store;

  PROCEDURE Build*;
  BEGIN
    NEW(S); ASSERT(S # NIL, Errors.HeapOverflow)
  END Build;

END CS.
