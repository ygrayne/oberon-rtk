MODULE GPIO;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  General Purpose IO (GPIO)
  --
  MCU: MCXN947
  --
  Copyright (c) 2023-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2;


  CONST
    Enabled* = 1;
    Disabled* = 0;

    SlewSlow* = 1;
    SlewFast* = 0;

    DriveLow* = 0;
    DriveHigh* = 1;
    DriveNormal* = 0;
    DriveDouble* = 1;

    PullDown* = 0;
    PullUp* = 1;

    (* functions *)
    (* check port map to select applicable value for a specific pin *)

    Fio0*       = 0;
    Fclkout0*   = 1;
    Fewm0*      = 1;
    Ffreqme0*   = 1;
    Fflexcom0*  = 2;


  TYPE
    PadCfg* = RECORD            (* PCR: first value: reset/base state *)
      inputInv*: INTEGER;       (* disabled/enabled *)
      inputBufEn*: INTEGER;     (* disabled/enabled *)
      driveStrength1*: INTEGER; (* normal/double *)
      driveStrength*: INTEGER;  (* low/high *)
      openDrainEn*: INTEGER;    (* disabled/enabled *)
      filterEn*: INTEGER;       (* disabled/enabled *)
      slewRate*: INTEGER;       (* fast/slow *)
      pullEn*: INTEGER;         (* disabled/enabled *)
      pullSel*: INTEGER         (* down/up *)
    END;

    Pin* = RECORD
      pinNo: INTEGER;
      port: INTEGER
    END;


  PROCEDURE* ConfigurePad*(port, pin: INTEGER; cfg: PadCfg);
  (* parameter 'port': MCU.PORTx *)
    VAR pcr, val: INTEGER;
  BEGIN
    pcr := port + MCU.PORT_PCR_Offset + (pin * 4);
    SYSTEM.GET(pcr, val);
    BFI(val, 13, cfg.inputInv);
    BFI(val, 12, cfg.inputBufEn);
    BFI(val, 7, cfg.driveStrength1);
    BFI(val, 6, cfg.driveStrength);
    BFI(val, 5, cfg.openDrainEn);
    BFI(val, 4, cfg.filterEn);
    BFI(val, 3, cfg.slewRate);
    BFI(val, 1, cfg.pullEn);
    BFI(val, 0, cfg.pullSel);
    SYSTEM.PUT(pcr, val)
  END ConfigurePad;


  PROCEDURE* GetPadBaseCfg*(VAR cfg: PadCfg);
  BEGIN
    CLEAR(cfg)
  END GetPadBaseCfg;


  PROCEDURE* SetFunction*(port, pin, function: INTEGER);
  (* parameter 'port': MCU.PORTx *)
    VAR pcr, val: INTEGER;
  BEGIN
    pcr := port + MCU.PORT_PCR_Offset + (pin * 4);
    SYSTEM.GET(pcr, val);
    BFI(val, 11, 8, function);
    SYSTEM.PUT(pcr, val)
  END SetFunction;


  (* GPIO control *)
  (* function 'Fio' *)
  (* parameter 'gpio': MCU.GPIOx *)

  PROCEDURE* Set*(gpio: INTEGER; mask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.GPIO_PSOR_Offset, mask)
  END Set;


  PROCEDURE* Clear*(gpio: INTEGER; mask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.GPIO_PCOR_Offset, mask)
  END Clear;


  PROCEDURE* Toggle*(gpio: INTEGER; mask: SET);
  BEGIN
    SYSTEM.PUT(gpio + MCU.GPIO_PTOR_Offset, mask)
  END Toggle;


  PROCEDURE* EnableOutput*(gpio: INTEGER; mask: SET);
    VAR addr: INTEGER; val: SET;
  BEGIN
    addr := gpio + MCU.GPIO_PDDR_Offset;
    SYSTEM.GET(addr, val);
    val := val + mask;
    SYSTEM.PUT(addr, val)
  END EnableOutput;

END GPIO.
