# This file is a general .xdc for the Basys3 rev B board
# To use it in a project:
# - uncomment the lines corresponding to used pins
# - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

# Clock signal (100 MHz)
set_property  -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports XTAL_CLK]

create_clock -add -name sys_clk_pin -period 10.00 [get_ports XTAL_CLK]

# Switches (0: down; 1: up)
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[0]}]
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[1]}]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[2]}]
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[3]}]
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[4]}]
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[5]}]
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[6]}]
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[7]}]
set_property -dict { PACKAGE_PIN V2  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[8]}]
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[9]}]
set_property -dict { PACKAGE_PIN T2  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[10]}]
set_property -dict { PACKAGE_PIN R3  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[11]}]
set_property -dict { PACKAGE_PIN W2  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[12]}]
set_property -dict { PACKAGE_PIN U1  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[13]}]
set_property -dict { PACKAGE_PIN T1  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[14]}]
set_property -dict { PACKAGE_PIN R2  IOSTANDARD LVCMOS33 } [get_ports {SW_ASYNC[15]}]

# LEDs (0: off; 1: on)
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {LED[0]}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {LED[1]}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {LED[2]}]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {LED[3]}]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {LED[4]}]
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {LED[5]}]
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {LED[6]}]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {LED[7]}]
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {LED[8]}]
set_property -dict { PACKAGE_PIN V3  IOSTANDARD LVCMOS33 } [get_ports {LED[9]}]
set_property -dict { PACKAGE_PIN W3  IOSTANDARD LVCMOS33 } [get_ports {LED[10]}]
set_property -dict { PACKAGE_PIN U3  IOSTANDARD LVCMOS33 } [get_ports {LED[11]}]
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports {LED[12]}]
set_property -dict { PACKAGE_PIN N3  IOSTANDARD LVCMOS33 } [get_ports {LED[13]}]
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports {LED[14]}]
set_property -dict { PACKAGE_PIN L1  IOSTANDARD LVCMOS33 } [get_ports {LED[15]}]

# Seven-segment display.
#   Segments: 0=segment enabled, 1=segment disabled
#   Anodes: 0=digit enabled, 1=digit disabled.
set_property -dict { PACKAGE_PIN W7  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[0]}]
set_property -dict { PACKAGE_PIN W6  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[1]}]
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[2]}]
set_property -dict { PACKAGE_PIN V8  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[3]}]
set_property -dict { PACKAGE_PIN U5  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[4]}]
set_property -dict { PACKAGE_PIN V5  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[5]}]
set_property -dict { PACKAGE_PIN U7  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[6]}]
set_property -dict { PACKAGE_PIN V7  IOSTANDARD LVCMOS33 } [get_ports {SSEG_SEGMENT[7]}]; # The decimal point following the digit.

set_property -dict { PACKAGE_PIN U2  IOSTANDARD LVCMOS33 } [get_ports {SSEG_ANODE[0]}]
set_property -dict { PACKAGE_PIN U4  IOSTANDARD LVCMOS33 } [get_ports {SSEG_ANODE[1]}]
set_property -dict { PACKAGE_PIN V4  IOSTANDARD LVCMOS33 } [get_ports {SSEG_ANODE[2]}]
set_property -dict { PACKAGE_PIN W4  IOSTANDARD LVCMOS33 } [get_ports {SSEG_ANODE[3]}]

# Buttons (0: not pushed; 1: pushed)
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports BTN_C_ASYNC]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports BTN_U_ASYNC]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports BTN_L_ASYNC]
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports BTN_R_ASYNC]
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports BTN_D_ASYNC]

# PMOD header JA
set_property -dict { PACKAGE_PIN J1  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p1]
set_property -dict { PACKAGE_PIN L2  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p2]
set_property -dict { PACKAGE_PIN J2  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p3]
set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p4]
set_property -dict { PACKAGE_PIN H1  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p7]
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p8]
set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p9]
set_property -dict { PACKAGE_PIN G3  IOSTANDARD LVCMOS33 } [get_ports PMOD_A_p10]

# PMOD header JB
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p1]
set_property -dict { PACKAGE_PIN A16 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p2]
set_property -dict { PACKAGE_PIN B15 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p3]
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p4]
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p7]
set_property -dict { PACKAGE_PIN A17 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p8]
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p9]
set_property -dict { PACKAGE_PIN C16 IOSTANDARD LVCMOS33 } [get_ports PMOD_B_p10]

# PMOD header JC
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p1]
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p2]
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p3]
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p4]
set_property -dict { PACKAGE_PIN L17 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p7]
set_property -dict { PACKAGE_PIN M19 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p8]
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p9]
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports PMOD_C_p10]

# PMOD header JXADC
# These can be used either as regular digital I/Os, or as inputs to the on-chip XADC.
# Note that these have some filtering circuitry to optimize for XADC usage that affects the performance
# when used as digital I/Os. Check the schematics for more info. 
set_property -dict { PACKAGE_PIN J3  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p1]
set_property -dict { PACKAGE_PIN L3  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p2]
set_property -dict { PACKAGE_PIN M2  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p3]
set_property -dict { PACKAGE_PIN N2  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p4]
set_property -dict { PACKAGE_PIN K3  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p7]
set_property -dict { PACKAGE_PIN M3  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p8]
set_property -dict { PACKAGE_PIN M1  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p9]
set_property -dict { PACKAGE_PIN N1  IOSTANDARD LVCMOS33 } [get_ports PMOD_X_p10]

# VGA Connector
set_property -dict { PACKAGE_PIN G19 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[0]}]
set_property -dict { PACKAGE_PIN H19 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[1]}]
set_property -dict { PACKAGE_PIN J19 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[2]}]
set_property -dict { PACKAGE_PIN N19 IOSTANDARD LVCMOS33 } [get_ports {VGA_R[3]}]
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[0]}]
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[1]}]
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[2]}]
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports {VGA_G[3]}]
set_property -dict { PACKAGE_PIN N18 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[0]}]
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[1]}]
set_property -dict { PACKAGE_PIN K18 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[2]}]
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports {VGA_B[3]}]
set_property -dict { PACKAGE_PIN P19 IOSTANDARD LVCMOS33 } [get_ports {VGA_HSYNC}]
set_property -dict { PACKAGE_PIN R19 IOSTANDARD LVCMOS33 } [get_ports {VGA_VSYNC}]

# USB-RS232 Interface
set_property -dict { PACKAGE_PIN B18 IOSTANDARD LVCMOS33 } [get_ports UART_RX_ASYNC]
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports UART_TX]

# USB HID (PS/2)
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 PULLUP true } [get_ports PS2_CLK]
set_property -dict { PACKAGE_PIN B17 IOSTANDARD LVCMOS33 PULLUP true } [get_ports PS2_DATA]

# Quad SPI Flash
# Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the STARTUPE2 primitive.
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports {QSPI_DATA[0]}]
set_property -dict { PACKAGE_PIN D19 IOSTANDARD LVCMOS33 } [get_ports {QSPI_DATA[1]}]
set_property -dict { PACKAGE_PIN G18 IOSTANDARD LVCMOS33 } [get_ports {QSPI_DATA[2]}]
set_property -dict { PACKAGE_PIN F18 IOSTANDARD LVCMOS33 } [get_ports {QSPI_DATA[3]}]
set_property -dict { PACKAGE_PIN K19 IOSTANDARD LVCMOS33 } [get_ports QSPI_CSn]
