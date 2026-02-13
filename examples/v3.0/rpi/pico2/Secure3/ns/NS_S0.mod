MODULE NS_S0;
(* generated, do not edit *)
(* Secure module: S0 *)
(* NSC veneer address: 010800000H *)
IMPORT SYSTEM;


PROCEDURE* ToggleLED*(led: INTEGER);
BEGIN
SYSTEM.EMITH(0B001H); (* add sp,#4, fix stack *)
SYSTEM.EMIT(0F8DFB004H); (* ldr.w r11,[pc,#4] *)
SYSTEM.EMITH(04758H); (* bx r11 *)
SYSTEM.ALIGN; (* word alignment *)
SYSTEM.DATA(010800001H); (* nsc target address *)
END ToggleLED;

END NS_S0.
