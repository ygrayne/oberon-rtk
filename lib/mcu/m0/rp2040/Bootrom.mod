MODULE Bootrom;
(**
  Oberon RTK Framework
  Access to the functions ond data in bootrom.
  --
  MCU: Cortex-M0+ RP2040, tested on Pico
  --
  Calling bootrom functions from Oberon:
  * Cf. Procedure Call Standard for the Arm Architecture, 2023Q3.
    * define corresponding procedure types
    * check assembly code to make sure the parameters and results are passed correctly,
      in particular when Astrobe uses two registers for one parameter
  * Bootrom functions have bit 0 set for thumb code, but Astrobe's
    proc variables contain the actual proc address
    => adjust bootrom function addresses by -1
  --
  Copyright (c) 2024 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT SYSTEM;

  CONST
    MagicAddr = 010H;
    TableAddrAddr = 014H; (* {31:16 DataAddr, 15:0 FuncAddr} *)
    HelperAddrAddr = 018H;

    Magic = 010000H + ORD("u") * 0100H + ORD("M");

  TYPE
    HelperFunc = PROCEDURE(tableAddr, code: INTEGER): INTEGER;


  PROCEDURE CheckMagic*(): BOOLEAN;
    VAR value: INTEGER;
  BEGIN
    SYSTEM.GET(MagicAddr, value);
    RETURN BFX(value, 23, 0) = Magic
  END CheckMagic;


  PROCEDURE GetRevision*(VAR revision: INTEGER);
    VAR value: INTEGER;
  BEGIN
    SYSTEM.GET(MagicAddr, value);
    revision := BFX(value, 31, 24)
  END GetRevision;


  PROCEDURE tableCode(c1, c2: CHAR): INTEGER;
    RETURN LSL(ORD(c2), 8) + ORD(c1)
  END tableCode;


  PROCEDURE getHelperFunc(VAR func: HelperFunc);
    VAR helperFuncAddr: INTEGER;
  BEGIN
    SYSTEM.GET(HelperAddrAddr, helperFuncAddr);
    helperFuncAddr := BFX(helperFuncAddr, 15, 0);
    func := SYSTEM.VAL(HelperFunc, helperFuncAddr - 1)
  END getHelperFunc;


  PROCEDURE GetFuncAddr*(c1, c2: CHAR; VAR addr: INTEGER);
    VAR funcTableAddr: INTEGER; helperFunc: HelperFunc;
  BEGIN
    getHelperFunc(helperFunc);
    SYSTEM.GET(TableAddrAddr, funcTableAddr);
    funcTableAddr := BFX(funcTableAddr, 15, 0);
    addr := helperFunc(funcTableAddr, tableCode(c1, c2)) - 1
  END GetFuncAddr;


  PROCEDURE GetDataAddr*(c1, c2: CHAR; VAR addr: INTEGER);
    VAR dataTableAddr: INTEGER; helperFunc: HelperFunc;
  BEGIN
    getHelperFunc(helperFunc);
    SYSTEM.GET(TableAddrAddr, dataTableAddr);
    dataTableAddr := BFX(dataTableAddr, 31, 16);
    addr := helperFunc(dataTableAddr, tableCode(c1, c2))
  END GetDataAddr;

END Bootrom.

