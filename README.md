Digilent BASYS-3 demo
=====================

This design demonstrates the I/Os of the BASYS-3 FPGA board.

The following I/O devices are included:

* The 16 LEDs replicate the values of the 16 switches. The lower 5 LEDs
  are inverted if any of the 5 push buttons are pushed.

* The seven-segment display shows a timer with a resolution of 0.1 seconds.

* The VGA output shows a test image made up of primary colors at a resolution of 1920x1080.
  This goes quite a bit beyond what (super) VGA is supposed to handle in terms of resolution,
  but on a sufficiently modern monitor of TV it works nicely.

* The PMOD outputs are driven with different frequency square waves:

  - PMOD-A    : 11..18 kHz
  - PMOD-B    : 21..28 kHz
  - PMOD-C    : 31..38 kHz
  - PMOD-XADC : 41..48 kHz

* The UART (connected as a virtual COM port via USB) is configured at 115200 baud, 8 data bits, no parity,
  and 1 stop bit (8N1). Characters are accepted from the UART-RX side, subjected to ROT13 (i.e., all letters
  are shifted by 13 places), and echoed back to the UART-TX side.

The following two I/O devices are not (yet) implemented:

* The QSPI interface that connects to the onboard flash memory chip;

* The PS/2 port that is driven by an on-board microcontroller that accepts a USB keyboard or mouse and mimics a PS/2 keyboard/mouse.
