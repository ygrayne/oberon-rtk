MODULE PIOsquarePio;
(**
  Oberon RTK Framework
  Generated module from PIO assembly code.
  Assembly program:
    .program squarewave
      set pindirs 1
    loop:
      set pins 1 [1]
      set pins 0
      jmp loop
**)

  PROCEDURE GetCode*(VAR code: ARRAY OF INTEGER; VAR n: INTEGER);
  BEGIN
    code[0] := 0E081H;
    code[1] := 0E101H;
    code[2] := 0E000H;
    code[3] := 00001H;
    n := 4
  END GetCode;
END PIOsquarePio.
