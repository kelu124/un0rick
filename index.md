---
layout: default
title: Welcome!
nav_order: 1
---

[![Patreon](https://img.shields.io/badge/patreon-donate-orange.svg)](https://www.patreon.com/kelu124) 
[![Kofi](https://badgen.net/badge/icon/kofi?icon=kofi&label)](https://ko-fi.com/G2G81MT0G)
[![Slack](https://badgen.net/badge/icon/slack?icon=slack&label)](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow)
[![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org)


The `un0rick` project is an open-source ultrasound hardware project, that has evolved significantly over nearly (soon) a decade -- keeping the objective of providing an affordable tool for educational demonstrations and rapid prototyping.


# The un0rick project today

## the pic0rick

The pic0rick device is a shift in the project's approach - abandoning more complex FPGA architectures for an accessible, RP2040/RP2350-based design that delivers comparable performance at a fraction of the cost and complexity, while eliminating the steep learning curve of FPGA programming.

![](https://cdn.tindiemedia.com/images/resize/Kn3s65qieAvQ6NCM_oXqx2dLEXg=/p/full-fit-in/2336x1752/i/17175/products/2025-01-08T20%3A52%3A36.763Z-20240406_153634.jpg?1736340770)

Similar to the previous hardware, the pic0rick has great ultrasound capabilities: 60 Msps ADC with 10-bit resolution (could go faster!), an AD8331 Time-Gain Compensation ranging from 7.5 to 55.5 dB, and innovative modular PMOD expansion system - that can be used for real-time VGA display output for live acquisition visualization, or to get a multiplexer allowing you to drive a series of piezos. Un0rick making it ideal 

![Example of acquisition](https://github.com/kelu124/pic0rick/raw/main/software/imgs/pico_shell/pic0gain_at_6.jpg)

## The journey to pic0rick

It's all been about accessibility and cost reduction. It started in 2016 with an integrated board, the [Murgen board](murgen), which was a first step into the complicated world of hardware. And some discoveries about joys of developing boards. The [echOmods](modules.md) introduced the original modular concept with separate breadboard components - that allowed further explorations in a hacker-friendly manner, with the cost of more noise.

This was partially solved with [un0rick](un0rick) (2018-2025), which consolidated the best of these modules into the first integrated FPGA board using Lattice iCE40 HX4K/HX8K, achieving up to 64 Msps sampling and good timing control, on a large and possibly over complicated board that requires significant FPGA expertise to tweak the firmware.. err gateware. The lit3rick (2020-2024) simplified the design with iCE40 UP5K using a Raspberry Pi pHAT format, reducing cost (no HV onboard) while maintaining FPGA capabilities in a smaller form factor. The [lit3-32](lit3-32) (2021-2024) pushed gain performance to 92dB with AD8332 amplifiers, optimizing for weak signal detection, but still was quite expensive. Each iteration solved specific technical challenges but remained constrained by FPGA programming complexity and higher costs.

The [pic0rick](pic0rick)  eliminates these barriers, and tries and lower the cost - no FPGA toolchains, no specialized hardware knowledge, just standard 'arduino' embedded programming on the rp2040/rp2350 proven platform.

Who knows what the next step will be?

## How does it get rid of the FPGA for timing control?

The design leverages the pico Programmable Input/Output (PIO) units - one for acquisition and another for something else (like VGA output) - leaving other microcontroller resources free for custom applications. This design philosophy makes it quite versatile an easy to use.


## What can be done with this hardware?

The boards have been developped for pedagogical purposes, to understand how ultrasound imaging and non-destructive testing work. This structure can be used to develop:

* ultrasound prototypes, eg can be used as a platform for A-mode, or B-mode imaging ([pulse echo](http://un0rick.cc/UseCase/pulse_echo) works best); 
* it can also be used for array imaging - the modules can be used with a multiplexer for do synthetic aperture beamforming; 
* new signal processing methods;
* test transducers - which can be used as well for maintenance and repairs of ultrasound probes;
* use [old mechanical probes](http://un0rick.cc/probes) to get ultrasound images;
* play with [ultrasound tomography](http://un0rick.cc/UseCase/tomo);
* can be [connected to arduinos](http://un0rick.cc/UseCase/m5stack);
* other [non-destructive](http://un0rick.cc/UseCase/NDT) testing apparatus. 
* 

## How is this better?

Compared to previous iterations, the pic0rick is

* more robust;
* more cost efficient;
* has modular capabilities, for bigger captures or MUXes;
* still a device that is [Open Source Hardware Certified](http://certificate.oshwa.org/certification-directory/)

# Why open-source ultrasound?


Non destructive testing and imaging ultrasound have been around since the '50s. Many ultrasound open-source projects are emerging, mostly focusing on image processing - while hardware has been left behind. Several teams have produced succesful designs to be used on commercial US scanners, but they are not cheap, and are difficult to access.

_I couldn't find designs to play with, that would be affordable or open, so I decided to make one for makers, researchers and hackers._

# Working together

## Who's working on this?

A summary of the contributors using this family of hardware is detailed below. Some continents are still to be represented!

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/map.jpg)

## And you?

* Want to learn more? We are on the [Matrix](https://app.element.io/#/room/#un0rick:matrix.org) as an open chat, if you want to discuss, but there are plenty of other sources:
* Check __the [project repo](https://github.com/kelu124/pic0rick/)__


# Articles


The systems designs have been documented, and captured in a number of openly accessible articles:
* [Arduino-like development kit for single-element ultrasound imaging](https://doi.org/10.5334/joh.2)
* [Review of Current Simple Ultrasound Hardware Considerations, Designs, and Processing Opportunities](https://doi.org/10.5334/joh.28)
* [A rp2040-based ultrasound pulse-echo acquisition device](https://doi.org/10.5281/zenodo.10968503)


## License

This work is based on a previous TAPR project, the [pic0rick project](https://github.com/kelu124/pic0rick), the [echOmods project](https://github.com/kelu124/echomods/). The [un0rick project](https://github.com/kelu124/un0rick), the [lit3rick project](https://github.com/kelu124/lit3rick) and their boards are open hardware and software, developped with open-source elements, as much as possible.

Copyright Kelu124 (kelu124@gmail.com) 2018-2025

* The hardware is licensed under TAPR Open Hardware License (www.tapr.org/OHL)
* The software components are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
* The documentation is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).


## Disclaimer(s)

This project is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. Also:
* This is not a medical ultrasound scanner! It's a development kit that can be used for pedagogical and academic purposes - possible immediate use as a non-destructive testing (NDT) tool, for example in metallurgical crack analysis. 
* As in all electronics, be careful, especially.
* This is a learning by doing project, I never did something related -> It's all but a finalized product.
* Ultrasound raises questions. In case you build a scanner, use caution and good sense!
