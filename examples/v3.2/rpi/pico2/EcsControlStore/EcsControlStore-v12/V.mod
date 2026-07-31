MODULE V;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  V = Values
  --
  Operational values: tuning parameters, changeable without
  impact on the system structure (W).
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    TickPeriod* = 10; (* milliseconds *)

    (* kernel-based periods are in kernel ticks *)
    BlinkPeriod_0* = 400 DIV TickPeriod;
    BlinkPeriod_1* = 650 DIV TickPeriod;
    HeartbeatPeriod* = 1000 DIV TickPeriod;

    DrainBaudrate* = 38400;

END V.
