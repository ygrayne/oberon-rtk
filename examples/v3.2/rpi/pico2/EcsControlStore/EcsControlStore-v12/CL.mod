MODULE CL;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  CL = Components Locked
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT W, I;

  TYPE
    (* locked: SenseSystem, ActuateSystem *)
    LedBinding* = RECORD
      ledPin*: INTEGER
    END;

    (* locked: CoupleSystem *)
    LedFollower* = RECORD
      follows*: INTEGER;
    END;

    (* locked: DrainSystem *)
    UartBinding* = RECORD
      devHandle*: INTEGER
    END;

    (* locked cross-system: HeartbeatSystem, TickMonitorSystem *)
    PrintWriter* = RECORD
      writerHandle*: INTEGER
    END;

    (* locked cross-system: PrintSystem, HeartbeatSystem, TickMonitorSystem *)
    PrintBuf* = RECORD
      devHandle*: INTEGER
    END;

    (* locked: PrintSystem, DrainSystem *)
    DrainBuf* = RECORD
      devHandle*: INTEGER
    END;

    (* locked: HeartbeatSystem *)
    TimerBinding* = RECORD
      devHandle*: INTEGER
    END;


  VAR
    ledBindingLeader*: ARRAY W.Leader_Num OF LedBinding;
    ledBindingFollower*: ARRAY W.Follower_Num OF LedBinding;
    ledFollower*: ARRAY W.Follower_Num OF LedFollower;

    printWriter*: ARRAY W.Printer_Num OF PrintWriter;
    printBuf*: ARRAY W.Printer_Num OF PrintBuf;

    uartBinding*: UartBinding;
    drainBuf*: DrainBuf;
    timerBinding*: TimerBinding;

BEGIN
  ledBindingLeader[0].ledPin := W.Pin_Leader_0;
  ledBindingLeader[1].ledPin := W.Pin_Leader_1;

  ledBindingFollower[0].ledPin := W.Pin_Follower_0;
  ledBindingFollower[1].ledPin := W.Pin_Follower_1;

  ledFollower[0].follows := I.Leader_1;
  ledFollower[1].follows := I.Leader_0;

  printWriter[I.Printer_Heartbeat].writerHandle := W.WriterHandle_A;
  printWriter[I.Printer_TickMonitor].writerHandle := W.WriterHandle_B;

  printBuf[I.Printer_Heartbeat].devHandle := W.PrintBufHandle_A;
  printBuf[I.Printer_TickMonitor].devHandle := W.PrintBufHandle_B;

  uartBinding.devHandle := W.UartHandle_Drain;
  drainBuf.devHandle := W.DrainBufHandle_Tx;

  timerBinding.devHandle := W.TimerHandle_Heartbeat
END CL.
