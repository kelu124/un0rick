---
layout: default
title: un0rick m5stack 
parent: un0rick
nav_order: 6
---

# Testing the un0rick board with a M5Stack

## What is the M5Stack ?

That's an ESP32, with a screen of 320x240.

For a 120us  acquisition, that leaves 3us per pixel.. Still interesting to see. Moreover, there seems to be a 512KB RAM, would be enough to store long acquisitions. One line is 256kB at 64Msps.

Even a [FFT processing](https://github.com/ElectroMagus/M5-FFT) would be possible.

Connectors necessary were :

* 5V
* GND
* CS
* MISO
* MOSI

## Actual connections:

```
* M5STACK pin22 -> RPi header GPIO 23 (Ice40 reset)
* M5STACK pin21 -> RPi header GPIO 8 (Ice40 CS)
* M5STACK pin19 -> RPi header GPIO 10 (Rpi MISO)
* M5STACK pin23 -> RPi header GPIO 9 (Rpi MOSI)
* M5STACK pin18 -> RPi header GPIO 11 (Rpi  CLK)
* M5STACK GND to RaspberryPi header GND pin
* M5STACK 5V ->  RaspberryPi header 5V pin
```

## Some code

Only SPI libs and M5Stack were necessary.. and a proof of concept was done with a single line acquisition process, for 200us, with a low gain.

* [Arduino file source is available](https://github.com/kelu124/echomods/blob/4923d2af498ee07439468cc0e1ba58e79040f0c0/matty/m5stack/SPI.ino)
* [Using the standard v1.1 firmware](https://github.com/kelu124/un0rick/raw/master/bins/v1.1.bin), as detailed [previously](rpi-setup.md).

## Results

### With the calibration rig

![](https://github.com/kelu124/echomods/raw/master/matty/m5stack/calibration.gif)

### With a piezo in a mug

![](https://github.com/kelu124/echomods/raw/master/matty/m5stack/mug.gif)

### Not so bad eh!
