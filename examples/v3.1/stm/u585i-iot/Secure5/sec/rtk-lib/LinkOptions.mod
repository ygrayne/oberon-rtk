MODULE LinkOptions;
(* -------------------------------------------------------------------------
   Astrobe Library module to access an application's configuration data.

   The exported global variables are initialised with data taken from the
   current configuration *.ini file when the application was linked. Consequently,
   this data can be accessed by the application when it is running on the target MCU.

   LinkOptions must be the first module to be loaded when an application is
   linked. This can be ensured by listing LinkOptions first in the IMPORT list
   of the Main module.

   (c) 2012-2024 CFB Software
   https://www.astrobe.com

   ------------------------------------------------------------------------- *)

IMPORT SYSTEM;

VAR
  OptionsStart: INTEGER;

  (* .ini file data *)
  ConfigID*: INTEGER;
  HeapStart*: INTEGER;
  HeapLimit*: INTEGER;
  StackStart*: INTEGER;
  ResourceStart*: INTEGER;
  DataStart*: INTEGER;
  DataEnd*: INTEGER;
  cs, CodeStart*: INTEGER;
  CodeEnd*: INTEGER;

PROCEDURE* CodeStartAddress;
END CodeStartAddress;

PROCEDURE Init();
BEGIN
  cs := SYSTEM.ADR(CodeStartAddress) - 244H;
  OptionsStart := cs + 200H;
  SYSTEM.GET(OptionsStart + 4, ConfigID);
  SYSTEM.GET(OptionsStart + 8, HeapStart);
  SYSTEM.GET(OptionsStart + 12, HeapLimit);
  SYSTEM.GET(OptionsStart + 16, ResourceStart);
  (* Module Initialisation Table = OptionsStart + 20 *)
  SYSTEM.GET(OptionsStart + 24, DataStart);
  SYSTEM.GET(OptionsStart + 28,  DataEnd);
  SYSTEM.GET(OptionsStart + 32, CodeStart);
  SYSTEM.GET(OptionsStart + 36, CodeEnd);
  SYSTEM.GET(CodeStart, StackStart)
END Init;

BEGIN
  Init()
END LinkOptions.
