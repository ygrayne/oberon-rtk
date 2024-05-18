# Oberon RTK

Oberon RTK is a framework to support writing embedded control programs in Oberon for the RP2040 Cortex-M0+ microcontroller using the [Astrobe for Cortex-M0](https://www.astrobe.com) cross-compiling IDE.

RTK stands for "real-time kernel", that is, an embedded multi-threading kernel to allow to divide, and program, the control program as set of separate control processes.

Note that the use of the kernel is not mandatory for the Oberon RTK library/framework in general, which can be used to program any kind of application, employing one or both cores.

# More Information

Cf. [oberon-rtk.org](https://oberon-rtk.org).

# Dependencies and Prerequitites

The RTK modules depend on a few modules in the Astrobe library. Hence, you need to have a registered copy of Astrobe for Cortex-M0.

The Oberon modules are written using Astrobe for Cortex-M0. The current baseline is version 9.1, corresponding to the available free Personal Edition.
