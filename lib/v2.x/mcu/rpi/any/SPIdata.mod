MODULE SPIdata;
(**
  Oberon RTK Framework
  Version: v3.0
  --
  SPI data device driver
  * put and get data (only 8 bits data size (BYTE) transfers implemented as of now)
  * master mode
  * fifo buffered (8x 16 bit slots tx and rx each)
  * busy waiting (blocking)
  * MSB first only for now (hw does not support LSB first)
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2024-2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, SPId := SPIdev;

  CONST FifoDepth = SPId.FifoDepth;


  PROCEDURE PutByte*(dev: SPId.Device; data: BYTE);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(dev.SR, SPId.SR_TNF);
    SYSTEM.PUT(dev.TDR, data);
    REPEAT UNTIL SYSTEM.BIT(dev.SR, SPId.SR_RNE);
    SYSTEM.GET(dev.RDR, data)
  END PutByte;


  PROCEDURE GetByte*(dev: SPId.Device; VAR data: BYTE);
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(dev.SR, SPId.SR_TNF);
    SYSTEM.PUT(dev.TDR, dev.txShift);
    REPEAT UNTIL SYSTEM.BIT(dev.SR, SPId.SR_RNE);
    SYSTEM.GET(dev.RDR, data)
  END GetByte;


  PROCEDURE PutBytes*(dev: SPId.Device; txData: ARRAY OF BYTE; n: INTEGER);
    VAR iw, nw, nr, dummy: INTEGER;
  BEGIN
    ASSERT(n <= LEN(txData));
    iw := 0;
    nw := n; nr := n;
    WHILE (nw > 0) OR (nr > 0) DO
      WHILE (nw > 0) & (nr < nw + FifoDepth) & SYSTEM.BIT(dev.SR, SPId.SR_TNF) DO
        SYSTEM.PUT(dev.TDR, txData[iw]);
        INC(iw); DEC(nw)
      END;
      IF (nr > 0) & SYSTEM.BIT(dev.SR, SPId.SR_RNE) THEN
        SYSTEM.GET(dev.RDR, dummy);
        DEC(nr)
      END
    END
  END PutBytes;


  PROCEDURE GetBytes*(dev: SPId.Device; VAR rxData: ARRAY OF BYTE; n: INTEGER);
    VAR ir, nw, nr: INTEGER;
  BEGIN
    ASSERT(n <= LEN(rxData));
    ir := 0;
    nw := n; nr := n;
    WHILE (nw > 0) OR (nr > 0) DO
      WHILE (nw > 0) & (nr < nw + FifoDepth) & SYSTEM.BIT(dev.SR, SPId.SR_TNF) DO
        SYSTEM.PUT(dev.TDR, dev.txShift);
        DEC(nw)
      END;
      IF (nr > 0) & SYSTEM.BIT(dev.SR, SPId.SR_RNE) THEN
        SYSTEM.GET(dev.RDR, rxData[ir]);
        INC(ir); DEC(nr)
      END
    END
  END GetBytes;


  PROCEDURE PutGetBytes*(dev: SPId.Device; txData: ARRAY OF BYTE; VAR rxData: ARRAY OF BYTE; n: INTEGER);
    VAR iw, ir, nw, nr: INTEGER;
  BEGIN
    ASSERT(n <= LEN(txData));
    ASSERT(n <= LEN(rxData));
    iw := 0; ir := 0;
    nw := n; nr := n;
    WHILE (nw > 0) OR (nr > 0) DO
      WHILE (nw > 0) & (nr < nw + FifoDepth) & SYSTEM.BIT(dev.SR, SPId.SR_TNF) DO
        SYSTEM.PUT(dev.TDR, txData[iw]);
        INC(iw); DEC(nw)
      END;
      IF (nr > 0) & SYSTEM.BIT(dev.SR, SPId.SR_RNE) THEN
        SYSTEM.GET(dev.RDR, rxData[ir]);
        INC(ir); DEC(nr)
      END
    END
  END PutGetBytes;

END SPIdata.

(*
  PROCEDURE PutBytes*(dev: SPId.Device; txData: ARRAY OF BYTE; n: INTEGER);
    VAR iw, ir, dummy: INTEGER;
  BEGIN
    ASSERT(n <= LEN(txData));
    iw := 0; ir := 0;
    WHILE (iw < n) OR (ir < n) DO
      WHILE (iw < n) & (ir > iw - FifoDepth) & SYSTEM.BIT(dev.SR, SPId.SR_TNF) DO
        SYSTEM.PUT(dev.TDR, txData[iw]);
        INC(iw);
      END;
      IF (ir < n) & SYSTEM.BIT(dev.SR, SPId.SR_RNE) THEN
        SYSTEM.GET(dev.RDR, dummy);
        INC(ir);
      END
    END
  END PutBytes;

  PROCEDURE GetBytes*(dev: SPId.Device; VAR rxData: ARRAY OF BYTE; n: INTEGER);
    VAR iw, ir: INTEGER;
  BEGIN
    ASSERT(n <= LEN(rxData));
    iw := 0; ir := 0;
    WHILE (iw < n) OR (ir < n) DO
      WHILE (iw < n) & (ir > iw - FifoDepth) & SYSTEM.BIT(dev.SR, SPId.SR_TNF) DO
        SYSTEM.PUT(dev.TDR, dev.txShift);
        INC(iw);
      END;
      IF (ir < n) & SYSTEM.BIT(dev.SR, SPId.SR_RNE) THEN
        SYSTEM.GET(dev.RDR, rxData[ir]);
        INC(ir);
      END
    END
  END GetBytes;
*)
