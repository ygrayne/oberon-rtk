# Example/test Program Secure5

## rtk-lib
- Note that both programs sec/S.mod and nonsec/NS.mod use a local project library `rtk-lib`.
- Run `gen-lib` to update, or remove `rtk-lib`

```
python -m gen-lib update -f %AstrobeRP2350% "v31-stm32u585-iot-secure5-s.ini" sec/S.mod
python -m gen-lib update -f %AstrobeRP2350% "v31-stm32u585-iot-secure5-ns.ini" nonsec/NS.mod

with
- %AstrobeRP2350% = actual value for your installation
- v31-stm32u585-iot-secure5-s.ini and v31-stm32u585-iot-secure5-ns.ini possibly adjusted for your installation
```
