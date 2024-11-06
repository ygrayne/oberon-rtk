# Oberon RTK

**Oberon RTK is a framework for writing embedded control programs in Oberon for the RP-series of micro-controllers of Raspberry Pi, using Astrobe's cross-compiling IDEs.**

* [RP2040](https://www.raspberrypi.com/documentation/microcontrollers/silicon.html#rp2040): Cortex-M0+, ARMv6-M, Pico 1 board
* [RP2350](https://www.raspberrypi.com/documentation/microcontrollers/silicon.html#rp2350): Cortex-M33, ARMv8-M, Pico 2 board

RTK stands for "real-time kernel", that is, an embedded multi-threading kernel allowing to divide, and program, the controller program as set of separate control processes.

Oberon RTK is designed to run dual-core, multi-threaded programs.

The use of the kernel is not mandatory for the Oberon RTK library/framework in general, which can be used to program any kind of application using one or two cores.

# More Information

Cf. [oberon-rtk.org](https://oberon-rtk.org).
