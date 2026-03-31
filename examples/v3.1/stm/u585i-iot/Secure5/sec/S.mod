MODULE S;
(**
  Oberon RTK Framework v3.0
  --
  Experimental program Secure5
  https://oberon-rtk.org/docs/examples/v3/secure5/
  Secure program
  --
  MCU: STM32U585
  Board: B-U585I-IOT02A
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, DEV2, S0, Secure, RST, GPIO, GPIOdef;

  CONST
    (* Secure GPIOH registers, due to correct (S) MCU.mod picked via lib search path *)
    (* some direct-register shenagians, to use S0.SetBits across S/NS boundary *)
    GPIOH_BSSR* = DEV2.GPIOH_BASE + DEV2.GPIO_BSRR_Offset;
    GPIOH_MODER = DEV2.GPIOH_BASE + DEV2.GPIO_MODER_Offset;
    GPIOH_OSPEEDR = DEV2.GPIOH_BASE + DEV2.GPIO_OSPEEDR_Offset;

    (* Non-secure program flash address *)
    NSimageAddr = 08100000H;

    LEDred   = 6; (* GPIOH *)
    LEDgreen = 7;
    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE cfgGPIO; (* Secure part *)
    VAR twoBits: S0.TwoBits;
  BEGIN
    (*ASSERT(FALSE);*)
    RST.EnableBusClock(DEV2.GPIO_BC_EN, GPIOdef.PORTH);
    GPIO.SetNonSecPins(GPIOdef.PORTH, {LEDgreen});

    (* config Secure LEDred pin *)
    twoBits.pin := LEDred;
    twoBits.addr := GPIOH_MODER;
    twoBits.value := MODER_Out;
    S0.SetBits(twoBits);
    twoBits.addr := GPIOH_OSPEEDR;
    twoBits.value := OSPEED_High;
    S0.SetBits(twoBits);

    (* LEDred off *)
    SYSTEM.PUT(GPIOH_BSSR, {LEDred});
    (*ASSERT(FALSE);*)
  END cfgGPIO;


BEGIN
  cfgGPIO;
  Secure.StartNonSecProg(NSimageAddr, 0)
END S.
