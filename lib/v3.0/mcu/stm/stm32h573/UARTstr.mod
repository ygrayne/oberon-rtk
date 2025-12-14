MODULE UARTstr;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  UART string device driver, kernel not required (busy waiting)
  --
  MCU: STM32H573II
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UART, TextIO;


  PROCEDURE* PutChar*(dev: TextIO.Device; ch: CHAR);
    VAR dev0: UART.Device;
  BEGIN
    dev0 := dev(UART.Device);
    REPEAT UNTIL SYSTEM.BIT(dev0.ISR, UART.ISR_TXFNF);
    SYSTEM.PUT(dev0.TDR, ch)
  END PutChar;


  PROCEDURE* PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UART.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UART.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF SYSTEM.BIT(dev0.ISR, UART.ISR_TXFNF) THEN
        SYSTEM.PUT(dev0.TDR, s[i]);
        INC(i)
      END
    END
  END PutString;


  PROCEDURE* GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numChar, res: INTEGER);
  END GetString;

END UARTstr.
