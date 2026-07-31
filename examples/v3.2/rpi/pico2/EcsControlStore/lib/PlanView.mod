MODULE PlanView;
(**
  Oberon RTK Framework
  Version: v4.0
  --
  Dev-build companion to Kernel: human-readable view of Plan results.
  --
  MCU: RP2350
  --
  Copyright (c) 2026 Gray, gray@grayraven.org
  https://oberon-rtk.org/licences/
**)

  IMPORT Kernel, Texts, TokenNames;

  CONST
    MsgSize = 48;

  VAR
    checkMsg: ARRAY Kernel.NumChecks OF ARRAY MsgSize OF CHAR;


  PROCEDURE writeToken(wh, id: INTEGER);
  BEGIN
    IF (id < LEN(TokenNames.Names)) & (TokenNames.Names[id][0] # 0X) THEN
      Texts.WriteString(wh, TokenNames.Names[id])
    ELSE
      Texts.WriteString(wh, "token "); Texts.WriteInt(wh, id, 0)
    END
  END writeToken;


  PROCEDURE writeTokenSet(wh: INTEGER; tokens: SET);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < Kernel.MaxTokens DO
      IF i IN tokens THEN
        Texts.WriteString(wh, "     "); writeToken(wh, i); Texts.WriteLn(wh)
      END;
      INC(i)
    END
  END writeTokenSet;


  PROCEDURE writeSystemSet(wh: INTEGER; sys: SET);
    VAR i: INTEGER;
  BEGIN
    i := 0;
    WHILE i < Kernel.NumSystems DO
      IF i IN sys THEN
        Texts.WriteString(wh, "     "); Texts.WriteString(wh, Kernel.Systems[i].name); Texts.WriteLn(wh)
      END;
      INC(i)
    END
  END writeSystemSet;


  PROCEDURE Manifests*(wh: INTEGER);
    VAR i: INTEGER;
  BEGIN
    Texts.WriteString(wh, "manifests (registration order):"); Texts.WriteLn(wh);
    i := 0;
    WHILE i < Kernel.NumSystems DO
      Texts.WriteInt(wh, i, 2); Texts.WriteString(wh, " ");
      Texts.WriteString(wh, Kernel.Systems[i].name); Texts.WriteLn(wh);
      IF Kernel.Systems[i].manifest.C # {} THEN
        Texts.WriteString(wh, "   C:"); Texts.WriteLn(wh);
        writeTokenSet(wh, Kernel.Systems[i].manifest.C)
      END;
      IF Kernel.Systems[i].manifest.O # {} THEN
        Texts.WriteString(wh, "   O:"); Texts.WriteLn(wh);
        writeTokenSet(wh, Kernel.Systems[i].manifest.O)
      END;
      IF Kernel.Systems[i].manifest.P # {} THEN
        Texts.WriteString(wh, "   P:"); Texts.WriteLn(wh);
        writeTokenSet(wh, Kernel.Systems[i].manifest.P)
      END;
      IF Kernel.Systems[i].manifest.Cx # {} THEN
        Texts.WriteString(wh, "   Cx:"); Texts.WriteLn(wh);
        writeTokenSet(wh, Kernel.Systems[i].manifest.Cx)
      END;
      IF Kernel.Systems[i].manifest.Px # {} THEN
        Texts.WriteString(wh, "   Px:"); Texts.WriteLn(wh);
        writeTokenSet(wh, Kernel.Systems[i].manifest.Px)
      END;
      INC(i)
    END
  END Manifests;


  PROCEDURE Deps*(wh: INTEGER);
    VAR i: INTEGER;
  BEGIN
    Texts.WriteString(wh, "dependencies (registration order):"); Texts.WriteLn(wh);
    i := 0;
    WHILE i < Kernel.NumSystems DO
      Texts.WriteInt(wh, i, 2); Texts.WriteString(wh, " ");
      Texts.WriteString(wh, Kernel.Systems[i].name); Texts.WriteLn(wh);
      writeSystemSet(wh, Kernel.Deps[i]);
      INC(i)
    END
  END Deps;


  PROCEDURE Order*(wh: INTEGER);
    VAR i: INTEGER;
  BEGIN
    Texts.WriteString(wh, "derived scheduling order:"); Texts.WriteLn(wh);
    i := 0;
    WHILE i < Kernel.NumPlaced DO
      Texts.WriteInt(wh, i, 2); Texts.WriteString(wh, " ");
      Texts.WriteString(wh, Kernel.Systems[Kernel.Order[i]].name); Texts.WriteLn(wh);
      INC(i)
    END;
    IF Kernel.NumPlaced < Kernel.NumSystems THEN
      Texts.WriteString(wh, "  stalled: cycle among remaining systems"); Texts.WriteLn(wh)
    END
  END Order;


  PROCEDURE Violations*(wh: INTEGER);
    VAR chk: INTEGER;
  BEGIN
    IF Kernel.Failed = {} THEN
      Texts.WriteString(wh, "plan checks: all pass"); Texts.WriteLn(wh)
    ELSE
      Texts.WriteString(wh, "plan check violations:"); Texts.WriteLn(wh);
      chk := 0;
      WHILE chk < Kernel.NumChecks DO
        IF chk IN Kernel.Failed THEN
          Texts.WriteString(wh, " ");
          Texts.WriteString(wh, checkMsg[chk]);
          IF chk IN Kernel.Relaxed THEN
            Texts.WriteString(wh, " (waived)")
          END;
          Texts.WriteLn(wh);
          IF chk = Kernel.ChkCycle THEN
            writeSystemSet(wh, Kernel.Offend[chk])
          ELSE
            writeTokenSet(wh, Kernel.Offend[chk])
          END
        END;
        INC(chk)
      END
    END
  END Violations;


  PROCEDURE Report*(wh: INTEGER);
  BEGIN
    Texts.WriteString(wh, "Kernel.Plan"); Texts.WriteLn(wh);
    Manifests(wh);
    Deps(wh);
    Order(wh);
    Violations(wh)
  END Report;

BEGIN
  checkMsg[Kernel.ChkWriter] := "multiple writers";
  checkMsg[Kernel.ChkClass] := "token class conflict (P/O vs Px, C vs Cx)";
  checkMsg[Kernel.ChkOwnedRead] := "owned token consumed";
  checkMsg[Kernel.ChkSelfLoop] := "consumes own written token";
  checkMsg[Kernel.ChkUnproduced] := "consumed but not produced";
  checkMsg[Kernel.ChkUnconsumed] := "produced but not consumed";
  checkMsg[Kernel.ChkNoCollector] := "deposit without collector";
  checkMsg[Kernel.ChkCycle] := "dependency cycle"
END PlanView.
