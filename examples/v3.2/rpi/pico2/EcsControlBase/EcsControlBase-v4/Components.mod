MODULE Components;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v4
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT UART, QueueingPort, TextMessages, Errors;

  CONST
    NumLed* = 4;

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

    (* producer: StateSystem *)
    (* consumer: DrainSystem *)
    (* init: world creation *)
    OutputPort* = POINTER TO OutputPortDesc;
    OutputPortDesc* = RECORD
      port*: QueueingPort.Port
    END;

    (* owned: DrainSystem *)
    (* init: world creation *)
    TxCursor* = POINTER TO TxCursorDesc;
    TxCursorDesc* = RECORD
      msg*: TextMessages.Message (* don't NEW, gets message from OutputPort *)
    END;

    (* locked: StateSystem *)
    (* init: world creation, locked for steady state *)
    StatusSource* = POINTER TO StatusSourceDesc;
    StatusSourceDesc* = RECORD
      leds*: SET
    END;


  VAR
    (* LED components instances *)
    ledBinding*: ARRAY NumLed OF LedBinding;
    ledState*: ARRAY NumLed OF LedState;
    blinkConfig*: ARRAY NumLed OF BlinkConfig;
    ledGpioBinding*: ARRAY NumLed OF LedGpioBinding;
    (* terminal components instances *)
    uartBinding*: UartBinding;
    outputPort*: OutputPort;
    txCursor*: TxCursor;
    statusSource*: StatusSource;


  PROCEDURE Create*;
  (* allocate the components in the heap *)
  (* also allocate any POINTER TO RECORD component elements *)
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < NumLed DO
      NEW(ledBinding[i]); ASSERT(ledBinding[i] # NIL, Errors.HeapOverflow);
      NEW(ledState[i]); ASSERT(ledState[i] # NIL, Errors.HeapOverflow);
      NEW(blinkConfig[i]); ASSERT(blinkConfig[i] # NIL, Errors.HeapOverflow);
      NEW(ledGpioBinding[i]); ASSERT(ledGpioBinding[i] # NIL, Errors.HeapOverflow);
      INC(i)
    END;
    NEW(uartBinding); ASSERT(uartBinding # NIL, Errors.HeapOverflow);
    NEW(uartBinding.device); ASSERT(uartBinding.device # NIL, Errors.HeapOverflow);
    NEW(outputPort); ASSERT(outputPort # NIL, Errors.HeapOverflow);
    NEW(outputPort.port); ASSERT(outputPort.port # NIL, Errors.HeapOverflow);
    NEW(txCursor); ASSERT(txCursor # NIL, Errors.HeapOverflow);
    NEW(statusSource); ASSERT(statusSource # NIL, Errors.HeapOverflow)
  END Create;

END Components.
