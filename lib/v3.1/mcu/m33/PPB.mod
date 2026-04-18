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
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST

    (* == PPB base addresses == *)
    PPB_BASE*       = 0E0000000H;
    PPB_NS_BASE*    = 0E0020000H;
    PPB_NS_Offset*  = PPB_NS_BASE - PPB_BASE;


    (* == ITM: instrumentation trace macrocell *)
    ITM_STIM0*    = PPB_BASE;
      (* STIM0 .. STIM 31 *)
      (* block offset *)
      ITM_STIM_Offset* = 4;

    ITM_TER0*     = PPB_BASE + 00E00H;
    ITM_TPR*      = PPB_BASE + 00E40H;
    ITM_TCR*      = PPB_BASE + 00E80H;
    INT_ATREADY*  = PPB_BASE + 00EF0H;
    INT_ATVALID*  = PPB_BASE + 00EF8H;
    ITCTRL*       = PPB_BASE + 00F00H;
    ITM_DEVARCH*  = PPB_BASE + 00FBCH;
    ITM_DEVTYPE*  = PPB_BASE + 00FCCH;
    (* .. *)

    (* == DWT: data watchpoint and trace == *)
    DWT_CTRL*      = PPB_BASE + 01000H;
    DWT_CYCCNT*    = PPB_BASE + 01004H;
    DWT_EXCCNT*    = PPB_BASE + 0100CH;
    DWT_LSUCNT*    = PPB_BASE + 01014H;
    DWT_FOLDCNT*   = PPB_BASE + 01018H;
    DWT_COMP0*     = PPB_BASE + 01020H;
    DWT_FUNCTION0* = PPB_BASE + 01028H;
    DWT_COMP1*     = PPB_BASE + 01030H;
    DWT_FUNCTION1* = PPB_BASE + 01038H;
    DWT_COMP2*     = PPB_BASE + 01040H;
    DWT_FUNCTION2* = PPB_BASE + 01048H;
    DWT_COMP3*     = PPB_BASE + 01050H;
    DWT_FUNCTION3* = PPB_BASE + 01058H;
    (* .. *)

    (* == FPB: flash patch and breakpoint == *)
    FP_CTRL*      = PPB_BASE + 02000H;
    (* .. *)

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


END PPB.
