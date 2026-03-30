-- Halt test — verify halt-on-failure stops the test
-- Based on phase6-test with one wrong expected value + halt keyword.
-- The 3rd check should FAIL and halt; checks 4-5 should NOT execute.
--
option timeout = 15
option max-hits = 50

stop after 2 hits

proc UART.Configure
  at entry
    trace arg dev
    check mem [arg dev + 0x00] = 0           -- PASS: uartId = 0
    check mem [arg dev + 0x18] = 0x50013800  -- PASS: CR1 address
    check mem [arg dev + 0x1C] = 0x50013803  halt  -- FAIL: wrong (real = 0x50013804)
    check mem [arg dev + 0x24] = 0x5001380C  -- should NOT execute
    check mem [arg dev + 0x34] = 0x5001381C  -- should NOT execute
