MODULE ICE40UP5K;
(**
  Oberon RTK Framework v2.1
  --
  Lattice Semi iCE40 UltraPlus 5k FPGA
  --
  MCU: RRP2350B
  Board: Pico2-Ice
  --
  Copyright (c) 2025 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT
    MCU := MCU2, ClockOut, GPIO, SPIdev, Timers, Errors;

  CONST
    (* wired/defined by hardware *)
    SPIno* = SPIdev.SPI0;
    SPIsclkFreq* = 12 * 1000000;
    SPItxPinCram* =  35;
    SPItxPinFlash* = 7;
    SPIrxPin* = 4;
    SPIsclkPin* = 6;
    IceCsPin* = 5;
    IceResetPin* = 31;
    IceDonePin* = 40;
    IceClockPin* = 21;
    SPIcpol* = 0;
    SPIcpha* = 0;
    SPItxShift* = 055H;
    IceClockDivInt* = 1; (* full 48 MHz peri clock *)

(*
  VAR
    timer: Timers.Device; (* delay timer *)
*)

  PROCEDURE StartClock*(freqDivInt: INTEGER); (* integer divisor *)
  (* clock out 0 on RP21 feeds ICE35 *)
    VAR padCfg: GPIO.PadCfg;
  BEGIN
    GPIO.ResetPin(IceClockPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    GPIO.ConfigurePad(IceClockPin, padCfg);
    GPIO.SetFunction(IceClockPin, MCU.IO_BANK0_Fclk);
    ClockOut.Start(ClockOut.COUT0, MCU.CLK_GPOUT_ClkPeri, freqDivInt, 0)
  END StartClock;


  PROCEDURE StartFpga*;
    CONST Delay0 = 2; (* microseconds *)
    VAR padCfg: GPIO.PadCfg; timer: Timers.Device;
  BEGIN
    NEW(timer); ASSERT(timer # NIL, Errors.HeapOverflow);
    Timers.Init(timer, Timers.TIMER0);
    GPIO.ResetPin(IceResetPin);
    GPIO.GetPadBaseCfg(padCfg);
    padCfg.pulldownEn := GPIO.Disabled;
    padCfg.pullupEn := GPIO.Disabled;
    padCfg.outputDe := GPIO.OutputConn;
    GPIO.ConfigurePad(IceResetPin, padCfg);
    GPIO.SetFunction(IceResetPin, MCU.IO_BANK0_Fsio);
    GPIO.OutputEnable2({IceResetPin}, {});
    GPIO.Clear2({IceResetPin}, {});
    Timers.DelayBlk(timer, Delay0);
    GPIO.Set2({IceResetPin}, {});
    DISPOSE(timer)
  END StartFpga;


  PROCEDURE StopFpga*;
  (* pull iCE CRESET low *)
  BEGIN
    GPIO.Clear2({IceResetPin}, {});
    GPIO.DisconnectOutput(IceResetPin) (* hi-z, let pull-down take over *)
  END StopFpga;

(*
  PROCEDURE init;
  BEGIN
    NEW(timer);
    Timers.Init(timer, Timers.TIMER0)
  END init;
*)
BEGIN
(*
  init
*)
END ICE40UP5K.
