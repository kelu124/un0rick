# This project

![](/images/un0desc.png)

Non destructive testing and imaging ultrasound modalities have been around since the '50s in . More and more ultrasound-based initiative are emerging, mostly focusing on image processing - while hardware has been left behind. Several teams have produced succesful designs for the different possible uses, mostly efforts from research laboratories. Most have been used on commercial US scanners, traditionaly used as experiment platforms, but they are not cheap, and yield very little in terms of data access and control. Others have been developped in labs, but, sadly, very few have been open-sourced. Let's tackle this!

## Picture of the setup

The board was connected to a single element piezo, in water, with a reflector a few centimers away, immersed in water. Pulser is set up at 25V high pulses.

![](/images/IMG_20180224_195210.jpg)

Acquisition is realized, with a small offset, between 32Msps and 64Msps. Data is explored a bit further.

![](/images/2018-02-27.jpg)

* [Jupyter notebook of the acquisition](/images/20180227/20180227a-Loops.ipynb)
* [Dataset at 32Msps](/images/20180227/One-0-VGA@0x22-spimode1-32msps.csv)
* [Datast for 64Msps](/images/20180227/One-5-VGA@0x22-spimode1-64msps.csv)

# Sources

* The [source files -- the upverter initial design are here](/source/)
* The [production files are here](/build/)
* The [VHDL files](/software/) - and [corresponding firmware](/software/MATTY.bin)

# External sources

* DATA server
* gitbook for external doc

# Resources

