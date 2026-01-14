MODULE NS_S0;
(* generated, do not edit *)
IMPORT SYSTEM;

PROCEDURE* ToggleLED*(VAR leds: SET);
BEGIN
SYSTEM.EMITH(0B001H); (* add sp,#4, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
(*!addr_nsc 6 *) SYSTEM.DATA(00800084FH); (* target address *)
END ToggleLED;

PROCEDURE SetBits2*(pin, addr, twoBitValue: INTEGER);
BEGIN
SYSTEM.EMITH(0B004H); (* add sp,#16, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
(*!addr_nsc 22 *) SYSTEM.DATA(00800085FH); (* target address *)
END SetBits2;

PROCEDURE Test*(x, v: INTEGER);
BEGIN
SYSTEM.EMITH(0B003H); (* add sp,#12, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
(*!addr_nsc 38 *) SYSTEM.DATA(00800086FH); (* target address *)
END Test;

END NS_S0.
