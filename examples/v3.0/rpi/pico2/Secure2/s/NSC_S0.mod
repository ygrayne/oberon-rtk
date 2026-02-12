MODULE NSC_S0;
(* handcrafted, but will be generated *)

  IMPORT SYSTEM, Secure, S0;

  TYPE
    SecProc = Secure.SecProc;

  PROCEDURE InstallProcs*;
    VAR res: INTEGER;
  BEGIN
    Secure.AddSecProc(SYSTEM.VAL(SecProc, S0.ToggleLED), 42, res)
    (* error handling here *)
  END InstallProcs;

END NSC_S0.
