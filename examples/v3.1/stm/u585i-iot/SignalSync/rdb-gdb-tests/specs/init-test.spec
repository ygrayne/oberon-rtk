-- SignalSync init-phase test spec
-- Tests known argument values at procedure entry points.

option timeout = 15
option max-hits = 20

-- Stop after seeing all init calls
stop after 10 hits

-- LED.Set is called with {LED.Pico} = 128 = 0x80
proc LED.Set
  at entry
    check arg leds = 128

-- Kernel.SetPeriod is called twice during init:
--   t0c: SetPeriod(50, 0)    -- T0period=50, startAfter=0
--   t3c: SetPeriod(100, 100) -- T3period=100, startAfter=100
-- We trace both args to see the values.
proc Kernel.SetPeriod
  at entry
    trace arg period
    trace arg startAfter

-- Cores.CoreId is a leaf proc with no args.
-- It returns r0 = core ID. We just trace it to confirm we can break there.
proc Cores.CoreId
  at entry
    trace local cid
