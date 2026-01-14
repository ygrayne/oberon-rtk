MODULE NSC_S0;
(* generated, do not edit *)
IMPORT SYSTEM, Main;

PROCEDURE* ToggleLED*(VAR leds: SET);
BEGIN
(* SYSTEM.EMIT(0E97FE97FH); *) (* SG *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
(*!addr_s 12 *) SYSTEM.DATA(008000C5DH); (* target address *)
END ToggleLED;

PROCEDURE SetBits2*(pin, addr, twoBitValue: INTEGER);
BEGIN
(* SYSTEM.EMIT(0E97FE97FH); *) (* SG *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
(*!addr_s 44 *) SYSTEM.DATA(008000C7DH); (* target address *)
END SetBits2;

PROCEDURE Test*(x, v: INTEGER);
BEGIN
(* SYSTEM.EMIT(0E97FE97FH); *) (* SG *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
(*!addr_s 136 *) SYSTEM.DATA(008000CD9H); (* target address *)
END Test;

END NSC_S0.
