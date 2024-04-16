MODULE TestWrap;
(**
  Oberon RTK Framework
  Boundary wrap test program, single-threaded, one core
  See https://oberon-rtk.org/examples/taskeval/
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Main, Out;

  CONST
    (*
    RefTime = 02H;
    StartTime = 0FFFFFFFFH - 8;
    StopTime = 0FFFFFFFFH + 8;
    *)
    (*
    RefTime = 080000001H; (* 07FFFFFFFH + 2 *)
    StartTime = 0FFFFFFFFH - 8;
    StopTime = 0FFFFFFFFH + 8;
    *)
    RefTime = 080000001H; (* 07FFFFFFFH + 2 *)
    StartTime = 07FFFFFFFH - 8;
    StopTime = 080000007H;  (* 07FFFFFFFH + 8 *)
    (*
    RefTime = 02H;
    StartTime = 07FFFFFFFH - 8;
    StopTime = 080000007H;  (* 07FFFFFFFH + 8 *)
    *)

  PROCEDURE run;
    VAR t: INTEGER;
  BEGIN
    t := StartTime;
    Out.String("ref "); Out.Hex(RefTime, 0); Out.Ln;
    WHILE StopTime - t >= 0 DO
      IF t - RefTime = 0 THEN
        Out.String("now    ")
      ELSIF t - RefTime > 0 THEN
        Out.String("after  ");
      ELSE
        Out.String("before ")
      END;
      Out.Int(RefTime - t, 12); Out.Hex(t, 10); Out.Ln;
      INC(t)
    END;
    Out.Ln
  END run;

BEGIN
  run
END TestWrap.

