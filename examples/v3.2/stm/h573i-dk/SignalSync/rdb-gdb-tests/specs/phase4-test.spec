-- Phase 4 test: at exit, at line, return value tracing
-- Tests exit breakpoints, line breakpoints, and the return target.
-- Line numbers refer to .alst file lines.

option timeout = 15
option max-hits = 30

stop after 20 hits

-- Cores.CoreId: leaf function, returns core ID in r0.
-- at exit = pop {pc} at 0C001826; r0 holds the return value.
proc Cores.CoreId
  at exit
    trace return

-- LED.Set: check arg at entry
proc LED.Set
  at entry
    check arg leds = 128

-- Kernel.SetPeriod: trace args at entry
proc Kernel.SetPeriod
  at entry
    trace arg period
    trace arg startAfter

-- writeThreadInfo: at line 54 of SignalSync.alst = "Out.String("-t")..."
-- Args tid and cid are on the stack and accessible.
proc SignalSync.writeThreadInfo
  at line 54
    trace arg tid
    trace arg cid
