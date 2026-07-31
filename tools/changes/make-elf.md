## Change Notes: make-elf

Covers `make-elf.py` and its library `pylib/elfdata.py`. Newest first.

### 2026-07-31

`pylib/elfdata.py`:
* fix: record members were dropped from the debug data when the record is only reachable through a pointer, or when the member type is an array of scalars
* record members can now forward-reference type DIEs emitted later in the compilation unit (back-patched, DW_FORM_ref4)
* exported type declarations get complete type DIEs even when not used by any variable in the declaring module
* an unresolvable member type now prints a warning instead of being dropped silently
