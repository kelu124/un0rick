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

In the fpga_ctrl folder you can run

`python3 test.py`

which will run a series of acqs. It's the test bench for the python lib matching the usb firmware.

# Example of acquisitons

## Raw signal, with DAC

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201026a/fpga_ctrl/img/3.png)

## Detail of an echo

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201026a/fpga_ctrl/img/4.png)

## Interleaved acquisiton mode = ON

Doublign acquisition speed (yellow and red dots below)

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20201026a/fpga_ctrl/img/6.png)




