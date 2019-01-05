---
layout: default
---

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/board/un0desc.png)

# FOSS ultrasound

Non destructive testing and imaging ultrasound have been around since the '50s. Many ultrasound open-source projects are emerging, mostly focusing on image processing - while hardware has been left behind. Several teams have produced succesful designs to be used on commercial US scanners, but they are not cheap, and are difficult to access.

I couldn't find designs to play with, that would be affordable or open, so I decided to make one for makers, researchers and hackers.

# What is inside ?

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/block-diagram.png)

## Step-by-step

1. Program the fpga using a open-source toolchain
2. Control the board fully through SPI, be it through USB, a Raspberry Pi, or even an arduino.
3. Set up the acquisition sequence through SPI (for example using this python lib for Raspberry Pi)
4. Get the data back again through SPI, and process it.

I recommend using RPi, particularly W for the wireless aspects, which then becomes the board server. There's a dedicated 20x2 header. Prepared are image for the [RPi W](https://doc.un0rick.cc/installation.html), a [python lib](https://github.com/kelu124/un0rick/tree/master/pyUn0) as well.

Also tested with a nice [m5stack board](https://doc.un0rick.cc/m5stack.html) ([ino file](https://github.com/kelu124/echomods/blob/4923d2af498ee07439468cc0e1ba58e79040f0c0/matty/m5stack/SPI.ino)).

## Stable binaries

* Single SMA: [v1.01](https://github.com/kelu124/un0rick/raw/master/bins/v1.01.bin)
* Two SMAs, large board: [v1.1](https://github.com/kelu124/un0rick/raw/master/bins/v1.1.bin)

## An example

The board was connected to a single element piezo, in water, with a reflector a few centimers away, immersed in water. Pulser is set up at 25V high pulses. Control was done through a Raspberry Pi W which is used as a .

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/IMG_20180224_195210.jpg)

Acquisition is realized, with a small offset, between 32Msps and 64Msps. Data is explored a bit further.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/2018-02-27.jpg)

## Up to 128msps ?

Playing with the trigger, it's possible to [interleave two signals](https://github.com/kelu124/echomods/blob/master/matty/20180814a/20180814a-Server.ipynb) and artificially double to acquisition speed, yielding clean images:

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/128msps.png)

# Specs (un0v1.1)

1. __FPGA__: Lattice iCE40HX4K - TQFP 144 Package
2. __Memory__:
  * 8 Mbit SRAM, 10ns, 512 k x 16, equivalent:
      * 65 full lines of 120us at 64Msps
      * 840 lines of 120us at 10Msps, 8 bits
  * 8 Mb SPI Flash for FPGA configuration 
3. __Ultrasound processing__:
  * __VGA__: AD8331 controled by DAC
  * __Pulser__: MD1210 + TC6320
  * __ADC__: 65Msps ADC10065
    * 10 bits of data / sample
    * 2 bits of line trackers
    * 4 bits of IOs (counters, ...) 
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
8. __Fully Open Source__:
  * Hardware: [github repository](https://github.com/kelu124/un0rick)
  * Software: [github repository](https://github.com/kelu124/un0rick)
  * Toolchain: [Project IceStorm](http://www.clifford.at/icestorm/)
  * Documentation: [gitbook](https://doc.un0rick.cc/)
9. __Operating Voltage__: 
  * FPGA and logics at at 3.3 V
  * High voltage at 25V, 50V, 75V

# Orders

* First sets around 449$.  Vilis Ad Bis Pretii !
  * Send me a mail at __orders@un0rick.cc__ !
  * Or wait for the [Tindie shop]((https://www.tindie.com/stores/kelu124/)

# Changelog

* lit3rick _v1.2 - Ongoing_ 
  * lighter board
  * external HV modules
* un0rick dual _v1.2 - Ongoing_ 
  * Better HV generation
  * SPI muxing to update
  * Check USB too
  * PMOD-compliant headers
  * remove i2c header, but keep i2c to RPI (with PU)
* un0Rick dual - __v1.1__
  * Double SMA to possibly separate TX and RX path (for dual elements transducers)
  * Still some issues with muxing
* un0Rick - __v1.01__
  * Rewired SPI
  * Less MUXing
* The "matty board" __v1__ 
  * First ice40 board - compatible with iceprog =)
  * Only one in existence, had some SPI wiring issues
  * HV module footprint reversed

# Useful links

* __Come and chat__ : join the [Slack channel](https://join.slack.com/usdevkit/shared_invite/MTkxODU5MjU0NjI1LTE0OTY1ODgxMDEtMmYyZTliZDBlZA)
* The full [GitHub Repo](https://github.com/kelu124/un0rick)
* The board's [Tindie shop](https://www.tindie.com/stores/kelu124/)
* The project [Hackaday](https://hackaday.io/project/28375-un0rick-an-ice40-ultrasound-board) page
* wlmeng11's [SimpleRick](https://github.com/wlmeng11/SimpleRick) for a analog part board. Clever use of [RTL-sdr hardware](https://github.com/wlmeng11/rtl-ultrasound) for the acquisition !
* A [messy braindump](https://github.com/kelu124/echomods/) with all experiments, and a slightly [cleaner documentation](https://kelu124.gitbooks.io/echomods/content/) of my earlier works.

# Thanks & shouts

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
* all the supportive users
* .. and all the others !

# Where are we ?

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/map.jpg)
