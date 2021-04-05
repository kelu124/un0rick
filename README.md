![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_black.png)


# un0rick

## Overview

This is a relatively simple single-channel ultrasound board. Block diagram below:

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/block-diagram.png)

## Step-by-step

1. Program the fpga using a open-source toolchain to synthetise the embedded firmware.
2. Control the board fully through SPI, be it [through USB](http://un0rick.cc/un0rick/usb-setup), a [Raspberry Pi](http://un0rick.cc/un0rick/rpi-setup), or even an [arduino](http://un0rick.cc/un0rick/m5stack) (though a cheap one may not have sufficient resources to do what you want do to).
3. Set up the acquisition sequence 
4. Get the data back again 
5. Process / visualize the acquistion

I recommend using RPi, particularly W for the wireless aspects, which then becomes the board server. There's a dedicated 20x2 header. Prepared is a [python lib](https://github.com/kelu124/un0rick/tree/master/pyUn0) as well. The v1.0.0 version is RPi4 proofed.

## Two control options: usb or raspberry

* [Tutorial : Controlling it with a GPIO ribbon](http://un0rick.cc/un0rick/rpi-setup)
* [Tutorial : Controlling it with usb](http://un0rick.cc/un0rick/usb-setup)

## Examples 

* __With a Raspberry pi__

The board was connected to a single element piezo, in water, with a reflector a few centimers away, immersed in water. Pulser is set up at 25V high pulses. Control was done through a Raspberry Pi W which is used as a controler and server, another Rasbperry pi.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190713/P_20190713_223932.jpg)

Acquisition is realized, with a small offset, between 32Msps and 64Msps. Data is explored a bit further.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/P_20201009_194611.jpg)

* __With a M5Stack (or any microcontroller really)__

The board was also tested with a nice [m5stack board](http://un0rick.cc/UseCase/m5stack) ([ino file](https://github.com/kelu124/echomods/blob/4923d2af498ee07439468cc0e1ba58e79040f0c0/matty/m5stack/SPI.ino)). Below an example in image:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/m5stack/calibration.gif)


## Specs (un0v1.1)

1. __FPGA__: Lattice iCE40HX4K - TQFP 144 Package
2. __Memory__:
  * 8 Mbit SRAM, 10ns, 512 k x 16, equivalent to 65 full lines of 120us at 64Msps or 840 lines of 120us at 10Msps, 8 bits.
  * 8 Mb SPI Flash for FPGA configuration 
3. __Ultrasound processing__:
  * __VGA__: AD8331 controled by DAC
  * __Pulser__: MD1210 + TC6320
  * __ADC__: 65Msps ADC10065
  * __Data__ formatted over 2 bytes, with 10 bits / sample, 2 bits of line trackers, 4 bits of IOs (counters, ...)  and 2 bits for tracking.
4. __Parameters__: Settings programable via USB or Raspberry Pi 
  * Type of acquisition (one line / set of lines)
  * Number of lines
  * Length of lines acquisitions
  * Delay between acquisitions
  * Pulse width 
  * Delay between pulse and beginning of acquisitions
  * 200us time-gain-compensation programmable (8 bits, from 0 to Max), every 5us
5. __Extensibility__:
  * 2 x Pmod connectors
  * SMA plug for transducers
  * RPi GPIO
6. __User Interfaces__:
  * 2 x PMOD for IOs
  * 4 x push button (with software noise debouncing)
  * Jumpers for high voltage selection
  * Jumpers for SPI selection
7. __Input Voltage__: 
  * 5 V from RPi or USB
  * Uses 350mA-450mA at 5V (including RPi)
8. __Operating Voltage__: 
  * FPGA and logics at at 3.3 V
  * High voltage at 25V, 50V, 75V
9. __Fully Open Source__:
  * Hardware: [github repository](https://github.com/kelu124/un0rick)
  * Software: [github repository](https://github.com/kelu124/un0rick)
  * Toolchain: [Project IceStorm](http://www.clifford.at/icestorm/)
  * Documentation: [gitbook](https://doc.un0rick.cc/)

## Latest sources

* Hardware resources are on github:
  * [FPGA bin](https://github.com/kelu124/un0rick/tree/master/software) so far using Lattice's tools. A icestorm port is coming.
  * Files for [v1.1](https://github.com/kelu124/un0rick/tree/master/hardware/v1.1) and [v1.01](https://github.com/kelu124/un0rick/tree/master/hardware) are available - on [upverter too](https://tools.upverter.com/eda/#tool=schematic,designId=c59550d3e0dcf944).
* FPGA files too:
  * Single SMA: [v1.01](https://github.com/kelu124/un0rick/raw/master/bins/v1.01.bin)
  * Two SMAs, large board: [v1.1](https://github.com/kelu124/un0rick/raw/master/bins/v1.1.bin)
* [Python lib too](https://github.com/kelu124/un0rick/blob/master/pyUn0/pyUn0.py)

## Orders

* The [board is available on Tindie](https://www.tindie.com/products/kelu124/un0rick-open-ice40-ultrasound-imaging-dev-board/) at around 489$.
  * Send me a mail at __orders@un0rick.cc__ !
  * Or wait for the [Tindie shop](https://www.tindie.com/stores/kelu124/)

# Others


## Changelog

* lit3rick v1.4
  * Using AD8332 for more gain
  * ADC: 12bits -> 10bits
* [lit3rick](http://un0rick.cc/lit3rick) __v1.3__
  * lighter board
  * 12bits ADC
  * up5k based
  * external HV modules
* un0rick dual _v1.2 - to be done 
  * Better HV generation
  * SPI muxing to update
  * Check USB too
  * PMOD-compliant headers
  * remove i2c header, but keep i2c to RPI (with PU)
* un0rick dual - __v1.1__
  * Double SMA to possibly separate TX and RX path (for dual elements transducers)
  * Still some issues with muxing
* un0rick - __v1.01__
  * Rewired SPI
  * Less MUXing
* The "matty board" __v1__ 
  * First ice40 board - compatible with iceprog =)
  * Only one in existence, had some SPI wiring issues
  * HV module footprint reversed

## Tip: reaching 128msps

Playing with the trigger, it's possible to [interleave two signals](https://github.com/kelu124/echomods/blob/master/matty/20180814a/20180814a-Server.ipynb) and artificially double to acquisition speed, yielding clean images.

[Source experiment](https://github.com/kelu124/echomods/tree/master/matty/20180814a)

### Overview 

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180814a/128Msps_20180813a-9-detail.jpg)

### In detail 

It seems that the different series interleave quite nicely, even in the detail.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180814a/128Msps_20180813a-9-fft.jpg)

## Useful links

* __Come and chat__ : join the [Slack channel](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow)
* The full [GitHub Repo](https://github.com/kelu124/un0rick) for the hx8k board.
  * [Hardware files](https://github.com/kelu124/un0rick/tree/master/hardware)
  * [Verilog for usb control](https://github.com/kelu124/un0rick/tree/master/usb) - with the [corresponding python module](https://pypi.org/project/un0usb/)
  * [A version of the lib](https://github.com/kelu124/un0rick/tree/master/pyUn0) - with the [corresponding python module](https://github.com/kelu124/pyUn0-lib)
* The board's [Tindie shop](https://www.tindie.com/stores/kelu124/)
* The project [Hackaday](https://hackaday.io/project/28375-un0rick-an-ice40-ultrasound-board) page
* A [messy braindump](https://github.com/kelu124/echomods/) with all experiments, and a slightly [cleaner documentation](https://kelu124.gitbooks.io/echomods/content/) of earlier works.
* un0rick boards are open-source certified on [OSHWA, FR000005](https://certification.oshwa.org/list.html?q=un0rick). lit3rick's certification is done on [OSHWA, FR000006](https://certification.oshwa.org/list.html?q=lit3rick).
* wlmeng11's [SimpleRick](https://github.com/wlmeng11/SimpleRick) for a analog part board. Clever use of [RTL-sdr hardware](https://github.com/wlmeng11/rtl-ultrasound) for the acquisition !

## Pinouts

### Raspberry Pi header

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_rpi_header.png)

### FTDI breakout

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_ftdi.png)

## Thanks & shouts

* BiVi - _always here to chat_
* Charles - _bringing neat insights_
* David - _what would I have done without you?_
* echOmods - _the fundations of this work_
* Fabian - _already so many insights_
* Fouad.. and team - _awesome works there_
* Jan - _piezooos_
* Johannes and Felix - _hardware is .. hard, but rew-harding!_
* Sofian - _early ideas!_
* Sterling - _another geek_
* Tindie - _to allow people sharing their niche hardware, and for others to search for these_
* Visa - _exploring amode_
* Vlad - _you pulse_
* Wlmeng11 - _inspiring_
* All the supportive users
* .. and all the others around the world!

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/map.jpg)


## License

This work is based on a previous TAPR project, [the echOmods project](https://github.com/kelu124/echomods/). The [un0rick project](https://github.com/kelu124/un0rick) and its boards are open hardware and software, developped with open-source elements.

Copyright Kelu124 (kelu124@gmail.com) 2018 

* The hardware is licensed under TAPR Open Hardware License (www.tapr.org/OHL)
* The software components are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
* The documentation is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).


## Disclaimer(s)

This project is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. Also:
* This is not a medical ultrasound scanner! It's a development kit that can be used for pedagogical and academic purposes - possible immediate use as a non-destructive testing (NDT) tool, for example in metallurgical crack analysis. 
* As in all electronics, be careful, especially.
* This is a learning by doing project, I never did something related -> It's all but a finalized product.
* Ultrasound raises questions. In case you build a scanner, use caution and good sense!


