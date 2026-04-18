-- Global variable access test
--
-- Test 1: Module-internal global (Kernel.coreCon accessed via Kernel.Done)
--   Kernel.Done and Kernel.Yield are exported procedure-type globals,
--   set in the module init block to SuspendMe and Next respectively.
--   By the time Kernel.SetPeriod runs, they are initialised.
--
-- Test 2: Cross-module global (Out.W accessed from Out.Open)
--   Out.W is an exported TextIO.Writer, set by Out.Open.

option timeout = 15
option max-hits = 50

stop after 3 hits

-- Same-module global: read Kernel.Done and Kernel.Yield at SetPeriod entry
proc Kernel.SetPeriod
  at entry
    trace Kernel.Done                        -- should be SuspendMe address
    trace Kernel.Yield                       -- should be Next address

-- Cross-module global: read Out.W from Out.Open
-- Out.Open sets W := W0
proc Out.Open
  at entry
    trace W0                                 -- the writer passed in
    trace Out.W                              -- the exported writer
