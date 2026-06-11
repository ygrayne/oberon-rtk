-- Phase 8 sentinel test — scheduler loop
-- Exercises start sentinel + when hits = N on stop sentinel.
--
-- Kernel.Run is called once to start the scheduler.
-- Kernel.loopc is a coroutine with a REPEAT loop.
--   Byte offset 1280: str r0,[sp] (tid := 0 store) — inside the
--   SysTick.Tick() branch, only fires when a real tick occurs.
-- SignalSync.t3c is a thread coroutine with a REPEAT loop.
--   cnt is incremented each iteration; alst line 216 has cnt after INC.
--
-- Test design:
--   start at Kernel.Run entry — window opens when scheduler starts
--   stop at Kernel.loopc listing line 1282 when hits = 150 — 150 real ticks
--   trace local cnt in SignalSync.t3c at line 216 — observe thread counter

option timeout = 30
option max-hits = 500

start proc Kernel.Run at entry
stop proc Kernel.loopc at 1280 when hits = 150

proc SignalSync.t3c
  at line 216
    trace local cnt
