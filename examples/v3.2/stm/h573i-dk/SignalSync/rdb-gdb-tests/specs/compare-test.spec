-- Comparison operators test
-- Exercises all six operators: = # > < >= <=
-- Also tests NIL constant and signedness overrides.
--
-- UART.Configure(dev, cfg, baudrate):
--   dev points to UART.Device record, dev.uartId = 0 (USART1)
--   dev + 18H: CR1 address = 050013800H
--   dev + 00H: uartId = 0

option timeout = 15
option max-hits = 50

stop after 2 hits

proc UART.Configure
  at entry
    -- Equality (existing, regression)
    check mem [arg dev + 00H] = 0              -- uartId = 0
    check mem [arg dev + 18H] = 050013800H     -- CR1 address

    -- Not-equal (#)
    check mem [arg dev + 18H] # 0              -- CR1 address is not zero
    check arg dev # NIL                        -- dev pointer is not nil

    -- Greater than (>)
    check mem [arg dev + 18H] > 050000000H     -- CR1 > secure peripheral base

    -- Less than (<)
    check mem [arg dev + 00H] < 10             -- uartId < 10

    -- Greater or equal (>=)
    check mem [arg dev + 18H] >= 050013800H    -- CR1 >= exact value
    check mem [arg dev + 00H] >= 0             -- uartId >= 0

    -- Less or equal (<=)
    check mem [arg dev + 18H] <= 050013800H    -- CR1 <= exact value
    check mem [arg dev + 00H] <= 0 as unsigned -- uartId <= 0 unsigned

    -- NIL checks
    check arg dev # NIL                        -- pointer is not nil
