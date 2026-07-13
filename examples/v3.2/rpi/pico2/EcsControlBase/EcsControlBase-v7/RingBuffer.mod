MODULE RingBuffer;
(**
  Oberon RTK Framework v3.2
  --
  Example/test program for ECS architecture
  EcsControlBase-v7
  --
  Circular (ring) buffer -- single producer, single consumer.
  Candidate framework module (draft).
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
  Capacity is 'Size' - 1 usable elements (one slot is the separator).
  Element type is 'Element'.
  --
  'Init' must be called after 'NEW'.
  --
  MCU: RP2350
  Board: Pico2
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Messages;

  CONST
    Size* = 4;   (* number of slots; usable capacity = Size - 1 *)

  TYPE
    Element* = Messages.Message;

    Buffer* = POINTER TO BufferDesc;
    BufferDesc* = RECORD
      data: ARRAY Size OF Element;
      head: INTEGER;   (* next write index, producer-owned *)
      tail: INTEGER    (* next read index, consumer-owned *)
    END;


  PROCEDURE* next(i: INTEGER): INTEGER;
  (* advance an index by one slot, wrapping at 'Size' *)
  BEGIN
    INC(i);
    IF i = Size THEN i := 0 END
    RETURN i
  END next;


  PROCEDURE* Init*(b: Buffer);
    VAR i: INTEGER;
  BEGIN
    b.head := 0;
    b.tail := 0;
    i := 0;
    WHILE i < Size DO
      b.data[i] := NIL;
      INC(i)
    END
  END Init;


  PROCEDURE* Empty*(b: Buffer): BOOLEAN;
    RETURN b.head = b.tail
  END Empty;


  PROCEDURE Full*(b: Buffer): BOOLEAN;
    RETURN next(b.head) = b.tail
  END Full;


  PROCEDURE* Count*(b: Buffer): INTEGER;
  (* number of elements currently held; derived from the indices, not stored *)
    VAR n: INTEGER;
  BEGIN
    n := b.head - b.tail;
    IF n < 0 THEN INC(n, Size) END
    RETURN n
  END Count;


  PROCEDURE Put*(b: Buffer; x: Element);
    VAR h: INTEGER;
  BEGIN
    h := next(b.head);
    IF h # b.tail THEN (* room for one, keeping the separator slot *)
      b.data[b.head] := x;
      (* SYSTEM.EMIT(ASM.DMB); *)  (* release: only if the consumer is on another bus master *)
      b.head := h  (* publish: advance head last *)
    END
  END Put;


  PROCEDURE Get*(b: Buffer; VAR x: Element);
  BEGIN
    IF b.head # b.tail THEN (* not empty *)
      (* SYSTEM.EMIT(ASM.DMB); *)  (* acquire: only if the producer is on another bus master *)
      x := b.data[b.tail];
      (* SYSTEM.EMIT(ASM.DMB); *)  (* release: only if the producer is on another bus master *)
      b.tail := next(b.tail)   (* release: advance tail last *)
    END
  END Get;

END RingBuffer.
