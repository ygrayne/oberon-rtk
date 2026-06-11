-- Phase 7 CONST resolution test
-- Exercises const_ref in multiple positions:
--   1. As expected value:    check arg pllId = CLK.PLL1
--   2. As mem address:       check mem MCU.FLASH_ACR [3:0] = 0
--   3. As indirect offset:   check mem [arg dev + UARTdef.USART1]
--   4. As expected value:    check arg dev.uartId = UARTdef.USART1
--
-- Execution order:
--   Main.init -> Clocks.Configure -> CLK.ConfigPLL(PLL1, pllCfg)
--   Main.init -> UART.Configure(dev, cfg, baudrate)
--
-- Register address constants are in the MCU module.

option timeout = 15
option max-hits = 20

start proc CLK.ConfigPLL at entry
stop after 6 hits

-- --- const_ref as expected value ---
-- CLK.ConfigPLL is called with pllId=0 (PLL1) and cfg.src=2 (PLLsrc_HSI16)
proc CLK.ConfigPLL
  at entry
    check arg pllId = CLK.PLL1
    check arg pllId = CLK.PLLsrc_None
    check arg cfg.src = CLK.PLLsrc_HSI16
    check arg cfg.range = CLK.PLLsrc_Frq_8_16

-- --- const_ref as mem address ---
-- MCU.FLASH_ACR is FLASH_BASE + 000H.
-- At PLL config entry, flash latency is still default (0).
-- MCU.RCC_CFGR1 is RCC_BASE + 01CH, bits [1:0] = SWS.
proc CLK.ConfigPLL
  at entry
    check mem MCU.FLASH_ACR [3:0] = 0
    trace mem MCU.RCC_CFGR1

-- --- const_ref as indirect offset ---
-- UART.Configure(dev, cfg, baudrate):
--   dev points to a Device record. dev+0 = uartId (=0 for USART1)
-- UARTdef.USART1 = 0, so [dev + USART1] reads dev+0 = uartId
proc UART.Configure
  at entry
    check mem [arg dev + UARTdef.USART1] = UARTdef.USART1
    trace mem [arg dev + UARTdef.USART2]

-- --- const_ref: UART module consts as expected values ---
proc UART.Configure
  at entry
    check arg dev.uartId = UARTdef.USART1

-- --- const_ref with large hex values ---
-- FLASH.KEY_val0 = 045670123H, FLASH.KEY_val1 = 0CDEF89ABH
-- Not memory addresses; used to verify hex const resolution.
proc CLK.ConfigPLL
  at entry
    check arg cfg.ndiv # FLASH.KEY_val0
    check arg pllId # FLASH.KEY_val1
