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

    PCR_LK = 15;    (* lock *)
    PCR_INV = 13;   (* input inverter *)
    PCR_IBE = 12;   (* input buffer enable *)
    PCR_MUX_1 = 11; (* function *)
    PCR_MUX_0 = 8;
    PCR_DSE1 = 7;   (* drive strength 1, only port 3, not all pins *)
      PCR_DSE1_val_normal = 0;
      PCR_DSE1_val_double = 1;
    PCR_DSE = 6;    (* drive strength *)
      PCR_DSE_val_low = 0;
      PCR_DSE_val_high = 1;
    PCR_ODE = 5;    (* open drain enable *)
    PCR_PFE = 4;    (* passive filter enable *)
    PCR_SRE = 3;    (* slew rate *)
      PCR_SRE_val_fast = 0;
      PCR_SRE_val_slow = 1;
    PCR_PE = 1;     (* pull enable *)
    PCR_PS = 0;     (* pull select *)
      PCR_PS_val_down = 0;
      PCR_PS_val_up = 1;

    (* value aliases *)
    SlewSlow* = PCR_SRE_val_slow;
    SlewFast* = PCR_SRE_val_fast;
    DriveLow* = PCR_DSE_val_low;
    DriveHigh* = PCR_DSE_val_high;
    DriveNormal* = PCR_DSE1_val_normal;
    DriveDouble* = PCR_DSE1_val_double;
    PullDown* = PCR_PS_val_down;
    PullUp* = PCR_PS_val_up;

    (* functions *)
    (* check port map to select applicable value for a specific pin *)

    Fio0*       = 0;
    Fclkout0*   = 1;
    Fewm0*      = 1;
    Ffreqme0*   = 1;
    Fflexcom0*  = 2;

(*
    Fio0*       = 0;
    Fcan0*      = 11;
    Fclkout0*   = 1;
    Fclkout1*   = 12;
    Fcmp0*      = 8;
    Fct0*       = 4;
    Fct1*       = 5;
    Ffrqme0*    = 1;
    Ffrqme1*    = 12;
    Fi2c0*      = 2;
    Fi2c1*      = 3;
    Fpwm0*      = 5;
    Fpwm1*      = 7;
    Fsmartdma0* = 7;
    Fsmartdma1* = 10;
    Fspi0*      = 2;
    Fspi1*      = 3;
    Ftamper0*   = 13;
    Ftrig0*     = 1;
    Fuart0*     = 2;
    Fuart1*     = 3;
    Fuart2*     = 8;
    Futick0*    = 5;
    Fwuu0*      = 13;
*)

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


  PROCEDURE* ConfigurePad*(pin: INTEGER; cfg: PadCfg);
    VAR pcr, val: INTEGER;
  BEGIN
    pcr := MCU.PORT0_BASE + ((pin DIV 32) * MCU.PORT_Offset);
    pcr := pcr + MCU.PORT_PCR_Offset + ((pin MOD 32) * 4);
    SYSTEM.GET(pcr, val);
    BFI(val, PCR_INV, cfg.inputInv);
    BFI(val, PCR_IBE, cfg.inputBufEn);
    BFI(val, PCR_DSE1, cfg.driveStrength1);
    BFI(val, PCR_DSE, cfg.driveStrength);
    BFI(val, PCR_ODE, cfg.openDrainEn);
    BFI(val, PCR_PFE, cfg.filterEn);
    BFI(val, PCR_SRE, cfg.slewRate);
    BFI(val, PCR_PE, cfg.pullEn);
    BFI(val, PCR_PS, cfg.pullSel);
    SYSTEM.PUT(pcr, val)
  END ConfigurePad;


  PROCEDURE* GetPadConfig*(pin: INTEGER; VAR pcrVal: INTEGER);
    VAR pcr: INTEGER;
  BEGIN
    pcr := MCU.PORT0_BASE + ((pin DIV 32) * MCU.PORT_Offset);
    pcr := pcr + MCU.PORT_PCR_Offset + ((pin MOD 32) * 4);
    SYSTEM.GET(pcr, pcrVal)
  END GetPadConfig;


  PROCEDURE* GetPadBaseCfg*(VAR cfg: PadCfg);
  BEGIN
    CLEAR(cfg)
  END GetPadBaseCfg;


  PROCEDURE* LockPad*(pin: INTEGER);
    VAR pcr, val: INTEGER;
  BEGIN
    pcr := MCU.PORT0_BASE + ((pin DIV 32) * MCU.PORT_Offset);
    pcr := pcr + MCU.PORT_PCR_Offset + ((pin MOD 32) * 4);
    SYSTEM.GET(pcr, val);
    BFI(val, PCR_LK, Enabled);
    SYSTEM.PUT(pcr, val)
  END LockPad;


  PROCEDURE* SetFunction*(pin, function: INTEGER);
    VAR pcr, val: INTEGER;
  BEGIN
    pcr := MCU.PORT0_BASE + ((pin DIV 32) * MCU.PORT_Offset);
    pcr := pcr + MCU.PORT_PCR_Offset + ((pin MOD 32) * 4);
    SYSTEM.GET(pcr, val);
    BFI(val, PCR_MUX_1, PCR_MUX_0, function);
    SYSTEM.PUT(pcr, val)
  END SetFunction;


  PROCEDURE* ConnectInput*(pin: INTEGER);
  END ConnectInput;


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

(*
  PROCEDURE* Set*(port: INTEGER; mask: SET);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.RGPIO0_BASE + MCU.RGPIO_PSOR_Offset + (port * MCU.RGPIO_Offset);
    SYSTEM.PUT(addr, mask)
  END Set;

  PROCEDURE* Clear*(port: INTEGER; mask: SET);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.RGPIO0_BASE + MCU.RGPIO_PCOR_Offset + (port * MCU.RGPIO_Offset);
    SYSTEM.PUT(addr, mask)
  END Clear;

  PROCEDURE* Toggle2*(port: INTEGER; mask: SET);
    VAR addr: INTEGER;
  BEGIN
    addr := MCU.RGPIO0_BASE + MCU.RGPIO_PTOR_Offset + (port * MCU.RGPIO_Offset);
    SYSTEM.PUT(addr, mask)
  END Toggle2;
*)
