MODULE PPB;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  ARMv8-M Mainline (Cortex-M33) architectural constants.
  --
  PPB register addresses, exception numbers and vector table offsets,
  All constants are defined by the ARM architecture and identical across
  all Cortex-M33 implementations.
  --
  Copyright (c) 2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)
  CONST

    (* == PPB base addresses == *)
    PPB_BASE*         = 0E0000000H;
    PPB_NS_BASE*      = 0E0020000H;
    PPB_NS_Offset*    = PPB_NS_BASE - PPB_BASE;


    (* == implementation control block == *)
    ICTR*         = PPB_BASE + 0E004H;
    ACTLR*        = PPB_BASE + 0E008H;


    (* == SysTick == *)
    SYST_CSR*     = PPB_BASE + 0E010H;
    SYST_RVR*     = PPB_BASE + 0E014H;
    SYST_CVR*     = PPB_BASE + 0E018H;
    SYST_CALIB*   = PPB_BASE + 0E01CH;


    (* == NVIC == *)
    NVIC_ISER0*   = PPB_BASE + 0E100H;
    NVIC_ICER0*   = PPB_BASE + 0E180H;
    NVIC_ISPR0*   = PPB_BASE + 0E200H;
    NVIC_ICPR0*   = PPB_BASE + 0E280H;
    NVIC_IABR0*   = PPB_BASE + 0E300H;
    NVIC_ITNS0*   = PPB_BASE + 0E380H;
    NVIC_IPR0*    = PPB_BASE + 0E400H;


    (* == exception numbers == *)
    EXC_NMI*          = 2;
    EXC_HardFault*    = 3;
    EXC_MemMgmtFault* = 4;
    EXC_BusFault*     = 5;
    EXC_UsageFault*   = 6;
    EXC_SecureFault*  = 7;
    EXC_SVC*          = 11;
    EXC_DebugMon*     = 12;
    EXC_PendSV*       = 14;
    EXC_SysTick*      = 15;

    SysExc*  = {3, 4, 5, 6, 7, 11, 14, 15};

    IRQ_BASE*         = 16; (* exc no = IRQ_BASE + IRQ number *)


    (* == vector table offsets == *)
    EXC_Reset_Offset*         = 004H;
    EXC_NMI_Offset*           = 008H;
    EXC_HardFault_Offset*     = 00CH;
    EXC_MemMgmtFault_Offset*  = 010H;
    EXC_BusFault_Offset*      = 014H;
    EXC_UsageFault_Offset*    = 018H;
    EXC_SecureFault_Offset*   = 01CH;
    EXC_SVC_Offset*           = 02CH;
    EXC_DebugMon_Offset*      = 030H;
    EXC_PendSV_Offset*        = 038H;
    EXC_SysTick_Offset*       = 03CH;
    EXC_IRQ0_Offset*          = 040H;


    (* == SCB system control block == *)
    CPUID*        = PPB_BASE + 0ED00H;
    ICSR*         = PPB_BASE + 0ED04H;
    VTOR*         = PPB_BASE + 0ED08H;
    AIRCR*        = PPB_BASE + 0ED0CH;
    SCR*          = PPB_BASE + 0ED10H;
    CCR*          = PPB_BASE + 0ED14H;

    SHPR1*        = PPB_BASE + 0ED18H;
    SHPR2*        = PPB_BASE + 0ED1CH;
    SHPR3*        = PPB_BASE + 0ED20H;

    SHCSR*        = PPB_BASE + 0ED24H;

    CFSR*         = PPB_BASE + 0ED28H; (* UFSR [31:16], BFSR [15:8], MMFSR [7:0] *)
    HFSR*         = PPB_BASE + 0ED2CH;
    DFSR*         = PPB_BASE + 0ED30H;
    MMFAR*        = PPB_BASE + 0ED34H;
    BFAR*         = PPB_BASE + 0ED38H;
    AFSR*         = PPB_BASE + 0ED3CH;

    CPACR*        = PPB_BASE + 0ED88H;
    NSACR*        = PPB_BASE + 0ED8CH;

    (* key to access AIRCR [31:16] *)
    AIRCR_VECTKEY*     = 05FAH;  (* to write *)
    AIRCR_VECTKEYSTAT* = 0FA05H; (* on read *)


    (* == MPU memory protection unit == *)
    MPU_TYPE*     = PPB_BASE + 0ED90H;
    MPU_CTRL*     = PPB_BASE + 0ED94H;
    MPU_RNR*      = PPB_BASE + 0ED98H;
    MPU_RBAR*     = PPB_BASE + 0ED9CH;
    MPU_RLAR*     = PPB_BASE + 0EDA0H;
    MPU_RBAR_A1*  = PPB_BASE + 0EDA4H;
    MPU_RLAR_A1*  = PPB_BASE + 0EDA8H;
    MPU_RBAR_A2*  = PPB_BASE + 0EDACH;
    MPU_RLAR_A2*  = PPB_BASE + 0EDB0H;
    MPU_RBAR_A3*  = PPB_BASE + 0EDB4H;
    MPU_RLAR_A3*  = PPB_BASE + 0EDB8H;
    MPU_MAIR0*    = PPB_BASE + 0EDC0H;
    MPU_MAIR1*    = PPB_BASE + 0EDC4H;


    (* == SAU security attribution unit == *)
    SAU_CTRL*     = PPB_BASE + 0EDD0H;
    SAU_TYPE*     = PPB_BASE + 0EDD4H;
    SAU_RNR*      = PPB_BASE + 0EDD8H;
    SAU_RBAR*     = PPB_BASE + 0EDDCH;
    SAU_RLAR*     = PPB_BASE + 0EDE0H;
    SFSR*         = PPB_BASE + 0EDE4H;
    SFAR*         = PPB_BASE + 0EDE8H;


    (* == debug control block == *)
    DHCSR*        = PPB_BASE + 0EDF0H;
    DCRSR*        = PPB_BASE + 0EDF4H;
    DCRDR*        = PPB_BASE + 0EDF8H;
    DEMCR*        = PPB_BASE + 0EDFCH;


    (* == sw interrupt generation == *)
    STIR*         = PPB_BASE + 0EF00H;


    (* == FPU floating point extension == *)
    FPCCR*        = PPB_BASE + 0EF34H;
    FPCAR*        = PPB_BASE + 0EF38H;
    FPDSCR*       = PPB_BASE + 0EF3CH;


    (* == debug identification block == *)
    DDEVARCH*     = PPB_BASE + 0EFBCH;


    (* == CPU registers == *)
    (* CONTROL special register *)
    CONTROL_SPSEL* = 1; (* enable PSP *)

(*
    (* == assembly instructions == *)
    (* can/will be replaced by (* ASM .. END ASM *) in-line assembly code *)

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
*)

END PPB.
