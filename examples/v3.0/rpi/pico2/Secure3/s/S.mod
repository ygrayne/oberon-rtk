MODULE S;
(**
  Oberon RTK Framework v3.0
  --
  Exploration program Secure3
  https://oberon-rtk.org/docs/examples/v3/secure3/
  Secure program
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, MCU := MCU2, Main, Secure, SAU, AccessCtrl, S0;

  CONST
    NSimageAddr = 010400000H;
    NSCimageAddr = 010800000H;
    VTORoffset = 0000H;
    LEDpico = 25;
    LED0 = 27;
    LED1 = 28;
    LED2 = 26;
    LED3 = 22;
    LEDs = {22, 25, 26, 27, 28};


  PROCEDURE enableFaults;
  (* useful in debugger *)
    VAR val: SET;
  BEGIN
    SYSTEM.GET(MCU.PPB_SHCSR, val);
    val := val + {16, 17, 18, 19};
    SYSTEM.PUT(MCU.PPB_SHCSR, val)
  END enableFaults;


  PROCEDURE setFunction(pinNo: INTEGER);
    CONST PADS_ISO = 8;
    VAR addr, x: INTEGER;
  BEGIN
    addr := MCU.IO_BANK0_GPIO0_CTRL + (pinNo * MCU.IO_BANK0_GPIO_Offset);
    SYSTEM.GET(addr, x);
    BFI(x, 4, 0, MCU.IO_BANK0_Fsio);
    SYSTEM.PUT(addr, x);
    addr := MCU.PADS_BANK0_GPIO0 + MCU.ACLR + (pinNo * MCU.PADS_BANK0_GPIO_Offset);
    SYSTEM.PUT(addr, {PADS_ISO})
  END setFunction;


  PROCEDURE configGPIO;
    CONST Dev = {MCU.RESETS_IO_BANK0, MCU.RESETS_PADS_BANK0};
    VAR done: SET;
  BEGIN
    (* release resets *)
    SYSTEM.PUT(MCU.RESETS_RESET + MCU.ACLR, Dev);
    REPEAT
      SYSTEM.GET(MCU.RESETS_DONE, done)
    UNTIL done * Dev = Dev;
    setFunction(LEDpico);
    setFunction(LED0);
    setFunction(LED1);
    setFunction(LED2);
    setFunction(LED3);
    (* enable outputs and clear *)
    SYSTEM.PUT(MCU.SIO_GPIO_OE_SET, LEDs);
    SYSTEM.PUT(MCU.SIO_GPIO_OUT_CLR, LEDs);
    (* set LED pin to Non-secure access *)
    (* note: LEDpico remains Secure *)
    AccessCtrl.SetGPIOnonSec(MCU.ACCESSCTRL_GPIO_NSMASK0, {LED0});
  END configGPIO;


  PROCEDURE configSAU;
    CONST Disabled = 0; Enabled = 1;
    VAR cfg: SAU.RegionCfg; r: INTEGER;
  BEGIN
    (* SRAM *)
    cfg.baseAddr := 020040000H;
    cfg.limitAddr := 020080000H - 1;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(0, cfg);
    (* NS code 512k *)
    cfg.baseAddr := 010400000H;
    cfg.limitAddr := 010480000H - 1;
    cfg.nsc := Disabled;
    SAU.ConfigRegion(1, cfg);
    (* NSC code 32k *)
    cfg.baseAddr := 010800000H;
    cfg.limitAddr := 010808000H - 1;
    cfg.nsc := Enabled;
    SAU.ConfigRegion(2, cfg);
    (* make sure the unused regions are disabled *)
    (* leave reserved region 7 alone, even though it's not used here *)
    r := 3;
    WHILE r < 7 DO
      SAU.DisableRegion(r);
      INC(r)
    END;
    SAU.Enable
  END configSAU;


BEGIN
  enableFaults;
  configGPIO;
  configSAU;
  Secure.InstallNonSecImage(NSimageAddr);
  Secure.InstallNonSecCallImage(NSCimageAddr);
  Secure.StartNonSecProg(NSimageAddr, VTORoffset)
END S.
