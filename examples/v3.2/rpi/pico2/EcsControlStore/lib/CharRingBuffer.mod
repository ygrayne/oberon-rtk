MODULE CharRingBuffer;
(**
  Oberon RTK Framework
  Version v4.0
  --
  Circular (ring) buffer -- single producer, single consumer.
  --
  The pure algorithmic part: the buffer itself and the state are provided
  by the client module.
  --
  * 'head' = next write index (owned by the producer)
  * 'tail' = next read index  (owned by the consumer)
  * one slot is kept empty as the full/empty separator -- no element
    count is stored: empty <=> head = tail, full <=> next(head) = tail
  * each index has a single writer (producer writes only 'head',
    consumer writes only 'tail'): the lock-free SPSC discipline. On a
    single core, a thread and its own interrupt handler are one
    observer -- each sees the other's writes in program order -- so no
    memory barrier is needed, whether the two ends are two cooperative
    Systems or a System and an ISR. A data barrier (DMB) is required
    only when the ends sit on separate bus masters (a second core, or
    DMA); the marked spots in 'Put' and 'Get' show where it would go.
  --
  'Init' must be called after 'NEW'.
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)


  TYPE
    Element* = CHAR;

    State* = RECORD
      size: INTEGER;
      head: INTEGER;   (* next write index, producer-owned *)
      tail: INTEGER    (* next read index, consumer-owned *)
    END;


  PROCEDURE* next(i, size: INTEGER): INTEGER;
  (* advance an index by one slot, wrapping at 'Size' *)
  BEGIN
    INC(i);
    IF i = size THEN i := 0 END
    RETURN i
  END next;


  PROCEDURE* Init*(VAR state: State; size: INTEGER);
  BEGIN
    state.size := size;
    state.head := 0;
    state.tail := 0
  END Init;


  PROCEDURE* Empty*(state: State): BOOLEAN;
    RETURN state.head = state.tail
  END Empty;


  PROCEDURE Full*(state: State): BOOLEAN;
    RETURN next(state.head, state.size) = state.tail
  END Full;


  PROCEDURE* Count*(state: State): INTEGER;
    VAR n: INTEGER;
  BEGIN
    n := state.head - state.tail;
    IF n < 0 THEN INC(n, state.size) END
    RETURN n
  END Count;


  PROCEDURE Put*(VAR state: State; VAR buf: ARRAY OF Element; x: Element);
    VAR h: INTEGER;
  BEGIN
    h := next(state.head, state.size);
    IF h # state.tail THEN (* room for one, keeping the separator slot *)
      buf[state.head] := x;
      (* SYSTEM.EMIT(ASM.DMB); *)  (* release: only if the consumer is on another bus master *)
      state.head := h (* publish: advance head last *)
    END
  END Put;


  PROCEDURE Get*(VAR state: State; buf: ARRAY OF Element; VAR x: Element);
  BEGIN
    IF state.head # state.tail THEN (* not empty *)
      (* SYSTEM.EMIT(ASM.DMB); *)  (* acquire: only if the producer is on another bus master *)
      x := buf[state.tail];
      (* SYSTEM.EMIT(ASM.DMB); *)  (* release: only if the producer is on another bus master *)
      state.tail := next(state.tail, state.size) (* release: advance tail last *)
    END
  END Get;

END CharRingBuffer.
