---
layout: default
title: Welcome!
nav_order: 1
---


# Open source ultrasound


Non destructive testing and imaging ultrasound have been around since the '50s. Many ultrasound open-source projects are emerging, mostly focusing on image processing - while hardware has been left behind. Several teams have produced succesful designs to be used on commercial US scanners, but they are not cheap, and are difficult to access.


I couldn't find designs to play with, that would be affordable or open, so I decided to make one for makers, researchers and hackers.

## Why this project ?

This project has a specific target of providing a __low-cost, open source technological kit to allow scientists, academics, hackers, makers or OSHW fans to hack their way to ultrasound imaging__ - below 500$ - at home, with no specific equipment required. This piece of hardware follows [the murgen dev-kit](https://github.com/kelu124/murgen-dev-kit) and the [echomods](https://github.com/kelu124/echomods/), previous iterations. Those were simpler, less robust and less cost-efficient than this kit.

The aim of this project is to build a basic ultrasound imaging hardware and software development kit, with the specific goal of:

- consolidating [existing hardware research](http://openhardware.metajnl.com/articles/10.5334/joh.2/);
- simplifing / lowering the cost of the kit;
- making it more robust;
- introducing a simple API to control hardware;
- having a server which provides raw ultrasound data, and for ultrasound imaging, can deliver standard DICOM files;
- having a kit that can be used for pedagogical and academic purposes - not to mention people who want to understand ultrasound!

Previous projects has shown the feasibility of the hardware, but was not simple enough. Let's keep the momentum, and use this dev kit in interesting ways.

## Two boards

For this project, I developped two boards, the [un0rick](un0rick.md) and the [lit3rick](lit3rick.md) boards, based on the hx4k and up5k lattice fpga, respectively.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_black.png)


![](https://raw.githubusercontent.com/kelu124/lit3rick/master/images/top.jpg)

## ice40 - a specificity

This board builds in particular on the famouse ice40 FPGA family which is low-cost, ... and open-sourced.

It can use the "Project IceStorm", which aims at reverse engineering and documenting the bitstream format of Lattice iCE40 FPGAs and providing simple tools for analyzing and creating bitstream files.

There's a bit of action around these FPGAs these days, be it for tools, extensions, DIP designs,... and I thought using those for a ultrasound imaging device would permit to mix both FPGA and OpenSource.



## How is this better?

Compared to previous iterations, the two un0rick and lit3rick boards setups are :

* more robust;
* more cost efficient;
* integrated: SNR is far better than earlier;
* better memory for bigger captures;
* has an [Open Source Hardware Certificate](http://certificate.oshwa.org/certification-directory/)

## What can be done with this hardware?

This board has been developped for pedagogical purposes, to understand how ultrasound imaging and non-desctrucive testing work. This structure can be used to develop:

* other modalities of ultrasound imaging - and be used as a platform for A-mode, or B-mode imaging; 
* it can also be used for array imaging - the modules can be used with a multiplexer for do synthetic aperture beamforming; 
* new signal processing methods;
* test transducers - which can be used as well for maintenance and repairs of ultrasound probes;
* other non-destructive testing apparatus.

Why are you doing this ? or besides pedagogical uses of your prototype, we want to know if you are thinking about other applications ? Where your prototype can be more useful? Can your prototype solve some problems? 

# Working together

## Who's working on this?

A summary of the contributors using this family of hardware is detailed below. Some continents are still to be represented!

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/map.jpg)

## And you?

* Want to learn more? You can join the [slack channel](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow) if you want to discuss, but there are plenty of other sources:
* [Hackaday page too](https://hackaday.io/project/28375-un0rick-an-ice40-ultrasound-board)
* You can also __fork the [project repo](https://github.com/kelu124/un0rick/)__, 
* Or, you can go vintage and see:
  * [Old repo](https://github.com/kelu124/echomods/) can be used for an extensive archive for the source files, raw data and raw experiment logs or explore the [hackaday page](https://hackaday.io/project/9281-murgen-open-source-ultrasound-imaging), where I tried to blog day-to-day experiments in a casual format
  * Obviously, you can __read the [online manual/book](https://www.gitbook.com/book/kelu124/echomods/details)__ for a easily readable and searchable archive of the whole work on this family of hardware

# Articles

Under CC-BY-4.0, [main article here](https://openhardware.metajnl.com/articles/10.5334/joh.2/). Other articles are in the pipeline.

## License

This work is based on a previous TAPR project, [the echOmods project](https://github.com/kelu124/echomods/). The [un0rick project](https://github.com/kelu124/un0rick), the [lit3rick project](https://github.com/kelu124/lit3rick) and their boards are open hardware and software, developped with open-source elements, as much as possible.

Copyright Kelu124 (kelu124@gmail.com) 2018-2020

* The hardware is licensed under TAPR Open Hardware License (www.tapr.org/OHL)
* The software components are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
* The documentation is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).


## Disclaimer(s)

This project is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. Also:
* This is not a medical ultrasound scanner! It's a development kit that can be used for pedagogical and academic purposes - possible immediate use as a non-destructive testing (NDT) tool, for example in metallurgical crack analysis. 
* As in all electronics, be careful, especially.
* This is a learning by doing project, I never did something related -> It's all but a finalized product.
* Ultrasound raises questions. In case you build a scanner, use caution and good sense!

