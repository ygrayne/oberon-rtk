MODULE GPIO;
(**
  Oberon RTK Framework
  --
  General Purpose IO (GPIO)
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  Datasheet:
  * 2.19.6.1, p243 (GPIO)
  * 2.19.6.3, p298 (banks and pads)
  * 2.3.1.17, p42 (SIO)
  --
  Pin mumbers 0 .. 29, on "lo bank" (IO_BANK0)
  The "hi bank" for QPSI is not handled here.
  --
  Copyright (c) 2023-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, StartUp;

  CONST
    (* pads *)
    Enabled* = 1;
    Disabled* = 0;
    CurrentValue* = -1;
    Drive2mA*  = 0;
    Drive4mA*  = 1;  (* reset *)
    Drive8mA*  = 2;
    Drive12mA* = 3;
    SlewSlow*  = 0;  (* reset *)
    SlewFast*  = 1;

    OD = 7; (* output disable *)
    IE = 6; (* input enable *)

    (* functions *)
    F1* = 1;   F2* = 2;   F3* = 3;   F4* = 4;
    F5* = 5;   F6* = 6;   F7* = 7;   F8* = 8;   F9* = 9;

    Fspi* = F1;
    Fuart* = F2;
    Fi2c* = F3;
    Fpwm* = F4;
    Fsio* = F5;
    Fpio0* = F6;
    Fpio1* = F7;
    Fclk* = F8;
    Fusb* = F9;


  TYPE
    PadConfig* = RECORD
      drive*: INTEGER;     (* reset: Drive4mA *)
      pullUp*: INTEGER;    (* reset: Disabled *)
      pullDown*: INTEGER;  (* reset: Enabled *)
      schmittTrig*: INTEGER;   (* reset: Enabled *)
      slewRate*: INTEGER   (* reset: SlewSlow *)
    END;

  (* --- GPIO device --- *)

  PROCEDURE SetFunction*(pinNo, functionNo: INTEGER);
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_GPIO_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, functionNo);
    SYSTEM.PUT(addr, x)
  END SetFunction;

  PROCEDURE SetInverters*(pinNo: INTEGER; mask: SET);
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_GPIO_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 31, 5, ORD(mask));
    SYSTEM.PUT(addr, x)
  END SetInverters;

  (* define interrupts functions here *)
  (* ... *)

  (* --- pad --- *)

  PROCEDURE ConfigurePad*(pinNo: INTEGER; cfg: PadConfig);
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    IF cfg.drive # CurrentValue THEN BFI(x, 5, 4, cfg.drive) END;
    IF cfg.pullUp # CurrentValue THEN BFI(x, 3, cfg.pullUp) END;
    IF cfg.pullDown # CurrentValue THEN BFI(x, 2, cfg.pullDown) END;
    IF cfg.schmittTrig # CurrentValue THEN BFI(x, 1, cfg.schmittTrig) END;
    IF cfg.slewRate # CurrentValue THEN BFI(x, 0, cfg.slewRate) END;
    SYSTEM.PUT(addr, x)
  END ConfigurePad;


  PROCEDURE DisableOutput*(pinNo: INTEGER);
  (* reset: enabled *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO + MCU.ASET + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {OD})
  END DisableOutput;


  PROCEDURE DisableInput*(pinNo: INTEGER);
  (* reset: enabled *)
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.PADS_BANK0_GPIO + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {IE})
  END DisableInput;


  (* GPIO control via SIO *)
  (* Need to select function 'Fsio' *)

  PROCEDURE Set*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_SET, mask)
  END Set;

  PROCEDURE Clear*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, mask)
  END Clear;

  PROCEDURE Toggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_XOR, mask)
  END Toggle;

  PROCEDURE Get*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value)
  END Get;

  PROCEDURE Put*(value: SET);
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OUT, value)
  END Put;

  PROCEDURE GetBack*(VAR value: INTEGER);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OUT, value)
  END GetBack;

  PROCEDURE Check*(mask: SET): BOOLEAN;
    VAR value: SET;
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_IN, value);
    RETURN value * mask # {}
  END Check;

  PROCEDURE OutputEnable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, mask)
  END OutputEnable;

  PROCEDURE OutputDisable*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_CLR, mask)
  END OutputDisable;

  PROCEDURE OutputEnToggle*(mask: SET);
  (* atomic *)
  BEGIN
    SYSTEM.PUT(MCU.SIO_GPIO_OE_XOR, mask)
  END OutputEnToggle;

  PROCEDURE GetOutputEnable*(VAR value: SET);
  BEGIN
    SYSTEM.GET(MCU.SIO_GPIO_OE, value)
  END GetOutputEnable;

  PROCEDURE init;
  BEGIN
    StartUp.ReleaseReset(MCU.RESETS_IO_BANK0);
    StartUp.AwaitReleaseDone(MCU.RESETS_IO_BANK0);
    StartUp.ReleaseReset(MCU.RESETS_PADS_BANK0);
    StartUp.AwaitReleaseDone(MCU.RESETS_PADS_BANK0)
  END init;

BEGIN
  init
END GPIO.
