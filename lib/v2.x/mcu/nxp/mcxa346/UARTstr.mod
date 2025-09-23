MODULE UARTstr;
(**
  Oberon RTK Framework v2.1
  --
  UART string device driver, kernel not required (busy waiting)
  --
  MCU: MCX-A346
  --
  Copyright (c) 2020-2025 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UARTdev, TextIO;


  PROCEDURE* PutChar*(dev: TextIO.Device; ch: CHAR);
    VAR dev0: UARTdev.Device;
  BEGIN
    dev0 := dev(UARTdev.Device);
    REPEAT UNTIL SYSTEM.BIT(dev0.STAT, UARTdev.STAT_TDRE);
    SYSTEM.PUT(dev0.DATA, ch)
  END PutChar;


  PROCEDURE* PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTdev.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UARTdev.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF SYSTEM.BIT(dev0.STAT, UARTdev.STAT_TDRE) THEN
        SYSTEM.PUT(dev0.DATA, s[i]);
        INC(i)
      END
    END
  END PutString;


  PROCEDURE GetString*(dev: TextIO.Device; VAR s: ARRAY OF CHAR; VAR numChar, res: INTEGER);
  END GetString;

END UARTstr.
