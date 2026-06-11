-- Phase 8 sentinel test
-- Exercises start/stop sentinels and the test window.
--
-- Init sequence (from prior test runs):
--   hit 1: LED.Set(leds=128)             -- LED init
--   hit 2: Kernel.SetPeriod(period=50)   -- first timer
--   hit 3: Kernel.SetPeriod(period=100)  -- second timer
--   (with only LED.Set + Kernel.SetPeriod breakpoints set)
--
-- Test 1 — basic start sentinel + window gating:
--   start at Kernel.SetPeriod entry → window opens at hit 2
--   LED.Set trace at entry → should be SKIPPED (window closed at hit 1)
--   Kernel.SetPeriod trace → should fire (window open)
--
-- Test 2 — stop after all checks:
--   Only check is at Kernel.SetPeriod, so stop fires after first check hit.
--
-- Expected: 0 results from LED.Set, 1 PASS + 1 TRACE from Kernel.SetPeriod,
--   stop reason = "all checks evaluated".

option timeout = 15
option max-hits = 30

start proc Kernel.SetPeriod at entry
stop after all checks

-- --- Window-gated trace (should be skipped) ---
-- LED.Set is called before Kernel.SetPeriod → window still closed.
-- This trace should produce zero results.
proc LED.Set
  at entry
    trace arg leds

-- --- Checks that fire after window opens ---
-- First Kernel.SetPeriod call has period=50.
-- stop after all checks fires after this single check evaluates.
proc Kernel.SetPeriod
  at entry
    check arg period = 50
    trace arg startAfter
