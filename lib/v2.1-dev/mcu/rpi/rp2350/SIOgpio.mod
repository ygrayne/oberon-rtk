MODULE SIOgpio;
(**
  Oberon RTK Framework v2.1
  --
  SIO control of GPIO
  --
  MCU: RP2350A (30 GPIO: 0 .. 29), RP2350B (48 GPIO: 0 .. 47)
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;

  PROCEDURE* Set*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, mask)
  END Set;

  PROCEDURE* SetH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_SET, maskH)
  END SetH;


  PROCEDURE* Clear*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, mask)
  END Clear;

  PROCEDURE* ClearH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_CLR, maskH)
  END ClearH;


  PROCEDURE* Toggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, mask)
  END Toggle;

  PROCEDURE* ToggleH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT_XOR, maskH)
  END ToggleH;


  PROCEDURE* Get*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, pinVal)
  END Get;

  PROCEDURE* GetH*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, pinVal)
  END GetH;


  PROCEDURE* Put*(pinVal: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, pinVal)
  END Put;

  PROCEDURE* PutH*(pinValH: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OUT, pinValH)
  END PutH;


  PROCEDURE* PutPin*(pin: INTEGER; setPin: BOOLEAN);
  (* atomic *)
    VAR addr: INTEGER;
  BEGIN
    IF pin < 32 THEN
      IF setPin THEN
        addr := MCU.SIO_GPIO_OUT_SET
      ELSE
        addr := MCU.SIO_GPIO_OUT_CLR
      END
    ELSE
      pin := pin - 32;
      IF setPin THEN
        addr := MCU.SIO_GPIO_HI_OUT_SET
      ELSE
        addr := MCU.SIO_GPIO_HI_OUT_CLR
      END
    END;
    SYSTEM.PUT(addr, {pin})
  END PutPin;


  PROCEDURE* GetBack*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OUT, pinVal)
  END GetBack;

  PROCEDURE* GetBackH*(VAR pinValH: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_OUT, pinValH)
  END GetBackH;


  PROCEDURE* Check*(mask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * mask # {}
  END Check;

  PROCEDURE* CheckH*(maskH: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_IN, value);
    RETURN value * maskH # {}
  END CheckH;


  PROCEDURE* OutputEnable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, mask)
  END OutputEnable;

  PROCEDURE* OutputEnableH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_SET, maskH)
  END OutputEnableH;


  PROCEDURE* OutputDisable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, mask)
  END OutputDisable;

  PROCEDURE* OutputDisableH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_CLR, maskH)
  END OutputDisableH;


  PROCEDURE* OutputEnToggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_XOR, mask)
  END OutputEnToggle;

  PROCEDURE* OutputEnToggleH*(maskH: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_HI_OE_XOR, maskH)
  END OutputEnToggleH;


  PROCEDURE* GetOutputEnable*(VAR pinVal: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, pinVal)
  END GetOutputEnable;

  PROCEDURE* GetOutputEnableH*(VAR pinValH: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_HI_OE, pinValH)
  END GetOutputEnableH;

END SIOgpio.
