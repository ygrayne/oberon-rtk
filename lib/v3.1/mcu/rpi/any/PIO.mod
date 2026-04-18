MODULE PIO;
(**
  Oberon RTK Framework
  Version: v3.1
  --
  PIO devices
  First-cut implementation, to get the example program running.
  See https://oberon-rtk.org/examples/v2/piosquare/
  --
  Type: MCU
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2024-2026 Gray gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM, BASE, DEV := PIO_DEV, RST, Errors;

  CONST
    PIO0* = DEV.PIO0;
    PIO1* = DEV.PIO1;
    PIO2* = DEV.PIO1;
    SM0* = DEV.SM0;
    SM1* = DEV.SM1;
    SM2* = DEV.SM2;
    SM3* = DEV.SM3;



    StateMachines = {SM0 .. SM3};

    (* CTRL bits and values *)
    CTRL_CLKDIV_RESTART1 = 11;
    CTRL_CLKDIV_RESTART0 = 8;
    CTRL_SM_RESTART1     = 7;
    CTRL_SM_RESTART0     = 4;
    CTRL_SM_ENABLE1      = 3;
    CTRL_SM_ENABLE0      = 0;

    (* SM_PINCTRL bits and values (per state machine) *)
    SM_PINCTRL_SIDESET_COUNT1 = 31;
    SM_PINCTRL_SIDESET_COUNT0 = 29;
    SM_PINCTRL_SET_COUNT1     = 28;
    SM_PINCTRL_SET_COUNT0     = 26;
    SM_PINCTRL_OUT_COUNT1     = 25;
    SM_PINCTRL_OUT_COUNT0     = 20;
    SM_PINCTRL_IN_BASE1       = 19;
    SM_PINCTRL_IN_BASE0       = 15;
    SM_PINCTRL_SIDESET_BASE1  = 14;
    SM_PINCTRL_SIDESET_BASE0  = 10;
    SM_PINCTRL_SET_BASE1      = 9;
    SM_PINCTRL_SET_BASE0      = 5;
    SM_PINCTRL_OUT_BASE1      = 4;
    SM_PINCTRL_OUT_BASE0      = 0;

    (* SM_CLKDIV bits and values (per state machine) *)
    SM_CLKDIV_INT1  = 31;
    SM_CLKDIV_INT0  = 16;
    SM_CLKDIV_FRAC1 = 15;
    SM_CLKDIV_FRAC0 = 8;

    (* SM_EXECCTRL bits and values (per state machine) *)
    SM_EXECCTRL_WRAP_TOP1     = 16;
    SM_EXECCTRL_WRAP_TOP0     = 12;
    SM_EXECCTRL_WRAP_BOTTOM1  = 11;
    SM_EXECCTRL_WRAP_BOTTOM0  = 7;

    NameLength = 32;
    NumDefs* = 8;

  TYPE
    StateMachineRegs* = RECORD
      CLKDIV: INTEGER;
      EXECCTRL: INTEGER;
      SHIFTCTRL: INTEGER;
      ADDR: INTEGER;
      INSTR: INTEGER;
      PINCTRL: INTEGER
    END;
    Device* = POINTER TO DeviceDesc;
    DeviceDesc* = RECORD
      pioNo: INTEGER;
      rstReg, rstPos: INTEGER;
      CTRL, INSTR_MEM: INTEGER;
      SM: ARRAY DEV.PIO_NumStateMachines OF StateMachineRegs
    END;

    (* PIO program data *)
    ProgName* = ARRAY NameLength OF CHAR;
    SymbolName* = ARRAY NameLength OF CHAR;
    LabelName* = ARRAY NameLength OF CHAR;

    PublicSymbol* = RECORD
      name*: SymbolName;
      value*: INTEGER
    END;

    PublicLabel* = RECORD
      name*: LabelName;
      value*: INTEGER
    END;

    Program* = RECORD
      name*: ProgName;
      wrapTarget*: INTEGER;
      wrap*: INTEGER;
      origin*: INTEGER;
      sideset*: RECORD
        size*: INTEGER;
        optional*: BOOLEAN;
        pindirs*: BOOLEAN
      END;
      instr*: ARRAY DEV.PIO_MaxNumInstr OF INTEGER;
      numInstr*: INTEGER;
      pubLabels*: ARRAY NumDefs OF PublicLabel; (* only valid of numPubLabels > 0 *)
      numPubLabels*: INTEGER;
      pubSymbols*: RECORD (* .define PUBLIC *)
        global*: ARRAY NumDefs OF PublicSymbol; (* only valid if numGlobals > 0 *)
        local*: ARRAY NumDefs OF PublicSymbol; (* only valid if numLocals > 0 *)
        numGlobals*: INTEGER;
        numLocals*: INTEGER
      END
    END;


  PROCEDURE* Init*(dev: Device; pioNo: INTEGER);
    VAR pioBase, i: INTEGER; smBase: ARRAY DEV.PIO_NumStateMachines OF INTEGER;
  BEGIN
    ASSERT(dev # NIL, Errors.HeapOverflow);
    ASSERT(pioNo IN DEV.PIO_all);
    dev.pioNo := pioNo;
    dev.rstReg := DEV.PIO_RST_reg;
    dev.rstPos := DEV.PIO0_RST_pos + pioNo;

    pioBase := DEV.PIO0_BASE + (pioNo * DEV.PIO_Offset);
    dev.CTRL := pioBase + DEV.PIO_CTRL_Offset;
    dev.INSTR_MEM := pioBase + DEV.PIO_INSTR_MEM0_Offset;
    smBase[0] := pioBase + DEV.PIO_SM0_Offset;
    smBase[1] := smBase[0] + DEV.PIO_SM_Offset;
    smBase[2] := smBase[1] + DEV.PIO_SM_Offset;;
    smBase[3] := smBase[2] + DEV.PIO_SM_Offset;
    i := 0;
    WHILE i < DEV.PIO_NumStateMachines DO
      dev.SM[i].CLKDIV := smBase[i] + DEV.PIO_SM_CLKDIV_Offset;
      dev.SM[i].EXECCTRL := smBase[i] + DEV.PIO_SM_EXECCTRL_Offset;
      dev.SM[i].SHIFTCTRL := smBase[i] + DEV.PIO_SM_SHIFTCTRL_Offset;
      dev.SM[i].ADDR := smBase[i] + DEV.PIO_SM_ADDR_Offset;
      dev.SM[i].INSTR := smBase[i] + DEV.PIO_SM_INSTR_Offset;
      dev.SM[i].PINCTRL := smBase[i] + DEV.PIO_SM_PINCTRL_Offset;
      INC(i)
    END
  END Init;


  PROCEDURE Enable*(dev: Device);
  BEGIN
    RST.ReleaseReset(dev.rstReg, dev.rstPos)
  END Enable;


  PROCEDURE* EnableStateMachines*(dev: Device; mask: SET);
  BEGIN
    SYSTEM.PUT(dev.CTRL + BASE.ASET, mask * StateMachines)
  END EnableStateMachines;


  PROCEDURE* DisableStateMachines*(dev: Device; mask: SET);
  BEGIN
    SYSTEM.PUT(dev.CTRL + BASE.ACLR, mask * StateMachines)
  END DisableStateMachines;


  PROCEDURE* RestartStateMachines*(dev: Device; mask: SET);
  BEGIN
    mask := mask * StateMachines;
    mask := BITS(LSL(ORD(mask), CTRL_SM_RESTART0));
    SYSTEM.PUT(dev.CTRL + BASE.ASET, mask)
  END RestartStateMachines;


  PROCEDURE* RestartClockDivs*(dev: Device; mask: SET);
  BEGIN
    mask := mask * StateMachines;
    mask := BITS(LSL(ORD(mask), CTRL_CLKDIV_RESTART0));
    SYSTEM.PUT(dev.CTRL + BASE.ASET, mask)
  END RestartClockDivs;


  PROCEDURE* PutCode*(dev: Device; code: ARRAY OF INTEGER; offset, numInstr: INTEGER);
    VAR i, regAddr: INTEGER;
  BEGIN
    ASSERT(offset + numInstr <= DEV.PIO_MaxNumInstr, Errors.ProgError);
    regAddr := dev.INSTR_MEM + (offset * DEV.PIO_INSTR_MEM_Offset);
    i := 0;
    WHILE i < numInstr DO
      SYSTEM.PUT(regAddr, code[i]);
      INC(i); INC(regAddr, DEV.PIO_INSTR_MEM_Offset)
    END
  END PutCode;


  PROCEDURE* ConfigPinsSet*(dev: Device; smNo: INTEGER; basePinNo, count: INTEGER);
    CONST ClearMask = {SM_PINCTRL_SET_BASE0 .. SM_PINCTRL_SET_BASE1, SM_PINCTRL_SET_COUNT0 .. SM_PINCTRL_SET_COUNT1};
    VAR x: INTEGER;
  BEGIN
    x := LSL(basePinNo, SM_PINCTRL_SET_BASE0) + LSL(count, SM_PINCTRL_SET_COUNT0);
    SYSTEM.PUT(dev.SM[smNo].PINCTRL + BASE.ACLR, ClearMask);
    SYSTEM.PUT(dev.SM[smNo].PINCTRL + BASE.ASET, x)
  END ConfigPinsSet;


  PROCEDURE* ConfigClockDiv*(dev: Device; smNo, int, frac: INTEGER);
  (* int = 0 => works as int = 65536 *)
    VAR x: INTEGER;
  BEGIN
    x := LSL(frac, SM_CLKDIV_FRAC0) + LSL(int, SM_CLKDIV_INT0);
    SYSTEM.PUT(dev.SM[smNo].CLKDIV, x)
  END ConfigClockDiv;


  PROCEDURE* ConfigWrap*(dev: Device; smNo: INTEGER; wrapBottom, wrapTop: INTEGER);
    CONST ClearMask = {SM_EXECCTRL_WRAP_BOTTOM0 .. SM_EXECCTRL_WRAP_BOTTOM1, SM_EXECCTRL_WRAP_TOP0 .. SM_EXECCTRL_WRAP_TOP1};
    VAR x: INTEGER;
  BEGIN
    x := LSL(wrapBottom, SM_EXECCTRL_WRAP_BOTTOM0) + LSL(wrapTop, SM_EXECCTRL_WRAP_TOP0);
    SYSTEM.PUT(dev.SM[smNo].EXECCTRL + BASE.ACLR, ClearMask);
    SYSTEM.PUT(dev.SM[smNo].EXECCTRL + BASE.ASET, x)
  END ConfigWrap;


  PROCEDURE* SetStartAddr*(dev: Device; smNo: INTEGER; addr: INTEGER);
  BEGIN
    SYSTEM.PUT(dev.SM[smNo].INSTR, addr) (* JMP to addr *)
  END SetStartAddr;


  (* Secure/Non-secure, RP2350 only *)

  PROCEDURE GetDevSec*(pioNo: INTEGER; VAR reg: INTEGER);
  BEGIN
    ASSERT(pioNo IN DEV.PIO_all);
    reg := DEV.PIO0_SEC_reg + (pioNo * 4)
  END GetDevSec;



END PIO.
