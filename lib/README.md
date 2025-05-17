# Oberon RTK Modules Library

Versions lib/v1.0, lib/v2.0, lib/2.1

```
+ lib
  + v1.0
    + any: generic, hardware independent
    + board: board-specific, possibly with external components and wiring
      + rp2040: RP2040 boards
        + any: any make based on RP2040
        + pico: Pico/RP2040
    + mcu: MCU-specific
      + m0: Cortex-M0/M0+ mcu
        + rp2040: RP2040
  + v2.0
    + any: generic, hardware independent
    + board: board-specific, possibly with external components and wiring
      + rpi: raspberry pi
        + any: any rpi board
        + pico: Pico/RP2040
        + pico2: Pico2/RP2350
    + mcu: MCU-specific
      + rpi: raspberry pi
        + any: any rpi mcu
        + rp2040: RP2040
        + rp2350: RP2350
  + v2.1: analogous to v2.0
```

[https://oberon-rtk.org/docs/lib/](https://oberon-rtk.org/docs/lib/)
