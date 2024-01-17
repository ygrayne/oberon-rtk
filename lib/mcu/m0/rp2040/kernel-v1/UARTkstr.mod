MODULE UARTkstr;
(**
  Oberon RTK Framework
  * for kernel use
  * text IO procedures
  * hw-buffered (fifo)
  * wait for 'write buffer empty' on 'write buffer full'
  --
  Copyright (c) 2020-2024 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, UARTd, TextIO, Kernel;


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
      ELSE
        Kernel.AwaitDeviceSet(dev0.FR, {UARTd.FR_TXFE})
      END
    END
  END PutString;


  PROCEDURE GetString*(dev: TextIO.Device; VAR string: ARRAY OF CHAR; del: CHAR);
  END GetString;

END UARTkstr.
