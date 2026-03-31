MODULE ASM;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  ARM instruction encodings for SYSTEM.EMIT/EMITH for ARMv8-M Mainline (Cortex-M33).
  Can/will be replaced by (* ASM .. END ASM *) in-line assembly code.
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  CONST
    NOP* = 046C0H;

    (* branch *)
    BX_LR*     = 04770H;   (* bx lr *)
    BXNS_LR*   = 04774H;   (* bxns lr — TrustZone NS return *)
    BLXNS_R11* = 047DCH;   (* blxns r11 — TrustZone NS call *)
    BLXNS_R12* = 047E4H;   (* blxns r12 *)

    (* stack *)
    POP_LR*  = 0E8BD4000H; (* pop.w {lr} — Thumb2 32-bit *)
    ADD_SP*  = 0B000H;     (* add sp,#N — N/4 added to lower bits *)

    (* read special regs MRS *)
    (* encoding: 0F3EF8 Rn SYSm *)
    (* [11:8] = register Rn, [7:0] = special reg SYSm *)
    MRS_R00_IPSR* = 0F3EF8005H;  (* move IPSR to r0 *)
    MRS_R03_IPSR* = 0F3EF8305H;  (* move IPSR to r3 *)
    MRS_R11_IPSR* = 0F3EF8B05H;  (* move IPSR to r11 *)

    MRS_R03_XPSR* = 0F3EF8303H;  (* move XPSR to r3 *)
    MRS_R11_XPSR* = 0F3EF8B03H;  (* move XPSR to r11 *)

    MRS_R00_MSP*  = 0F3EF8008H;  (* move MSP to r0 *)
    MRS_R03_MSP*  = 0F3EF8308H;  (* move MSP to r3 *)
    MRS_R11_MSP*  = 0F3EF8B08H;  (* move MSP to r11 *)

    MRS_R00_PSP*  = 0F3EF8009H;  (* move PSP to r0 *)
    MRS_R03_PSP*  = 0F3EF8309H;  (* move PSP to r3 *)
    MRS_R11_PSP*  = 0F3EF8B09H;  (* move PSP to r11 *)

    MRS_R03_CTL*  = 0F3EF8314H;  (* move CONTROL to r3 *)
    MRS_R11_CTL*  = 0F3EF8B14H;  (* move CONTROL to r11 *)

    MRS_R03_BASEPRI* = 0F3EF8311H; (* move BASEPRI to r3 *)
    MRS_R07_BASEPRI* = 0F3EF8711H; (* move BASEPRI to r7 *)
    MRS_R11_BASEPRI* = 0F3EF8B11H; (* move BASEPRI to r11 *)

    (* write special regs MSR *)
    (* encoding: 0F38 Rn 88 SYSm *)
    (* [19:16] = register Rn, [7:0] = special register SYSm *)
    MSR_PSP_R11* = 0F38B8809H;   (* move r11 to PSP *)
    MSR_MSP_R11* = 0F38B8808H;   (* move r11 to MSP *)
    MSR_CTL_R11* = 0F38B8814H;   (* move r11 to CONTROL *)

    MSR_MSPns_R11* = 0F38B8888H; (* move r11 to MSP_NS — TrustZone *)

    MSR_BASEPRI_R02* = 0F3828811H; (* move r2 to BASEPRI *)
    MSR_BASEPRI_R03* = 0F3838811H; (* move r3 to BASEPRI *)
    MSR_BASEPRI_R06* = 0F3868811H; (* move r6 to BASEPRI *)
    MSR_BASEPRI_R07* = 0F3878811H; (* move r7 to BASEPRI *)
    MSR_BASEPRI_R11* = 0F38B8811H; (* move r11 to BASEPRI *)

    (* instruction and data synchronisation barriers *)
    ISB* = 0F3BF8F6FH;
    DSB* = 0F3BF8F4FH;
    DMB* = 0F3BF8F5FH;

    (* interrupt enable/disable via PRIMASK *)
    CPSIE_I* = 0B662H; (* enable:  1011 0110 0110 0010 *)
    CPSID_I* = 0B672H; (* disable: 1011 0110 0111 0010 *)
    (* interrupt enable/disable via FAULTMASK *)
    (* raises execution priority to -1 = HardFault, clears on handler exit *)
    CPSIE_F* = 0B662H; (* enable:  1011 0110 0110 0001 *)
    CPSID_F* = 0B672H; (* disable: 1011 0110 0111 0001 *)

    (* wait for event/interrupt *)
    WFE* = 0BF20H;
    WFI* = 0BF30H;

    (* SVC *)
    (* SVCinstr = SVC + SVCvalue *)
    SVC* = 0DF00H;

END ASM.
