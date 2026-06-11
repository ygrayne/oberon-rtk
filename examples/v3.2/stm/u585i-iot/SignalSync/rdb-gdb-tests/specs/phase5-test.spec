-- Phase 5 test: static memory reads
-- After clock init, check RCC register values.
--
-- RCC_CR = 046020C00H (clock control register)
--   bit 24 = PLL1ON, bit 25 = PLL1RDY
--   bits [25:24] should be 3 (both set) after PLL1 init
--
-- RCC_CFGR1 = 046020C1CH (clock config register 1)
--   bits [3:2] = SWS (system clock switch status)
--   value 3 = PLL selected as system clock

option timeout = 15
option max-hits = 10

stop after 5 hits

-- Break at Kernel.SetPeriod entry — this fires after all clock init.
-- Read RCC registers to verify clock configuration.
proc Kernel.SetPeriod
  at entry
    trace arg period
    trace mem 046020C00H
    check mem 046020C00H [25:24] = 3
    trace mem 046020C1CH
    check mem 046020C1CH [3:2] = 3
