MODULE UARTbinding;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v7
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, UART;

  CONST
    Baudrate1 = 38400;
    UART1 = UART.UART1;
    UART1_TxPinNo = 4;
    UART1_RxPinNo = 5;

  (* UART *)
  PROCEDURE cfgPins(txPin, rxPin: INTEGER);
    VAR pinCfg: GPIO.PinCfg;
  BEGIN
    GPIO.GetPinBaseCfg(pinCfg);
    pinCfg.pullupEn := GPIO.Enabled;
    pinCfg.pulldownEn := GPIO.Disabled;
    GPIO.Attach;
    GPIO.ConfigurePin(txPin, pinCfg);
    GPIO.ConfigurePin(rxPin, pinCfg);
    GPIO.ConnectInput(rxPin);
    GPIO.SetFunction(txPin, GPIO.Fuart);
    GPIO.SetFunction(rxPin, GPIO.Fuart)
  END cfgPins;

  PROCEDURE Config*(uartDev: UART.Device);
    VAR uartCfg: UART.DeviceCfg;
  BEGIN
    cfgPins(UART1_TxPinNo, UART1_RxPinNo);
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    UART.Init(uartDev, UART1);
    UART.Configure(uartDev, uartCfg, Baudrate1);
    UART.Enable(uartDev)
  END Config;

END UARTbinding.
