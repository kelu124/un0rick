---
layout: default
title: un0rick usb setup
parent: un0rick
nav_order: 4
---

# How to setup the board using only a usb cable

# Beware! If you use this, you just need to have a usb cable plugged in.

Install jumpers and connectors as indicated in the figure below. Jumpers necessary are the white and the green ones. 

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/Abdulrhman/unnamed.jpg)


# Installation 

## Preparing Python

`pip3 install pyftdi matplotlib numpy scipy`

## Installing iceprog to flash the fpga

iceprog is the software used to put the fpga on the flash storage on the board, which will be read by the fpga on boot. The easiest way is to :

`sudo apt install fpga-icestorm`

If this doesn’t work, then this may work:

```
sudo apt-get install libftdi-dev git gcc 
git clone https://github.com/cliffordwolf/icestorm.git
cd iceprog
make 
sudo make install
```

This will create and install the iceprog utility, used to flash the fpga program (bitstream).

## Board specific install files

Download the [install pack](https://github.com/kelu124/un0rick/blob/master/usb/install_pack.zip) or by 

`wget https://github.com/kelu124/un0rick/raw/master/usb/install_pack.zip`

## Connect the usb cable

Check that the FTDI device is well created by typing:

`dmesg`

# Programming it

Unzip it, inside, there's the bin to program the fpga :
 
`iceprog usb.bin`

# Running python

## Test

In the fpga_ctrl folder you can run

`python3 test.py`

which will run a series of acqs. It's the test bench for the python lib matching the usb firmware.

## Using the python lib

### Imports

In the fpga_ctrl folder, you'll need the `csr_map`, `ftdi_dev.py`, and `fpga_ctrl` files, to import the lib:

`from fpga_ctrl import FpgaControl`

I encourage the reader to go inside this libs, which are already documented.

### Create the device

then connect to the FPGA

```python
# init FTDI device
fpga = FpgaControl('ftdi://ftdi:2232:/', spi_freq=8E6)
# reload configuration (optional step - just to fill BRAM (DACGAIN registers) with initial values)
fpga.reload()
# reset fpga
fpga.reset()
```

### Pulser control

To control the waveform, one would set the `fpga.csr.ponw`, `fpga.csr.interw` and `fpga.csr.poffw`, that are respectively integers for setting the width (timing) of the pulse, width of a relaxation period before damping, and then duration of damping. Unit are (1/128us).

The `fpga.csr.initdel` register is the delay between the beginning of the acquisiton and the pulse. 

```
fpga.csr.initdel = InitDel
fpga.csr.ponw = PONWidth
fpga.csr.interw = INTERWidth
fpga.csr.poffw = PDAMP
```

Below is plotted amplitude of an echo as a function of the `fpga.csr.ponw` for a 4MHz transducer. One sees that a setting at `16` provides most

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201031a/amplitude.png)

(See [full experiment here](https://github.com/kelu124/echomods/tree/master/matty/20201031a)).

### Gain and acquisitions

And do acquisitions with `acq_res = fpga.do_acquisition(acq_lines=32, gain=gain, double_rate=True)` which will return an array of `acq_lines` acquisitions, of length 256us at 64Msps.
`double_rate=True` provides a half clock offset to odd lines, so that one can interleave two subsequent acquisition to have, in a fixed setting, a 128Msps acquisition.

The `gain` setting is an array of integers, of length 32, that can range from 0 to 1023, controlling gain for each of the 32 8us-segment of acquisition within the 256us line. 


### Other registers

* `fpga.csr.led3 = 0` sets LED3 off. led1, led2, led3 are possible, can be set to 0 or 1.
* `fpga.csr.topturnX` reads input 1 to 3 on the input header.
* `fpga.csr.jumperX` reads jumper 1 to 3 close to the programming jumper.
* `fpga.csr.outXice` writes/reads output 1 to 3.
* `fpga.csr.nblines = acq_lines - 1` is the register controlling the number of lines acquired.
* `fpga.csr.dacout` reads the DAC/TGC/VGA level outside of acquisitions.
* `fpga.csr.acqstart = 1` to start the acquisition
* `fpga.csr.drmode = int(double_rate)` triggers the interleaving mode.
* `fpga.csr.acqstart = 1` to start the acquisition
* `fpga.csr.acqdone` is equal to 0 during acquisitions.
* `fpga.csr.author` reads the ID of the author of the binary.
* `fpga.csr.version` reads the ID of the author's binary.

# Example of acquisitons

## Raw signal, with DAC

The signal is in blue, the gain levels are in green. Here there are 32 visible steps, of 8us each.
![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201103a/Acq%200.png)

## Detail of an echo

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201026a/fpga_ctrl/img/4.png)

## Interleaved acquisiton mode = ON

Doublign acquisition speed (yellow and red dots below)

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201026a/fpga_ctrl/img/6.png)




