---
layout: default
title: un0rick RPi setup
parent: un0rick
nav_order: 3
---

# How to setup the board using only a RaspberryPi (here with RPi 4)

## Putting the board together

Need a few feet to raise the board a bit above the ground, two 2x20 headers, and a SMA.

### Board in a bag

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_150726.jpg)

### What do we need ?

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_151518_good.jpg)

### Assembled !

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_163216_good.jpg)

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_163247_good.jpg)

# Software side

## Updating the raspberry tools

You may need to install new packages, especially to communicate with the fpga.

``` 
sudo apt-get update
sudo apt-get install i2c-tools libasound2-dev python3-numpy python-numpy
sudo apt-get install python-dev libatlas-base-dev
```

From a general perspective, it may be worth trying to keep your tools up to date with:

```
sudo apt-get upgrade
```

If you face SPI / GPIOs issues, and that you are using a RPi4, you may want to follow [these hints](http://wiringpi.com/wiringpi-updated-to-2-52-for-the-raspberry-pi-4b/) to update WiringPi. In short:

```
cd /tmp
wget https://project-downloads.drogon.net/wiringpi-latest.deb
sudo dpkg -i wiringpi-latest.deb
gpio -v
```

to check you're using v2.52 or above.

## Updating the python tools

On the raspberry pi, use pip to install the following modules:

```
pip3 install smbus2 RPi.GPIO PyAudio matplotlib numpy scipy spidev
```

## Installing iceprog to flash the fpga

iceprog is the software used to put the fpga on the flash storage on the board, which will be read by the fpga on boot. The easiest way is to :

```
sudo apt install fpga-icestorm
```

If this doesn't work, then this may work:

```
sudo apt-get install libftdi-dev git gcc 
git clone https://github.com/cliffordwolf/icestorm.git
cd iceprog
make 
sudo make install
```

This will create and install the iceprog utility, used to flash the fpga program (bitstream).

Prepare the jumper here :

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/program.jpg)

Then, plug an usb cable from the RPi to the board (not connected using the raspberry pi header).

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/P_20191123_144920.jpg)

Check that the FTDI device is well created by typing:

```
dmesg
```

and then flash the FPGA by doing:

```
wget https://github.com/kelu124/un0rick/raw/master/bins/v1.1.bin
iceprog v1.1.bin
```

This should flash the board:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/v1.01/iceprog.png)

If you do not have a success here, you may want to have a look at how to connect FTDI devices to your computer (see for example: https://stackoverflow.com/questions/36633819/iceprog-cant-find-ice-ftdi-usb-device-linux-permission-issue ). Usually, one has no issues with RPi fresh out of the box.

## Physical setup / connections for the lib acquisitions

### Pinouts

#### Raspberry Pi header

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_rpi_header.png)

#### FTDI breakout

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_ftdi.png)

### Setup

You can use a RPi4 with a ribbon cable to connect to the board, leaving the jumper on, putting one to select the high voltage level, connecting a piezo.. and that's it.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/P_20191123_161358.jpg)

## Running an acquisition

### Testing the connection to the board

Then, for example to discover the board using Python, you can use the library:

```
git clone https://github.com/kelu124/pyUn0-lib.git
cd pyUn0-lib
python pyUn0.py test
```

It will download the lib, then you should see with the 'test' option a LED blink

### Testing the connection to the board

The "single" option will allow you to capture a single line, then the "process" one will create the corresponding images.

```
python pyUn0.py single
python pyUn0.py process
```

## Results

I've used this exact setup to [get the lib](https://github.com/kelu124/pyUn0-lib) examples ( https://github.com/kelu124/pyUn0-lib ).
* [Raw files are here](https://github.com/kelu124/pyUn0-lib/tree/master/data)
* [Images here](https://github.com/kelu124/pyUn0-lib/tree/master/images)`


Example of an acq : 

![](https://raw.githubusercontent.com/kelu124/pyUn0-lib/master/images/20201009a-2.png)

with a clean spectrum: 

![](https://raw.githubusercontent.com/kelu124/pyUn0-lib/master/images/20201009a-2-fft.png)
