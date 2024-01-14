# Oberon RTK

Oberon RTK is a project, and framework, to support writing control programs in Oberon for the RP2040 Cortex-M0+ microcontroller using the Astrobe for Cortex-M0 cross-compiling IDE.

RTK stands for “real-time kernel”, that is, an embedded multi-threading kernel to allow to divide, and program, the controller program as set of separate control processes. A control process is the dynamic building blocks of a control program, much like Oberon modules are static building blocks regarding program structure. Oberon modules provide an ideal conceptual and implementation substrate to realise processes.

While the kernel is of special interest considering the two cores available with the RP2040, its use is not mandatory for the Oberon RTK library/framework in general, which can be used to program any kind of application, employing one or two cores.

# More Information
[oberon-rtk.org](https://oberon-rtk.org)

# Directory Structure

* README (this file)
* lib
  * any
  * mcu
    * m0
      * rp2040
  * board
    * m0
      * pico
* examples
  * pico
