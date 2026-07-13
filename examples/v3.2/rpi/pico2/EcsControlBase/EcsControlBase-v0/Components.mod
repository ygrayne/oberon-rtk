MODULE Components;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v0
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT UART, BUFstr, TextIO, Errors;

  TYPE
    (* -- entity LED components -- *)
    (* locked: BlinkSystem *)
    (* init: world creation, locked for steady state *)
    LedBinding* = POINTER TO LedBindingDesc;
    LedBindingDesc* = RECORD
      led*: INTEGER
    END;

    (* owned: BlinkSystem *)
    (* init: world creation *)
    LedState* = POINTER TO LedStateDesc;
    LedStateDesc* = RECORD
      value*: INTEGER
    END;

    (* owned: BlinkSystem *)
    (* init: world creation *)
    BlinkConfig* = POINTER TO BlinkConfigDesc;
    BlinkConfigDesc* = RECORD
      period*: INTEGER;
      ticker*: INTEGER
    END;


    (* locked: StateSystem *)
    (* init: world creation, locked for steady state *)
    LedGpioBinding* = POINTER TO LedGpioBindingDesc;
    LedGpioBindingDesc* = RECORD
      ledPin*: INTEGER;
      ledPinPort*: INTEGER
    END;

    (* -- entity terminal components -- *)
    (* locked: DrainSystem *)
    (* init: world creation, locked for steady state *)
    UartBinding* = POINTER TO UartBindingDesc;
    UartBindingDesc* = RECORD
      device*: UART.Device
    END;

    (* locked: StateSystem *)
    (* init: world creation, locked for steady state *)
    TxBufWriter* = POINTER TO TxBufWriterDesc;
    TxBufWriterDesc* = RECORD
      writer*: TextIO.Writer
    END;

    (* producer: StateSystem *)
    (* consumer: DrainSystem *)
    (* init: world creation *)
    (* note: device includes the tx buffer, written via TxBufWriter.writer *)
    TxData* = POINTER TO TxDataDesc;
    TxDataDesc* = RECORD
      device*: BUFstr.Device;
      seq*: INTEGER
    END;

    (* producer: DrainSystem *)
    (* consumer: StateSystem *)
    (* init: world creation *)
    TxCursor* = POINTER TO TxCursorDesc;
    TxCursorDesc* = RECORD
      buf*: ARRAY BUFstr.BufSize OF CHAR;
      numChar*: INTEGER;
      pos*: INTEGER;
      done*: BOOLEAN;
      seqDone*: INTEGER
    END;


  VAR
    (* -- entity LED component instances -- *)
    ledBinding*: LedBinding;
    ledState*: LedState;
    blinkConfig*: BlinkConfig;
    ledGpioBinding*: LedGpioBinding;
    (* -- entity terminal component instances -- *)
    uartBinding*: UartBinding;
    txBufWriter*: TxBufWriter;
    txData*: TxData;
    txCursor*: TxCursor;


  PROCEDURE Create*;
  (* allocate the components in the heap *)
  (* also allocate any POINTER TO RECORD component elements *)
  BEGIN
    NEW(ledBinding); ASSERT(ledBinding # NIL, Errors.HeapOverflow);
    NEW(ledState); ASSERT(ledState # NIL, Errors.HeapOverflow);
    NEW(blinkConfig); ASSERT(blinkConfig # NIL, Errors.HeapOverflow);
    NEW(ledGpioBinding); ASSERT(uartBinding # NIL, Errors.HeapOverflow);
    NEW(uartBinding); ASSERT(ledGpioBinding # NIL, Errors.HeapOverflow);
    NEW(uartBinding.device); ASSERT(uartBinding.device # NIL, Errors.HeapOverflow);
    NEW(txBufWriter); ASSERT(txBufWriter # NIL, Errors.HeapOverflow);
    NEW(txBufWriter.writer); ASSERT(txBufWriter.writer # NIL, Errors.HeapOverflow);
    NEW(txData); ASSERT(txData # NIL, Errors.HeapOverflow);
    NEW(txData.device); ASSERT(txData.device # NIL, Errors.HeapOverflow);
    NEW(txCursor); ASSERT(txCursor # NIL, Errors.HeapOverflow)
  END Create;

END Components.
