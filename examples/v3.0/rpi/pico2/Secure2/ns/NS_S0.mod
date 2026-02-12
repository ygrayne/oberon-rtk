MODULE NS_S0;
(* handcrafted, but will be generated *)

  IMPORT Bootrom;

  CONST
    UserProcKey = 0C0000000H;

  (*
  PROCEDURE ToggleLED*(led, x, y, z: INTEGER): INTEGER;
  BEGIN
    RETURN Bootrom.SecureCall(led, x, y, z, UserProcKey + 42)
  END ToggleLED;
  *)

  PROCEDURE ToggleLED*(led: INTEGER): INTEGER;
    VAR s: SET; b: BOOLEAN; (* for testing *)
  BEGIN
    s := BITS(13); b:= FALSE;
    RETURN Bootrom.SecureCall(led, ORD(b), 42, ORD(s), UserProcKey + 42)
  END ToggleLED;

END NS_S0.
