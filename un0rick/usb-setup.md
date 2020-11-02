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

Download the [install pack](https://github.com/kelu124/un0rick/blob/master/usb/install_pack.zip) or by 

`wget https://github.com/kelu124/un0rick/raw/master/usb/install_pack.zip`

# Programming it

Unzip it, inside, there's the bin to program the fpga :
 
`iceprog usb.bin`

# Running python

In the fpga_ctrl folder you can run

`python3 test.py`

which will run a series of acqs. It's the test bench for the python lib matching the usb firmware.


