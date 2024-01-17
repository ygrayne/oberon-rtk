MODULE UARTstr;
(**
  Oberon RTK Framework
  * text IO procedures
  * hw-buffered (fifo)
  * busy-waiting with buffer full
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UARTd, TextIO;

(* to be removed
  PROCEDURE* PutChar*(dev: TextIO.Device; ch: CHAR);
    VAR dev0: UARTd.Device;
  BEGIN
    dev0 := dev(UARTd.Device);
    REPEAT UNTIL ~SYSTEM.BIT(dev0.FR, UARTd.FR_TXFF); (* not full *)
    SYSTEM.PUT(dev0.TDR, ch)
  END PutChar;
*)
(* to be removed
  PROCEDURE* GetChar*(dev: TextIO.Device; VAR ch: CHAR);
    VAR dev0: UARTd.Device;
  BEGIN
    dev0 := dev(UARTd.Device);
    REPEAT UNTIL ~SYSTEM.BIT(dev0.FR, UARTd.FR_RXFE);
    SYSTEM.GET(dev0.RDR, ch)
  END GetChar;
*)


  PROCEDURE PutString*(dev: TextIO.Device; s: ARRAY OF CHAR; numChar: INTEGER);
    VAR dev0: UARTd.Device; i: INTEGER;
  BEGIN
    dev0 := dev(UARTd.Device);
    IF numChar > LEN(s) THEN numChar := LEN(s) END;
    i := 0;
    WHILE i < numChar DO
      IF ~SYSTEM.BIT(dev0.FR, UARTd.FR_TXFF) THEN (* not full *)
        SYSTEM.PUT(dev0.TDR, s[i]);
        INC(i)
      END
    END
  END PutString;

  PROCEDURE GetString*(dev: TextIO.Device; VAR string: ARRAY OF CHAR; del: CHAR);
  END GetString;

END UARTstr.
