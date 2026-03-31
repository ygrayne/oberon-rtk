MODULE GPIOdef;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  MCU-specific API definitions for GPIO
  --
  Type: MCU
  --
  MCU: STM32U585AI
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)


  CONST
    (* port numbers (API parameter portNo) *)
    PORTA* = 0;
    PORTB* = 1;
    PORTC* = 2;
    PORTD* = 3;
    PORTE* = 4;
    PORTF* = 5;
    PORTG* = 6;
    PORTH* = 7;
    PORTI* = 8;
    NumPort* = 9;

END GPIOdef.
