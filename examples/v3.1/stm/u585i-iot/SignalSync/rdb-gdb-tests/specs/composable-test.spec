-- Composable access pattern test
-- Tests c003 syntax: record.field on args, global record.field
--
-- Execution order: Config.init (module body) sets globals
--   Main.init -> Clocks.Configure -> CLK.ConfigPLL(PLL1, pllCfg)
--   Main.init -> LED.Init -> GPIO.ConfigurePin(PORTH, pin, padCfg)  [x2]
--   Main.init -> Main.cfgPins -> GPIO.ConfigurePin(PORTA, pin, padCfg)  [x2]

option timeout = 15
option max-hits = 20

start proc CLK.ConfigPLL at entry
stop after 6 hits

-- --- CLK.ConfigPLL: 10-field record arg with known values ---
-- Called from Clocks.Configure with PLL1 config:
--   src=2, range=1, pen=0, qen=0, ren=1, mdiv=0, pdiv=0, qdiv=0, rdiv=0, ndiv=9
proc CLK.ConfigPLL
  at entry
    check arg cfg.src = 2
    check arg cfg.range = 1
    check arg cfg.ren = 1
    check arg cfg.pen = 0
    check arg cfg.qen = 0
    check arg cfg.ndiv = 9
    check arg cfg.mdiv = 0
    check arg cfg.pdiv = 0
    check arg cfg.qdiv = 0
    check arg cfg.rdiv = 0
    check arg pllId = 0

-- --- GPIO.ConfigurePin: 4-field record arg, two callers ---
-- Hit 1-2 (LED.Init): mode=1 (ModeOut), type=0 (PushPull), speed=0 (Low), pulls=0 (None)
-- Hit 3-4 (Main.cfgPins): mode=2 (ModeAlt), type=0, speed=2 (High), pulls=1 (PullUp)
proc GPIO.ConfigurePin
  at entry
    trace arg cfg.mode
    trace arg cfg.type
    trace arg cfg.speed
    trace arg cfg.pulls

-- --- Global record.field access ---
-- MemCfg.DataMem and MemCfg.HeapMem are arrays set during MemCfg.init.
proc CLK.ConfigPLL
  at entry
    trace MemCfg.DataMem
    trace MemCfg.HeapMem
