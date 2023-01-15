
Fidget - The FPGA Widget
========================

###### *Started January 5, 2023*

This project is an experiment in making a board using a Lattice iCE40 FPGA in a surface mount
package (LQFP-144).  It will have bus connectors to allow it to be hooked up to one of the
[computie](https://jabberwocky.ca/projects/computie/) single board computers, to be used as either a
debug monitor to replace the arduino, or as a generic expansion device, but also with an eye towards
being repurposed, for example as a generic logic analyzer.

It will need to have bus transceivers to level convert between the 5V signals of the computie
expansion bus, and the 3.3V I/O pins of the FPGA.  To save on I/Os, the address and data bus lines
are multiplexed using the level-converting transceivers.  I may also add the latches necessary to
make a request on the bus, but I might not if it takes too much space (there are 6 x 74LVC16245
transceivers, and the latches would add another 2 x 74LVC16373s for a total of 8 TSSOP-48 chips).
Without the latches, the device will only be able to receive bus requests but not make them.

The basic design of the USB and power supply circuitry was mostly copied from the [TinyFPGA
BX](https://www.crowdsupply.com/tinyfpga/tinyfpga-ax-bx) development board.  I bought one back in
early 2020, and have an environment set up for developing for it.  My hope is to be able to reuse
the bootloader and upload utility from that to accelerate the bring-up of this board.  I highly
recommend checking it out, as it sounds like they will have more boards for sale soon in 2023.  It's
an excellent cheap open source board which is great for experimenting with verilog and FPGAs.


