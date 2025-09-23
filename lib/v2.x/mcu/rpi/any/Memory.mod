MODULE Memory;
(**
  Oberon RTK Framework v2
  --
  * heap memory allocation for two cores
  * stacks allocation for two cores
  --
  MCU: RP2040, RP2350
  --
  Copyright (c) 2023-2025 Gray, gray@grayraven.org
  Portions copyright (c) 2012-2021 CFB Software, https://www.astrobe.com
  Used with permission.
  Please refer to the licensing conditions as defined at the end of this file.
**)

  IMPORT SYSTEM, MCU := MCU2, Config, MAU;

  CONST
    NumCores = MCU.NumCores;
    NumThreadStacks = 16;
    CoreZeroMainStackSize* = 2048; (* default, see SetMainStackSize below *)
    CoreOneMainStackSize*  = 2048;

    StackSeal* = 0FEF5EDA5H;

  TYPE
    CoreHeap = RECORD
      heapLimit: INTEGER;
      heapTop: INTEGER
    END;

    Stack = RECORD
      addr: INTEGER;
      size: INTEGER
    END;

    CoreStacks = RECORD
      threadStacks: ARRAY NumThreadStacks OF Stack;
      loopStack: Stack;
      stacksBottom, stacksTop: INTEGER;
      stackCheckEnabled: BOOLEAN
    END;

    DataMemory* = RECORD
      stackStart*: INTEGER;
      dataStart*: INTEGER
    END;

    CoreDataMemory* = ARRAY NumCores OF DataMemory;

  VAR
    DataMem*: CoreDataMemory;
    heaps: ARRAY NumCores OF CoreHeap;
    stacks: ARRAY NumCores OF CoreStacks;

  (* === heap memory === *)

  (* --- Astrobe code begin --- *)

  PROCEDURE* Allocate*(VAR p: INTEGER; typeDesc: INTEGER);
  (* from Astrobe library, modified *)
  (* allocate record, prefix with typeDesc field of 1 word with offset -4 *)
    VAR cid, h, size, limit: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid); (* direct, for leaf procedure *)
    limit := heaps[cid].heapLimit;
    IF limit = 0 THEN
      limit := stacks[cid].stacksBottom
    END;
    (* obtain record size from type descriptor, usually in flash *)
    SYSTEM.GET(typeDesc, size);
    h := heaps[cid].heapTop + 4 + size;
    IF h > limit THEN
      p := 0
    ELSE
      p := heaps[cid].heapTop + 4;
      (* address of type descriptor to tagfield of new record *)
      SYSTEM.PUT(heaps[cid].heapTop, typeDesc);
      heaps[cid].heapTop := h
    END;
  END Allocate;


  PROCEDURE* Deallocate*(VAR p: INTEGER; typeDesc: INTEGER);
  (* from Astrobe Library, modified *)
  (* Assign NIL = 0 to the pointer 'p'. Reclaim the space if this was the most
     recent allocation, otherwise do nothing. *)
    VAR cid, h, size: INTEGER;
  BEGIN
    ASSERT(p # 0, 12);
    SYSTEM.GET(MCU.SIO_CPUID, cid); (* direct, for leaf procedure *)
    (* obtain record size from type descriptor, usually in flash *)
    SYSTEM.GET(typeDesc, size);
    h := heaps[cid].heapTop - size;
    IF h = p THEN heaps[cid].heapTop := h - 4 END;
    p := 0
  END Deallocate;

  (* --- Astrobe code end --- *)

  PROCEDURE* LockHeaps*;
    CONST Core0 = 0; Core1 = 1;
  BEGIN
    heaps[Core0].heapLimit := heaps[Core0].heapTop;
    heaps[Core1].heapLimit := heaps[Core1].heapTop
  END LockHeaps;

  (* === thread & loop stacks === *)

  PROCEDURE* initStackCheck(addr, limit: INTEGER);
  BEGIN
    WHILE addr < limit DO
      SYSTEM.PUT(addr, addr + 3);
      INC(addr, 4)
    END
  END initStackCheck;


  PROCEDURE* checkStackUsage(addr, limit: INTEGER; VAR unused: INTEGER);
    VAR value: INTEGER;
  BEGIN
    SYSTEM.GET(addr, value);
    unused := 0;
    WHILE (value = addr + 3) & (addr < limit) DO
      INC(addr, 4); INC(unused, 4);
      SYSTEM.GET(addr, value)
    END
  END checkStackUsage;


  PROCEDURE CheckLoopStackUsage*(VAR size, used: INTEGER);
    VAR cid, addr, limit, unused: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    addr := stacks[cid].loopStack.addr;
    size := stacks[cid].loopStack.size;
    limit := addr + size;
    checkStackUsage(addr, limit, unused);
    used := size - unused
  END CheckLoopStackUsage;


  PROCEDURE CheckThreadStackUsage*(id: INTEGER; VAR size, used: INTEGER);
    VAR cid, addr, limit, unused: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    addr := stacks[cid].threadStacks[id].addr;
    size := stacks[cid].threadStacks[id].size;
    limit := addr + size;
    checkStackUsage(addr, limit, unused);
    used := size - unused
  END CheckThreadStackUsage;


  PROCEDURE* allocStack(VAR stkAddr: INTEGER; cid, stkSize: INTEGER);
    VAR limit: INTEGER;
  BEGIN
    limit := heaps[cid].heapLimit;
    IF limit = 0 THEN
      limit := heaps[cid].heapTop
    END;
    IF stacks[cid].stacksBottom - stkSize > limit THEN
      SYSTEM.PUT(stacks[cid].stacksBottom - 4, StackSeal);
      DEC(stacks[cid].stacksBottom, stkSize);
      stkAddr := stacks[cid].stacksBottom
    ELSE
      stkAddr := 0
    END
  END allocStack;


  PROCEDURE AllocThreadStack*(VAR stkAddr: INTEGER; id, stkSize: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    allocStack(stkAddr, cid, stkSize);
    IF stkAddr # 0 THEN
      stacks[cid].threadStacks[id].addr := stkAddr;
      stacks[cid].threadStacks[id].size := stkSize;
      IF stacks[cid].stackCheckEnabled THEN
        initStackCheck(stkAddr, stkAddr + stkSize)
      END
    END
  END AllocThreadStack;


  PROCEDURE AllocLoopStack*(VAR stkAddr: INTEGER; stkSize: INTEGER);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    allocStack(stkAddr, cid, stkSize);
    IF stkAddr # 0 THEN
      stacks[cid].loopStack.addr := stkAddr;
      stacks[cid].loopStack.size := stkSize;
      IF stacks[cid].stackCheckEnabled THEN
        initStackCheck(stkAddr, stkAddr + stkSize)
      END
    END
  END AllocLoopStack;


  PROCEDURE* EnableStackCheck*(on: BOOLEAN);
    VAR cid: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    stacks[cid].stackCheckEnabled := on
  END EnableStackCheck;


  PROCEDURE* ResetMainStack*;
  (* set MSP to top of stack memory from kernel loopc *)
  (* clear out the top of the main stack to get clean stack traces *)
    CONST R11 = 11;
    VAR cid, addr: INTEGER;
  BEGIN
    SYSTEM.GET(MCU.SIO_CPUID, cid);
    addr := DataMem[cid].stackStart;
    SYSTEM.LDREG(R11, addr);
    SYSTEM.EMIT(MCU.MSR_MSP_R11); (* move r11 to msp *)
    (*
    DEC(addr, 4); (* leave top-most value alone: stack seal *)
    i := 0;
    WHILE i < 256 DO
      SYSTEM.PUT(addr, 0);
      INC(i); DEC(addr, 4)
    END
    *)
  END ResetMainStack;

  (* === init and config === *)

  PROCEDURE* SetMainStackSize*(core0mainStackSize, core1mainStackSize: INTEGER);
  (* must be used before Kernel.Install *)
    CONST Core0 = 0; Core1 = 1;
  BEGIN
    stacks[Core0].stacksBottom := Config.CoreZeroStackStart - core0mainStackSize;
    stacks[Core1].stacksBottom := Config.CoreOneStackStart - core1mainStackSize;
  END SetMainStackSize;


  PROCEDURE init;
    CONST Core0 = 0; Core1 = 1;
  BEGIN
    MAU.SetNew(Allocate); MAU.SetDispose(Deallocate);

    (* exported info *)
    DataMem[Core0].stackStart := Config.CoreZeroStackStart;
    DataMem[Core0].dataStart := Config.CoreZeroDataStart;
    DataMem[Core1].stackStart := Config.CoreOneStackStart;
    DataMem[Core1].dataStart := Config.CoreOneDataStart;

    (* heaps *)
    heaps[Core0].heapTop := Config.CoreZeroHeapStart;
    heaps[Core0].heapLimit := Config.CoreZeroHeapLimit;
    heaps[Core1].heapTop := Config.CoreOneHeapStart;
    heaps[Core1].heapLimit := Config.CoreOneHeapLimit;

    (* thread & loop stacks *)
    stacks[Core0].stacksBottom := Config.CoreZeroStackStart - CoreZeroMainStackSize;
    stacks[Core0].stacksTop := Config.CoreZeroStackStart;
    stacks[Core0].stackCheckEnabled := FALSE;
    stacks[Core1].stacksBottom := Config.CoreOneStackStart - CoreOneMainStackSize;
    stacks[Core1].stacksTop := Config.CoreOneStackStart;
    stacks[Core1].stackCheckEnabled := FALSE;

    (* mark top of main stack (0FEF5EDA5H) *)
    SYSTEM.PUT(DataMem[Core0].stackStart, StackSeal);
    SYSTEM.PUT(DataMem[Core1].stackStart, StackSeal)
  END init;

BEGIN
  init
END Memory.

(**
  Copyright (c) 2023-2025 Gray, gray@grayraven.org
  Copyright (c) 2012-2021 CFB Software, https://www.astrobe.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**)