* Read more at [un0rick.cc](http://un0rick.cc), upcoming documentation at [doc.un0rick.cc](http://doc.un0rick.cc)
* On [Hackaday too](https://hackaday.io/project/28375-un0rick-an-ice40-ultrasound-board)

# __Nunc Ille Est Magicus__ -- Introduction

Non destructive testing and imaging ultrasound modalities have been around since the '50s in . More and more ultrasound-based initiative are emerging, mostly focusing on image processing - while hardware has been left behind. Several teams have produced succesful designs for the different possible uses, mostly efforts from research laboratories. Most have been used on commercial US scanners, traditionaly used as experiment platforms, but they are not cheap, and yield very little in terms of data access and control. Others have been developped in labs, but, sadly, very few have been open-sourced. This particular project stems from a previous beaglebone-based design, as well as an arduino-like module-based design. 

It has also been shown that simple (be it low-power, low-cost and small) can be achieved - and this, even for relatively complex systems, based on 16 to 64  parallel   channels   front-end  processing and software back-end processing (embedded PC or DSP). This makes it a bit more complex for the layman, hobbyist, or non-specialist researcher to use, not to mention the very little information that is accessible.

# __Non Quod Maneat, Sed Quod Adimimus__ -- simplified hardware: specs and features


1. __FPGA__: Lattice iCE40HX4K - TQFP 144 Package
2. __Memory__:
  * 8 Mbit SRAM, 10ns, 512 k x 16, equivalent:
      * 65 full lines of 120us at 64Msps
      * 840 lines of 120us at 10Msps, 8 bits
  * 8 Mb SPI Flash for FPGA configuration 
3. __Ultrasound processing__:
  * __VGA__: AD8331 controled by DAC
  * __Pulser__: MD1210 + TC6320
  * __ADC__: 10Msps ADC10065
    * 10 bits of data / sample
    * 2 bits of line counters
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
  * 3 x push button (with software noise debouncing)
  * Jumpers for high voltage selection
7. __Input Voltage__: 
  * 5 V from RPi or USB
  * Uses 350mA-450mA at 5V
8. __Fully Open Source__:
  * Hardware: _github repository_
  * Software: _github repository_
  * Toolchain: _Project IceStorm_
  * Documentation: _gitbook_
9. __Operating Voltage__: 
  * FPGA and logics at at 3.3 V
  * High voltage at 25V, 50V, 75V
10. __Dimensions__: @todo!
11. __Weight__: @todo! 

# __Si (Non) Confectus, (Non) Reficiat__ -- a short comparative

* Ready-made commercial platforms range in the 1000s$ .. and even smallish one-channel boards can be around 2k$. Each has pros and cons (for example a 2k$ board samples at 160Msps but can only store 4k pts). Not open-source.
* Research gigs are not always published. Not open-source.
* Some arduino-like modules were developped. A whole set is around 350$ for AFE+ADC+controls. Open source. DIY quality (acceptable, not for pros). Open source.
* This board has more or less only plusses compared to the competition =)
 

# __Quia Ego Sic Dico__ -- installation steps

1. Setup
2. Install the image on the Raspberry 
3. Burn bitstream
4. Acquire the signal
5. Process and display!

# __Faber Est Quisqve Fortunae Suae__ -- what can you do with this?

A couple of ideas to play with the stuff

* Compressed sensing to be used with [muscle detection]().
* AMode Non destructive testing
* Medical imaging BMode with a probe

# __Moneta Supervacanea, Magister?__ -- shopping time

* Send me a mail at __orders@un0rick.cc__ !
* Or wait for the Tindie shop to order.
* First sets around 349$.  Vilis Ad Bis Pretii !

# __Non Ante Septem Dies Proxima, Squiri__

* V1
  * Update of wrong footprints and connections
* V 0.1 [release](https://github.com/kelu124/un0rick/releases/tag/v0.1) -- Prototyping (project codename: MATTY)
  * [2018-03-10](https://github.com/kelu124/echomods/tree/master/matty/20180310a) - getting the DAC working
  * [2018-02-27](http://un0rick.cc/articles/2018-02/good-news) - first acquisitions at high speed
  * [2018-02-02](http://un0rick.cc/articles/2018-02/first-tests) - Getting the first tests done (and repairs)
  * [2018-01-23](http://un0rick.cc/articles/2018-01/first-board) - Got the first board from the fab
  * [2017-11-19](http://un0rick.cc/articles/2017-11/first-ideas) - Exploring the idea of an ICE40, using Upverter
  * [2017-09-15](http://un0rick.cc/articles/2017-09/uniboard) - First ideal specs on the paper

# __Liber Paginarum Fulvarum__ -- other resources


* The full [GitHub Repo](https://github.com/kelu124/un0rick)
* The guy's [Tindie shop](https://www.tindie.com/stores/kelu124/)
* The corresponding [Hackaday](https://hackaday.io/project/28375-un0rick-an-ice40-ultrasound-board) page
* Join the [Slack channel](https://join.slack.com/usdevkit/shared_invite/MTkxODU5MjU0NjI1LTE0OTY1ODgxMDEtMmYyZTliZDBlZA)

# Thanks to

* BiVi - _always here to chat_
* Charles - _bringing neat insights_
* David - _what would I have done without you?_
* echOmods - _the fundations of this work_
* Fabian - _already so many insights_
* Fouad.. and team - _awesome works there_
* Jan - _piezooos_
* Johannes and Felix - _hardware is .. hard, but rewarding!_
* Marc - _share these echoes =)_
* Murgen - _early elements_
* Sofian - _early ideas!_
* Tindie - _to allow people sharing their niche hardware, and for others to search for these_
* Visa - _exploring amode_
* Vlad - _you pulse_
* .. and all the others !

# License

## echOmods 

The [un0rick project](https://github.com/kelu124/un0rick) and its prototypes are open hardware, and working with open-hardware components.

Licensed under TAPR Open Hardware License (www.tapr.org/OHL)

Copyright Kelu124 (kelu124@gmail.com) 2018

## Based on 

The following work is based on a previous TAPR project, [the echOmods project](https://github.com/kelu124/echomods/) - and respects its TAPR license.

Copyright Kelu124 (kelu124@gmail.com) 2015-2018

## Disclaimer

This project is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. 

