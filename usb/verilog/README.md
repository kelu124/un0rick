# Gateware for un0rick board

Implements FTDI FT2232 SPI control interface for acquisitions performing.

## Compiled binaries

Ready to use binaries are in the ```bin``` directory.

To program FPGA simply run:

```bash
iceprog xxx.bin
```

where xxx - is a basename of a binary file.

## Sources

### src/beh

Directory with behavioral models used in simulation: interface and memory emulators and etc.

### src/rtl

Directory with actual source code to be synthesised.

### src/tb

Directory with testbenches.

## Simulation

### Modelsim

* Go to the ```sim/modelsim``` directory
* Run in a terminal ```./run_sim tb_xxx```, where tb_xxx is the name of the testbench (e.g. ```./run_sim tb_demo```).

### Icarus + GTKWave

* Go to the ```sim/icarus``` directory
* Run in a terminal ```./run_sim tb_xxx```, where tb_xxx is the name of the testbench (e.g. ```./run_sim -do tb_demo```).

## Implementation

### iCECube2

* Open ```.project``` project in the ```impl/icecube2``` directory
* Use GUI for synthesis, map and place and route

### Icestrom (yosys + nextpnr)

* Go to the ```impl/icestorm``` directory
* Run in a terminal ```./run_impl```. Synthesis, place and route and static timing analysis will be executed.

## Utilities

### util/csr_map

Tool to generate some code and other artifacts from CSR map YAML file.
More information you can find inside the file ```util/csr_map/gen_csr.py```.

### util/pll

Simple script to run icepll tool to obtain coefficients for the frequency needed.

### util/fpga_ctrl

Python library to access FPGA via FTDI FT2232 chip. More information about internal structure is in ```util/fpga_ctrl/README.md```.

### util/dump_to_imp

Tool to generate BMP images from frame dumps (HDL simulation artifacts).

### util/vga_layout

Tool to generate some code and other artifacts special for VGA display implementation.
