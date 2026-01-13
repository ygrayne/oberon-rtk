MODULE NS_S0;
(* generated, do not edit *)
IMPORT SYSTEM;
(*= NSC *) PROCEDURE* ToggleLED*(VAR leds: SET);
BEGIN
SYSTEM.EMITH(0B001H); (* add sp,#4, fix stack *)
(*= B 6 *) SYSTEM.EMITH(0E000H)
END ToggleLED;
(*= NSC *) PROCEDURE SetBits2*(pin, addr, twoBitValue: INTEGER);
BEGIN
SYSTEM.EMITH(0B004H); (* add sp,#16, fix stack *)
(*= B 14 *) SYSTEM.EMITH(0E000H)
END SetBits2;
(*= NSC *) PROCEDURE Test*(x, v: INTEGER);
BEGIN
SYSTEM.EMITH(0B003H); (* add sp,#12, fix stack *)
(*= B 22 *) SYSTEM.EMITH(0E000H)
END Test;
END NS_S0.
