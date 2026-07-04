MODULE ASM;
(**
  Oberon RTK Framework
  Version: v3.2
  --
  ARM instruction encodings for SYSTEM.EMIT/EMITH for ARMv6-M (Cortex-M0+).
  Can/will be replaced by (* asm .. end asm *) in-line assembly code.
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    NOP* = 046C0H;

    (* read special regs MRS *)
    (* 0F3EF8 B 09H r11(B) PSP(09) *)
    MRS_R11_IPSR* = 0F3EF8B05H;  (* move IPSR to r11 *)
    MRS_R03_IPSR* = 0F3EF8305H;  (* move IPSR to r3 *)
    MRS_R00_IPSR* = 0F3EF8005H;  (* move IPSR to r0 *)

    MRS_R11_XPSR* = 0F3EF8B03H;  (* move XPSR to r11 *)
    MRS_R03_XPSR* = 0F3EF8303H;  (* move XPSR to r3 *)

    MRS_R11_MSP*  = 0F3EF8B08H;  (* move MSP to r11 *)
    MRS_R03_MSP*  = 0F3EF8308H;  (* move MSP to r3 *)
    MRS_R00_MSP*  = 0F3EF8008H;  (* move MSP to r0 *)

    MRS_R11_PSP*  = 0F3EF8B09H;  (* move PSP to r11 *)
    MRS_R03_PSP*  = 0F3EF8309H;  (* move PSP to r3 *)
    MRS_R00_PSP*  = 0F3EF8009H;  (* move PSP to r0 *)

    MRS_R11_CTL*  = 0F3EF8B14H;  (* move CONTROL to r11 *)
    MRS_R03_CTL*  = 0F3EF8314H;  (* move CONTROL to r3 *)

    (* write special regs MSR *)
    (* 0F38 B 88 09H: r11(B), PSP(09), MSP(08)*)
    MSR_PSP_R11* = 0F38B8809H;  (* move r11 to PSP *)
    MSR_MSP_R11* = 0F38B8808H;  (* move r11 to MSP *)
    MSR_CTL_R11* = 0F38B8814H;  (* move r11 to CONTROL *)

    (* instruction & data sync *)
    ISB* = 0F3BF8F6FH;
    DSB* = 0F3BF8F4FH;
    DMB* = 0F3BF8F5FH;

    (* interrupt enable/disable via PRIMASK *)
    CPSIE_I* = 0B662H; (* enable:  1011 0110 0110 0010 *)
    CPSID_I* = 0B672H; (* disable: 1011 0110 0111 0010 *)

    (* wait for event/interrupt *)
    WFE* = 0BF20H;
    WFI* = 0BF30H;

    (* SVC *)
    (* SVCinstr = 'SVC' + SVCvalue *)
    SVC* = 0DF00H;


END ASM.
