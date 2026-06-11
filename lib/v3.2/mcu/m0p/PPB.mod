MODULE PPB;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  ARMv6-M (Cortex-M0+) architectural constants.
  --
  PPB register addresses, exception numbers and vector table offsets,
  All constants are defined by the ARM architecture and identical across
  all Cortex-M0+ implementations.
  --
  Copyright (c) 2023-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  CONST
    PPB_BASE* = 0E0000000H;

    (* -- SysTick -- *)
    SYST_CSR*     = PPB_BASE + 0E010H;
    SYST_RVR*     = PPB_BASE + 0E014H;
    SYST_CVR*     = PPB_BASE + 0E018H;
    SYST_CALIB*   = PPB_BASE + 0E01CH;

    (* -- NVIC -- *)
    NVIC_ISER0*   = PPB_BASE + 0E100H;
    NVIC_ICER0*   = PPB_BASE + 0E180H;
    NVIC_ISPR0*   = PPB_BASE + 0E200H;
    NVIC_ICPR0*   = PPB_BASE + 0E280H;
    NVIC_IPR0*    = PPB_BASE + 0E400H;

    (* -- exception numbers -- *)
    EXC_NMI*           = 2;
    EXC_HardFault*     = 3;
    EXC_SVC*           = 11;
    EXC_PendSV*        = 14;
    EXC_SysTick*       = 15;

    SysExc*  = {3, 11, 14, 15};

    IRQ_BASE* = 16; (* exc no = IRQ_BASE + IRQ number *)

    (* -- vector table -- *)
    EXC_Reset_Offset*         = 004H;
    EXC_NMI_Offset*           = 008H;
    EXC_HardFault_Offset*     = 00CH;
    EXC_SVC_Offset*           = 02CH;
    EXC_PendSV_Offset*        = 038H;
    EXC_SysTick_Offset*       = 03CH;
    EXC_IRQ0_Offset*          = 040H;


    (* -- SCB system control block -- *)
    CPUID*        = PPB_BASE + 0ED00H;
    ICSR*         = PPB_BASE + 0ED04H;
    VTOR*         = PPB_BASE + 0ED08H;
    AIRCR*        = PPB_BASE + 0ED0CH;
    SCR*          = PPB_BASE + 0ED10H;
    CCR*          = PPB_BASE + 0ED14H;

    (* defining non-implemented 'SHPR1' allows to calculate other 'SHPRx' *)
    (* uniformly across M-architectures using the exception number *)
    SHPR1*        = PPB_BASE + 0ED18H;  (* not implemented in M0+ *)
    SHPR2*        = PPB_BASE + 0ED1CH;
    SHPR3*        = PPB_BASE + 0ED20H;

    SHCSR*        = PPB_BASE + 0ED24H;


    (* -- MPU memory protection unit -- *)
    MPU_TYPE*     = PPB_BASE + 0ED90H;
    MPU_CTRL*     = PPB_BASE + 0ED94H;
    MPU_RNR*      = PPB_BASE + 0ED98H;
    MPU_RBAR*     = PPB_BASE + 0ED9CH;
    MPU_RASR*     = PPB_BASE + 0EDA0H;


    (* -- CPU registers -- *)
    (* CONTROL special register *)
    CONTROL_SPSEL* = 1; (* enable PSP *)

END PPB.
