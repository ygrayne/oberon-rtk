MODULE MAU;
  (* =========================================================================
   Astrobe Library Functions for Memory Usage

   Memory Allocation Unit; NW 15.12.2007
   The first two procedures must remain in that order!

  (c) 2012-2024 CFB Software
  https://www.astrobe.com

  ========================================================================= *)

IMPORT LinkOptions, SYSTEM;

TYPE
  Proc* = PROCEDURE (VAR p: INTEGER; T: INTEGER);

VAR
  allocate, deallocate: Proc;
  heapTop, heapLimit: INTEGER;

(* Must be 1st procedure *)
PROCEDURE New*(VAR p: INTEGER; T: INTEGER);
BEGIN
  allocate(p, T)
END New;

(* Must be 2nd procedure *)
PROCEDURE Dispose*(VAR p: INTEGER; T: INTEGER);
BEGIN
  deallocate(p, T)
END Dispose;

PROCEDURE SetNew*(p: Proc);
BEGIN
  allocate := p
END SetNew;

PROCEDURE SetDispose*(p: Proc);
BEGIN
  deallocate := p
END SetDispose;

PROCEDURE Allocate*(VAR p: INTEGER; typeDesc: INTEGER);
(* Allocate record, prefix with typeDesc field of 1 word with offset -4 *)
CONST 
  SP = 13;
VAR
  h, size, limit: INTEGER;
BEGIN
  IF heapLimit = 0 THEN
    limit := SYSTEM.REG(SP)
  ELSE
    limit := heapLimit
  END;
  (*obtain record size from type descriptor*)
  SYSTEM.GET(typeDesc, size);
  h := heapTop + 4 + size;
  IF h > limit THEN
    p := 0
  ELSE
    p := heapTop + 4;
    (* Address of type descriptor to tagfield of new record *)
    SYSTEM.PUT(heapTop, typeDesc);
    heapTop := h
  END
END Allocate;

PROCEDURE Deallocate*(VAR p: INTEGER; typeDesc: INTEGER);
(* Assign NIL to the pointer. Reclaim the space if this was the most
   recent allocation otherwise do nothing. *)
VAR
  h, size: INTEGER;
BEGIN
  ASSERT(p # 0, 12);
  (*obtain record size from type descriptor*)
  SYSTEM.GET(typeDesc, size);
  h := heapTop - size;
  IF h = p THEN heapTop := h - 4 END;
  p := 0
END Deallocate;

BEGIN
  SetNew(Allocate);
  SetDispose(Deallocate);
  heapTop := LinkOptions.HeapStart;
  heapLimit := LinkOptions.HeapLimit
END MAU.

