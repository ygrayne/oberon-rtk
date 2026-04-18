MODULE SIOgpio;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  SIO
  --
  MCU:
    RP2350A (30 GPIO: 0 .. 29)
    RP2350B (48 GPIO: 0 .. 47)
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, DEV := SIO_DEV;

  CONST
    (* handles *)
    GPIOA* = DEV.GPIOA; (* pins 0 .. 31 *)
    GPIOB* = DEV.GPIOB; (* pins 32 .. 47 *)


  PROCEDURE* Set*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + DEV.SIO_GPIO_OUT_SET_Offset, pinMask)
  END Set;


  PROCEDURE* Clear*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + DEV.SIO_GPIO_OUT_CLR_Offset, pinMask)
  END Clear;


  PROCEDURE* Toggle*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + DEV.SIO_GPIO_OUT_XOR_Offset, pinMask)
  END Toggle;


  PROCEDURE* Get*(gpio: INTEGER; VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(gpio, pinVal)
  END Get;


  PROCEDURE* Put*(gpio: INTEGER; pinVal: SET);
  BEGIN
    SYSTEM.PUT(gpio + DEV.SIO_GPIO_OUT_Offset, pinVal)
  END Put;

(*
  PROCEDURE* PutPin*(pin: INTEGER; setPin: BOOLEAN);
    VAR addr: INTEGER;
  BEGIN
    IF pin < 32 THEN
      IF setPin THEN
        addr := DEV_2.SIO_GPIO_OUT_SET
      ELSE
        addr := DEV_2.SIO_GPIO_OUT_CLR
      END
    ELSE
      pin := pin - 32;
      IF setPin THEN
        addr := DEV_2.SIO_GPIO_HI_OUT_SET
      ELSE
        addr := DEV_2.SIO_GPIO_HI_OUT_CLR
      END
    END;
    SYSTEM.PUT(addr, {pin})
  END PutPin;
*)

  PROCEDURE* Check*(gpio: INTEGER; pinMask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(gpio, value);
    RETURN value * pinMask # {}
  END Check;


  PROCEDURE* EnableOutput*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + DEV.SIO_GPIO_OE_SET_Offset, pinMask)
  END EnableOutput;


  (* disabling output sets pin to hi-z (tri-state) *)

  PROCEDURE* DisableOutput*(gpio: INTEGER; pinMask: SET);
  BEGIN
    SYSTEM.PUT(gpio + DEV.SIO_GPIO_OE_CLR_Offset, pinMask)
  END DisableOutput;


  PROCEDURE* GetEnabledOutput*(gpio: INTEGER; VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(gpio + DEV.SIO_GPIO_OE_Offset, pinVal)
  END GetEnabledOutput;


END SIOgpio.
