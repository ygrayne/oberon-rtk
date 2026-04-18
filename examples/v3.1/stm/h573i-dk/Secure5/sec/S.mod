MODULE S;
(**
  Oberon RTK Framework v3.1
  --
  Test program Secure5
  Secure program
  --
  MCU: STM32H573II
  Board: STM32H573I-DK
  --
  Copyright (c) 2025-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, Main, DEV := GPIO_DEV, S0, Secure, RST, GPIO, Out;

  CONST
    (* Secure GPIOH registers, due to correct (S) BASE.mod picked via lib search path *)
    (* some direct-register shenagians, to use S0.SetBits across S/NS boundary *)
    GPIOF_BSSR* = DEV.GPIOF_BASE + DEV.GPIO_BSRR_Offset;
    GPIOF_MODER = DEV.GPIOF_BASE + DEV.GPIO_MODER_Offset;
    GPIOF_OSPEEDR = DEV.GPIOF_BASE + DEV.GPIO_OSPEEDR_Offset;

    (* Non-secure program flash address *)
    NSimageAddr = 08100000H;

    LEDred   = 1;
    LEDblue = 4;
    MODER_Out = 1;
    OSPEED_High = 2;


  PROCEDURE cfgGPIO; (* Secure part *)
    VAR twoBits: S0.TwoBits;
  BEGIN
    (*ASSERT(FALSE);*)
    RST.EnableBusClock(DEV.GPIO_BC_reg, GPIO.PORTH);
    GPIO.SetNonSecPins(GPIO.PORTF, {LEDblue});

    (* config Secure LEDred pin *)
    twoBits.pin := LEDred;
    twoBits.addr := GPIOF_MODER;
    twoBits.value := MODER_Out;
    S0.SetBits(twoBits);
    twoBits.addr := GPIOF_OSPEEDR;
    twoBits.value := OSPEED_High;
    S0.SetBits(twoBits);

    (* LEDred off *)
    SYSTEM.PUT(GPIOF_BSSR, {LEDred});
    (*ASSERT(FALSE)*)
  END cfgGPIO;


BEGIN
  Out.String("start S"); Out.Ln;
  cfgGPIO;
  Secure.StartNonSecProg(NSimageAddr, 0)
END S.
