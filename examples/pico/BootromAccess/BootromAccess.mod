MODULE BootromAccess;
(**
  Oberon RTK Framework
  --
  Example program, not multi-threaded, single-core
  --
  MCU: RP2040
  Board: Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
**)

  IMPORT SYSTEM, Main, Out, Bootrom;

  TYPE
    F0 = PROCEDURE(value: INTEGER): INTEGER;

  PROCEDURE run;
    CONST BufSize = 64;
    VAR
      i, revision, reversed, romAddr: INTEGER;
      ch: CHAR;
      reverse: F0;
      cstring: ARRAY BufSize OF CHAR;
  BEGIN
    (* check magic values *)
    IF Bootrom.CheckMagic() THEN
      Out.String("magic!");
      Out.Ln
    END;

    (* get revision number *)
    Bootrom.GetRevision(revision);
    Out.String("revision: "); Out.Int(revision, 0); Out.Ln;

    (* get copyright string *)
    Bootrom.GetDataAddr("C", "R", romAddr);
    i := 0;
    SYSTEM.GET(romAddr, ch);
    WHILE (i < BufSize) & (ch # 0X) DO
      cstring[i] := ch;
      INC(romAddr); INC(i);
      SYSTEM.GET(romAddr, ch)
    END;
    cstring[i] := 0X;
    Out.String(cstring); Out.Ln;

    (* get bit reverse function *)
    Bootrom.GetFuncAddr("R", "3", romAddr);
    reverse := SYSTEM.VAL(F0, romAddr);
    reversed := reverse(0F0F0F0FH);
    Out.Bin(reversed, 0); Out.Ln
  END run;

BEGIN
  run
END BootromAccess.
