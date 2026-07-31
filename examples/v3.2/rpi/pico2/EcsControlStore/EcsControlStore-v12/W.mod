MODULE W;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  W = Wiring
  --
  Structural identity vocabulary: naming grammar Space_Member,
  reserved members X_Num (cardinality) and X_None (sentinel).
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT UART, TIMER, LEDbinding;

  CONST
    Leader_Num* = 2;
    Follower_Num* = 2;

    Printer_Num* = 2;
    PrintBufHandle_A* = 0;
    PrintBufHandle_B* = 1;
    WriterHandle_A* = 0;
    WriterHandle_B* = 1;

    (* handles as per device modules *)
    UartHandle_Drain* = 0; (* handle 1 is used by Console, one core (will fault with two cores used) *)
    TimerHandle_Heartbeat* = 0;
    DrainBufHandle_Tx* = 0;

    (* units: values per ref manual *)
    UartUnit_Drain* = UART.UART1;
    TimerUnit_Heartbeat* = TIMER.TIMER0;

    (* UART pins: chip numbering; as per the chip's wiring matrix *)
    Pin_DrainUartTx* = 4;
    Pin_DrainUartRx* = 5;

    (* LED pins: as per LEDext assignments/wiring *)
    Pin_Leader_0* = LEDbinding.LED0;
    Pin_Leader_1* = LEDbinding.LED3;
    Pin_Follower_0* = LEDbinding.LED1;
    Pin_Follower_1* = LEDbinding.LED2;

END W.
