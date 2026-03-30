-- Phase 6 test — indirect memory reads
-- Verify UART device struct fields via pointer indirection
--
-- UART.Configure(dev, cfg, baudrate) is a normal procedure.
-- At entry, 'dev' points to a UART.Device record initialised by UART.Init.
-- The Device record stores computed USART register addresses:
--   dev + 00H: uartId         (0 = USART1)
--   dev + 18H: CR1 address    (USART1_BASE + 000H = 050013800H)
--   dev + 1CH: CR2 address    (USART1_BASE + 004H = 050013804H)
--   dev + 24H: BRR address    (USART1_BASE + 00CH = 05001380CH)
--   dev + 34H: ISR address    (USART1_BASE + 01CH = 05001381CH)

option timeout = 15
option max-hits = 50

stop after 2 hits

proc UART.Configure
  at entry
    -- Verify stored register addresses in the device struct
    trace arg dev
    check mem [arg dev + 00H] = 0              -- uartId = USART1 = 0
    check mem [arg dev + 18H] = 050013800H     -- CR1 address
    check mem [arg dev + 1CH] = 050013804H     -- CR2 address
    check mem [arg dev + 24H] = 05001380CH     -- BRR address
    check mem [arg dev + 34H] = 05001381CH     -- ISR address


proc UART.Configure
  at entry
    -- Verify stored register addresses via dotted field access
    trace arg dev
    check arg dev.uartId = 0                   -- uartId = USART1 = 0
    check arg dev.CR1    = 050013800H          -- CR1 address
    check arg dev.CR2    = 050013804H          -- CR2 address
    check arg dev.BRR    = 05001380CH          -- BRR address
    check arg dev.ISR    = 05001381CH          -- ISR address
    -- Read actual hardware register via indirection
    trace mem [arg dev.CR1]                    -- USART1 CR1 contents

proc UART.Configure
  at entry
    -- Same checks without arg/local/mem keywords
    trace dev
    check dev.uartId = 0
    check dev.CR1    = 050013800H
    check dev.BRR    = 05001380CH
    check [dev + 18H] = 050013800H             -- bare indirect
    trace [dev.CR1]                            -- bare indirect with field
