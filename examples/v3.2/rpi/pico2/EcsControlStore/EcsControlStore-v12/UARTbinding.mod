MODULE UARTbinding;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlStore-12
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT GPIO, UART;

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

  PROCEDURE Config*(uartHandle, txPinNo, rxPinNo, baudrate: INTEGER);
    VAR uartCfg: UART.DeviceCfg;
  BEGIN
    cfgPins(txPinNo, rxPinNo);
    UART.GetBaseCfg(uartCfg);
    uartCfg.fifoEn := UART.Enabled;
    UART.Configure(uartHandle, uartCfg, baudrate);
    UART.Enable(uartHandle)
  END Config;

END UARTbinding.
