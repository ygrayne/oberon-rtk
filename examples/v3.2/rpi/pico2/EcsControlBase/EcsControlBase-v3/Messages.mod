MODULE Messages;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v3
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  TYPE
    Message* = POINTER TO MessageDesc;
    MessageDesc* = RECORD END;

END Messages.
