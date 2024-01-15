# Oberon RTK

Oberon RTK is a project, and framework, to support writing control programs in Oberon for the RP2040 Cortex-M0+ microcontroller using the [Astrobe for Cortex-M0](https://www.astrobe.com) cross-compiling IDE.

RTK stands for "real-time kernel", that is, an embedded multi-threading kernel to allow to divide, and program, the controller program as set of separate control processes.

Note that the use of the kernel is not mandatory for the Oberon RTK library/framework in general, which can be used to program any kind of application, employing one or two cores.

# More Information

There's a nascent, yet incomplete website: [oberon-rtk.org](https://oberon-rtk.org).

# Dependencies and Prerequitites

The RTK modules depend on modules in the Astrobe library. Hence, you need to have a registered copy of Astrobe for Cortex-M0. If you don't, get it. It's good.

The Oberon modules are written using the current version of Astrobe for Cortex-M0, v9.0.3
