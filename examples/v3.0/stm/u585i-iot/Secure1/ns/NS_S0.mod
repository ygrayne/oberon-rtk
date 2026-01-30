MODULE NS_S0;
(* generated, do not edit *)
IMPORT SYSTEM;

PROCEDURE* ToggleLED*(VAR led: SET);
BEGIN
SYSTEM.EMITH(0B001H); (* add sp,#4, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
SYSTEM.DATA(00C0FE001H); (* nsc target address *)
END ToggleLED;

PROCEDURE SetBits2*(pin, addr, twoBitValue: INTEGER);
BEGIN
SYSTEM.EMITH(0B004H); (* add sp,#16, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
SYSTEM.DATA(00C0FE011H); (* nsc target address *)
END SetBits2;

PROCEDURE Test*(x, v: INTEGER);
BEGIN
SYSTEM.EMITH(0B003H); (* add sp,#12, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
SYSTEM.DATA(00C0FE021H); (* nsc target address *)
END Test;

END NS_S0.
