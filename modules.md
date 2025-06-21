---
layout: default
title: Modules
parent: Older designs
nav_order: 30
has_children: true
---


# **BEWARE: This project has been deprecated since the arrival of the [un0rick project](un0rick) in 2018**


![GitHub repo size](https://img.shields.io/github/repo-size/kelu124/echomods?style=plastic)
![GitHub language count](https://img.shields.io/github/languages/count/kelu124/echomods?style=plastic)
![GitHub top language](https://img.shields.io/github/languages/top/kelu124/echomods?style=plastic)
![GitHub last commit](https://img.shields.io/github/last-commit/kelu124/echomods?color=red&style=plastic)

[![Patreon](https://img.shields.io/badge/patreon-donate-orange.svg)](https://www.patreon.com/kelu124) 
[![Kofi](https://badgen.net/badge/icon/kofi?icon=kofi&label)](https://ko-fi.com/G2G81MT0G)

[![Slack](https://badgen.net/badge/icon/slack?icon=slack&label)](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow)
[![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org)

# Modules

## What are the arduino-like ultrasound module ?

__Creating modules to facilitate ultrasound hacking__ : the principles of the echOmods is to enable a full chain of ultrasound image processing and hardware control.

We have chosen to use a module approach to make sure that each key component inside ultrasound image processing can easily be replaced and compared with another module, while providing logical _logic blocks_ and corresponding interfaces for these modules to communicate. There's a module for [high-voltage pulsing](https://github.com/kelu124/echomods/blob/master/retired/tobo/), one for the [transducer](https://github.com/kelu124/echomods/blob/master/retroATL3/), one for the [analog processing](https://github.com/kelu124/echomods/blob/master/goblin/), one for [data acquisiton](https://github.com/kelu124/echomods/blob/master/retired/toadkiller/), ... and many more!

## What images does it give ?

![](https://github.com/kelu124/echomods/raw/master/elmo/data/arduinoffset/LineImageEnveloppe.jpg)

## What does it look like?

The modules sit on a breadboard, and communicate through the tracks laying below. The configuration represented below show the Basic dev kit.

![](https://github.com/kelu124/echomods/raw/master/doj/images/doj_v2_notes.jpg)

and used in a wider context:

![](https://github.com/kelu124/echomods/raw/master/elmo/data/arduino/setup.png)

# A recap of the modules


| ThumbnailImage                                                                                                          | Name                                                                                                                                                                                                                                                                                | In                                                                                                                                                                              | Out                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/goblin/viewme.png' align='center' width='150'>      | **[goblin](https://github.com/kelu124/echomods/blob/master/goblin/Readme.md)**: The aim of this echOmod is to get the signal coming back from a transducer, and to deliver the signal, analogically processed, with all steps accessible to hackers.                                | <ul><li>ITF-1_GND</li></ul><li>ITF-2_VDD_5V</li></ul><li>ITF-7_GAIN</li></ul><li>ITF-4_RawSig</li></ul><li>ITF-3_ENV</li></ul><li>ITF-18_Raw</li></ul><li>ITF-mET_SMA</li></ul> | <ul><li>ITF-4_RawSig</li></ul><li>ITF-3_ENV_signal_envelope</li></ul><li>ITF-mEG_SPI</li></ul> |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/wirephantom/viewme.png' align='center' width='150'> | **[wirephantom](https://github.com/kelu124/echomods/blob/master/wirephantom/Readme.md)**: Just a phantom for calibrated signals                                                                                                                                                     | <ul><li>na</li></ul>                                                                                                                                                            | <ul><li>na</li></ul>                                                                           |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/lite.tbo/viewme.png' align='center' width='150'>    | **[lite.tbo](https://github.com/kelu124/echomods/blob/master/lite.tbo/Readme.md)**: The aim of this echOmod is to get the HV Pulse done.                                                                                                                                            | <ul><li>ITF-1_GND</li></ul><li>ITF-2_VDD_5V</li></ul><li>ITF-9_Pon</li></ul><li>ITF-10_Poff</li></ul><li>ITF-19_3.3V</li></ul><li>ITF-mET_Transducer</li></ul>                  | <ul><li>ITF-18_Raw</li></ul><li>ITF-mET_SMA</li></ul><li>ITF-mET_Transducer</li></ul>          |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/silent/viewme.png' align='center' width='150'>      | **[silent](https://github.com/kelu124/echomods/blob/master/silent/Readme.md)**: The aim of this echOmod is to simulate a raw signal that would come from the piezo and analog chain.                                                                                                | <ul><li>ITF-1_GND</li></ul><li>ITF-2_VDD_5V</li></ul><li>ITF-17_POff3</li></ul>                                                                                                 | <ul><li>ITF-18_Raw</li></ul>                                                                   |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/doj/viewme.png' align='center' width='150'>         | **[doj](https://github.com/kelu124/echomods/blob/master/doj/Readme.md)**: Getting a motherboard: that's fitting all the modules in an easy way, with an easy access to all tracks. See this for the Kicad files.                                                                    |                                                                                                                                                                                 |                                                                                                |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/retroATL3/viewme.png' align='center' width='150'>   | **[retroATL3](https://github.com/kelu124/echomods/blob/master/retroATL3/Readme.md)**: The aim of this echOmod is to get the mechanical movement of the piezos. Salvaged from a former ATL3.                                                                                         | <ul><li>ITF-A_gnd</li></ul><li>ITF-F_12V</li></ul><li>ITF-N_cc_motor_pwm</li></ul><li>ITF-mET_Transducer</li></ul><li>Motor</li></ul><li>Tri-Piezo Head</li></ul>               | <ul><li>Motor</li></ul><li>ITF-mET_Transducer</li></ul><li>Tri-Piezo Head</li></ul>            |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/pic0/viewme.png' align='center' width='150'>        | **[pic0](https://github.com/kelu124/echomods/blob/master/pic0/Readme.md)**: Using a rp2040 to do a full blown pulse echo device.                                                                                                                                                    |                                                                                                                                                                                 |                                                                                                |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/matty/viewme.png' align='center' width='150'>       | **[matty](https://github.com/kelu124/echomods/blob/master/matty/Readme.md)**: The aim is to summarize all modules in a all-inclusive board. Fast ADC, good load of memory, good SNR.. the not-so-DIY module, as it comes already assembled with nothing to do =)                    |                                                                                                                                                                                 |                                                                                                |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/lit3rick/viewme.png' align='center' width='150'>    | **[lit3rick](https://github.com/kelu124/echomods/blob/master/lit3rick/Readme.md)**: The aim is to summarize all modules in a all-inclusive board. Fast ADC, good load of memory, good SNR.. the not-so-DIY module, as it comes already assembled with nothing to do. Based on up5k. |                                                                                                                                                                                 |                                                                                                |
| <img src='https://raw.githubusercontent.com/kelu124/echomods/master/elmo/viewme.png' align='center' width='150'>        | **[elmo](https://github.com/kelu124/echomods/blob/master/elmo/Readme.md)**: The aim of this module is to achieve 20Msps, at 9bits or more.                                                                                                                                          | <ul><li>ITF-1_GND</li></ul><li>ITF-2_VDD_5V</li></ul><li>ITF-19_3.3V</li></ul><li>ITF-12_RPIn</li></ul>                                                                         | <ul><li>Signal Digitalized</li></ul>                                                           |

# Experiments

* 2024-11-09: [Testing MUX](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20241109a.md): If the mux works _(20241109a)_
* 2024-06-04: [Impedance matching](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20240604a.md): another round _(20240604a)_
* 2024-04-13: [test of pico](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20240413a.md): test of pico _(20240413a)_
* 2021-04-25: [Annular MUXed](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20210425a.md): testing an annular transducer on a pink phantom _(20210425a)_
* 2021-04-24: [BiVi piezo on the MUX](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20210424a.md): First tests of the MUX _(20210424a)_
* 2021-01-29: [`Tri` two probes](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20210129a.md): Tri's tests with two probes _(20210129a)_
* 2020-12-23: [test probes](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201223a.md): testing probes with un0usb _(20201223a)_
* 2020-12-19: [test piezos](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201219r.md): VNAs piezos (dismanted ones) _(20201219r)_
* 2020-11-28: [hp2121 matching](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201128a.md): checking hp2121 probe impedance matching _(20201128a)_
* 2020-11-08: [impedance matching](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201108a.md): testing two piezos with impedance matching network _(20201108a)_
* 2020-11-07: [lib 025](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201107a.md): NDT presentation - un0rick & usb _(20201107a)_
* 2020-11-04: [lib 024](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201104a.md): Basics on - un0rick & usb _(20201104a)_
* 2020-11-03: [Impedance matching](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201103a.md): Interesting results for impedance matching. _(20201103a)_
* 2020-10-31: [Pulse width calculation](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201031a.md): how to get the best echo as a function of pulser waveform _(20201031a)_
* 2020-10-28: [strange issues pyUn0](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201028a.md): seems CS does not work _(20201028a)_
* 2020-10-26: [usb firmware](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201026a.md): testing it works with un0rick _(20201026a)_
* 2020-10-24: [i2s issue](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201024a.md): Exploring the i2s offsets _(20201024a)_
* 2020-10-23: [Canada](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201023a.md): `Silvio` first lit3rick tests _(20201023a)_
* 2020-10-22: [Spain](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201022a.md): `Jorge` tests on lit3rick _(20201022a)_
* 2020-10-08: [benchmark lit3 and un0](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201008a.md): Running acquisitions on the same rig. _(20201008a)_
* 2020-08-09: [bard vna](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200809r.md): bard vna tests _(20200809r)_
* 2020-08-08: [all probes vna](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200808r.md): getting impedance params of all probes _(20200808r)_
* 2020-06-08: [brd35 test](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200608a.md): testing an electromagnetic movement probe _(20200608a)_
* 2020-05-08: [testing bard probe](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200508a.md): Nothing much really _(20200508a)_
* 2020-04-21: [a-law](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200421b.md): testing a-law compressions compared to log and sqrt _(20200421b)_
* 2020-04-21: [comparing boards](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200421a.md): preliminary check between lit3rick and un0rick _(20200421a)_
* 2020-04-18: [echo-tomo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200418a.md): Trying to get a tomo echo image _(20200418a)_
* 2020-04-16: [testing new piezos](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200416a.md): and calibrating new piezos against bubbles _(20200416a)_
* 2020-03-25: [NDT pulse widths](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200325a.md): Trying and getting different pulse on a steel block. _(20200325a)_
* 2020-03-21: [pulse widths](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200321a.md): Trying and getting different pulse on the test bench. _(20200321a)_
* 2019-10-27: [lit3rick De.bin](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191027b.md): New success with lit3rick, with dynamic DAC _(20191027b)_
* 2019-10-27: [meh - noisy](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191027a.md): still some tests, Dd.bin for lit3rick _(20191027a)_
* 2019-10-26: [meh C2w](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191026a.md): testing new bins for lit3rick _(20191026a)_
* 2019-10-24: [getting better at dyn dac](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191024a.md): tests _(20191024a)_
* 2019-10-23: [lit3 success](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191023a.md): Some better acquisitions - it works ! _(20191023a)_
* 2019-10-22: [lit3 weird](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191022b.md): Strange signals ahead _(20191022b)_
* 2019-10-22: [weird acqs again](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191022a.md): investigating _(20191022a)_
* 2019-10-18: [first un0 acqs from Tri](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191018a.md): his [setup seems to work](https _(20191018a)_
* 2019-10-16: [weird acqs](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191016a.md): what is wrong with me ? _(20191016a)_
* 2019-10-06: [lit3 questions](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20191006a.md): what is happening ? _(20191006a)_
* 2019-08-04: [tuto video for Un0rick](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190804a.md): [more here on youtube](https _(20190804a)_
* 2019-07-13: [new un0 batch](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190713b.md): quality tests _(20190713b)_
* 2019-07-13: [RPI3](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190713a.md): yes, I had to test _(20190713a)_
* 2019-04-15: [NDT tests](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190415a.md): testing what the NDT probes does _(20190415a)_
* 2019-04-04: [NDT tests double peak](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190404a.md): why are there two frequencies ? _(20190404a)_
* 2019-03-29: [NDT dual transducer](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190329a.md): understanding the transducer _(20190329a)_
* 2019-03-24: [lit3rick](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190324a.md): testing at first the pulser _(20190324a)_
* 2019-02-26: [flashing UP5K sran](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190226a.md): using a m5stack to flash the sram of the up5K, temporarily, through a web interface _(20190226a)_
* 2019-02-23: [Testing pHATrick flash](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190223a.md): Testing pHATrick flash _(20190223a)_
* 2019-01-13: [m5stack bis](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190113a.md): retesting with details the m5stack experiment _(20190113a)_
* 2019-01-11: [faster checks](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190111a.md): multi, single, process commands for the lib _(20190111a)_
* 2019-01-04: [lib improvements part II](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190104a.md): streamlining processing images _(20190104a)_
* 2019-01-03: [lib improvements](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20190103a.md): streamlining processing images _(20190103a)_
* 2018-11-26: [HV tests part II](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20181126b.md): checking what's the fact with HV parts _(20181126b)_
* 2018-11-26: [HV tests](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20181126a.md): checking what's the fact with HV parts _(20181126a)_
* 2018-11-04: [matty and 724A](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20181104c.md): testing a new probe with matty v1.01 _(20181104c)_
* 2018-11-04: [matty and Apogee10 recabled](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20181104b.md): testing a new probe with matty v1.01 _(20181104b)_
* 2018-11-04: [matty and hp2121](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20181104a.md): playing with hp2121 and matty _(20181104a)_
* 2018-10-13: [opening an hp2121](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20181013a.md): try and open an hp2121, while waiting for a new matty _(20181013a)_
* 2018-09-01: [wirephantom and kretzaw145ba](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180901a.md): wirephantom and kretzaw145ba _(20180901a)_
* 2018-08-31: [wirephantom and retroATL3](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180831c.md): wirephantom and retroATL3 _(20180831c)_
* 2018-08-26: [16bits n-cycles](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180826a.md): Testing if the 16bits n cycles works _(20180826a)_
* 2018-08-25: [2D images building](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180825a.md): Testing new functions to unpack images (with N lines) _(20180825a)_
* 2018-08-14: [Reaching 128msps](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180814a.md): Trying to experiment getting 128Msps _(20180814a)_
* 2018-08-13: [pyUn0 lib glitches](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180813a.md): Experiment to capture glitches. Now captured (bugs with timing), pending is increasing NCycles above a 8 bit count. _(20180813a)_
* 2018-08-12: [KretzImage](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180812a.md): Getting an image with a kretz AW14/5B/A ultrasound probe _(20180812a)_
* 2018-08-09: [Ausonics 7.5MHz probe](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180809b.md): Getting in a Ausonics 7.5MHz probe _(20180809b)_
* 2018-08-07: [InterspecApogee](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180807b.md): Opening an InterspecApogee probe _(20180807b)_
* 2018-08-07: [ADR Ultrasound probe](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180807a.md): Photo reportage of opening an ADR Ultrasound probe. _(20180807a)_
* 2018-07-21: [pyUn0 python lib and TGC](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180721a.md): Testing class-approach for acquisition and processing. Also tested Gain setup. _(20180721a)_
* 2018-06-20: [Uwe setup](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180620a.md): Testing ADC with Uwe setup with elmo and a 250khz source _(20180620a)_
* 2018-05-16: [Matty file format](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180516a.md): Testing to format the data for experiments to be easily reproduced _(20180516a)_
* 2018-05-11: [Enveloppe detection](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180511a.md): Checking different ways to rebuild enveloppe _(20180511a)_
* 2018-05-06: [SPI timing on Raspberry](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180506a.md): Checking SPI bottlenecks on Matty _(20180506a)_
* 2018-04-30: [JSON and Servo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180430a.md): Better file management and servo control using Matty. _(20180430a)_
* 2018-04-17: [echomods vs MATTY](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180417a.md): Comparing the performances of the modules vs the FPGA board Matty _(20180417a)_
* 2018-04-15: [Test of new batch 2/2](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180415r.md): Testing the lite.tbo, goblin and elmo boards done at the fab - on a doj v2 motherboard. _(20180415r)_
* 2018-04-15: [Test of new batch 1/2](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180415a.md): Testing the goblin board with silent, then test of the new lite.tbo pulser with a piezo. _(20180415a)_
* 2018-04-03: [`Tomas` first acq](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180403t.md): Tomas, a user, is getting a first image from a NDT setup with a block of steel. _(20180403t)_
* 2018-04-03: [Matty TGC test](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180403b.md): Testing matty 's TGC, including playing with the gain DAC and pulse control. _(20180403b)_
* 2018-04-03: [Voltage checks](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180403a.md): Testing matty at different voltages. _(20180403a)_
* 2018-03-10: [Matty DAQ](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180310a.md): testing the programmation of matty DAC control for the TGC. _(20180310a)_
* 2018-02-25: [Matty and RetroATL3](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180225a.md): Acquisition of a probe image with matty. _(20180225a)_
* 2018-02-24: [Matty Gain](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180224b.md): Testing matty's fixed gain settings. _(20180224b)_
* 2018-02-24: [Matty speed tests](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180224a.md): Testing matty s acquisition at different speed, 12Msps to 24Msps. _(20180224a)_
* 2018-02-17: [Alt.tbo and Elmo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180217a.md): Testing alt.tbo and elmo new boards for pulser issues (there is not positive and negative pulse, only goes in direction). _(20180217a)_
* 2018-02-16: [Alt.tbo and Elmo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180216a.md): Testing alt.tbo and elmo new boards. _(20180216a)_
* 2018-01-15: [Matty](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180115a.md): Receiving the first matty. _(20180115a)_
* 2018-01-03: [`Felix` experiment](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20180103a.md): Testing Felix setup with previous Bomanz module. _(20180103a)_
* 2017-11-24: [Impedance matching](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20171124a.md): Doing some tests for impedance matching. _(20171124a)_
* 2017-11-12: [Probe](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20171112a.md): Testing new probe with new pulser _(20171112a)_
* 2017-11-11: [Alt.tbo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20171111a.md): Testing new pulser again 4/4 _(20171111a)_
* 2017-10-01: [Alt.tbo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20171001b.md): Testing new pulser again 3/4 _(20171001b)_
* 2017-10-01: [Alt.tbo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20171001a.md): Testing new pulser again 2/4 _(20171001a)_
* 2017-09-30: [Alt.tbo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20170930a.md): Testing new pulser again 1/4 _(20170930a)_
* 2017-07-15: [RetroATL3 acquisition](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20170715a.md): Getting an image from the retroATL3 probe. _(20170715a)_
* 2017-07-13: [Elmo](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20170713a.md): Testing the new DAQ with two ADCs. _(20170713a)_
* 2017-06-11: [Croaker](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20170611a.md): Testing the acquisition with the croaker module. _(20170611a)_
* 2016-12-17: [Croaker](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20161217a.md): Testing the acquisition with the croaker module. _(20161217a)_
* 2016-08-22: [BBB+Probe](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20160822a.md): Images acquired from a BeagleBone black with a probe _(20160822a)_
* 2016-08-14: [RPi](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20160814a.md): Testing the acquisition with the BeagleBone DAQ. _(20160814a)_
* 2016-08-09: [Goblin tests](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20160809a.md): Testing the goblin board with the silent emulator. _(20160809a)_
