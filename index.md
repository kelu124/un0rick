---
layout: default
---

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/board/un0desc.png)

# __Nunc Ille Est Magicus__ 

### Introduction

Non destructive testing and imaging ultrasound modalities have been around since the '50s in . More and more ultrasound-based initiative are emerging, mostly focusing on image processing - while hardware has been left behind. Several teams have produced succesful designs for the different possible uses, mostly efforts from research laboratories. Most have been used on commercial US scanners, traditionaly used as experiment platforms, but they are not cheap, and yield very little in terms of data access and control. Others have been developped in labs, but, sadly, very few have been open-sourced. This particular project stems from a previous beaglebone-based design, as well as an arduino-like module-based design. 

It has also been shown that simple (be it low-power, low-cost and small) can be achieved - and this, even for relatively complex systems, based on 16 to 64  parallel   channels   front-end  processing and software back-end processing (embedded PC or DSP). This makes it a bit more complex for the layman, hobbyist, or non-specialist researcher to use, not to mention the very little information that is accessible.

__How about a case study? __

The board was connected to a single element piezo, in water, with a reflector a few centimers away, immersed in water. Pulser is set up at 25V high pulses. Control was done through a Raspberry Pi W.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/IMG_20180224_195210.jpg)

Acquisition is realized, with a small offset, between 32Msps and 64Msps. Data is explored a bit further.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/2018-02-27.jpg)



# __Non Quod Maneat, Sed Quod Adimimus__ 

### Simplified hardware: specs and features


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

# __Si (Non) Confectus, (Non) Reficiat__ 

If it's not broken..

* Ready-made commercial platforms range in the 1000s$ .. and even smallish one-channel boards can be around 2k$. Each has pros and cons (for example a 2k$ board samples at 160Msps but can only store 4k pts). Not open-source.
* Research gigs are not always published. Not open-source.
* Some arduino-like modules were developped. A whole set is around 350$ for AFE+ADC+controls. Open source. DIY quality (acceptable, not for pros). Open source.
* This board has more or less only plusses compared to the competition =)
 

# __Quia Ego Sic Dico__ 

### Installation steps

1. Setup
2. Install the image on the Raspberry 
3. Burn bitstream
4. Acquire the signal
5. Process and display!

# __Moneta Supervacanea, Magister?__

* Send me a mail at __orders@un0rick.cc__ !
* Or wait for the Tindie shop to order.
* First sets around 449$.  Vilis Ad Bis Pretii !

# __Non Ante Septem Dies Proxima, Squiri__

V1 RELEASE !
@todo

# __Liber Paginarum Fulvarum__ 

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
