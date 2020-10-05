---
layout: default
title: FPGA RPi setup
parent: un0rick
nav_order: 1
---

# Experiments

## Introduction

This project has a specific target of providing a __low-cost, open source technological kit to allow scientists, academics, hackers, makers or OSHW fans to hack their way to ultrasound imaging__ - below 500$ - at home, with no specific equipment required. This piece of hardware follows [the murgen dev-kit](https://github.com/kelu124/murgen-dev-kit) and the [echomods](https://github.com/kelu124/echomods/), previous iterations. Those were simpler, less robust and less cost-efficient than this kit.

## ice40 - a specificity

This board builds in particular on the famouse ice40 FPGA family which is low-cost, ... and open-sourced.

It can use the "Project IceStorm", which aims at reverse engineering and documenting the bitstream format of Lattice iCE40 FPGAs and providing simple tools for analyzing and creating bitstream files.

There's a bit of action around these FPGAs these days, be it for tools, extensions, DIP designs,... and I thought using those for a ultrasound imaging device would permit to mix both FPGA and OpenSource.

## How is this better?

Compared to previous iteration, this setup is:

* more robust;
* more cost efficient;
* integrated: SNR is far better than earlier;
* better memory for bigger captures;
* has an [Open Source Hardware Certificate](http://certificate.oshwa.org/certification-directory/)

## Objective

The aim of this project is to build a small ultrasound imaging hardware and software development kit, with the specific goal of:

- consolidating [existing hardware research](http://openhardware.metajnl.com/articles/10.5334/joh.2/);
- simplifing / lowering the cost of the kit;
- making it more robust;
- introducing a simple API to control hardware;
- having a server which provides raw ultrasound data, and for ultrasound imaging, can deliver standard DICOM files;
- having a kit that can be used for pedagogical and academic purposes - not to mention people who want to understand ultrasound!

Previous projects has shown the feasibility of the hardware, but was not simple enough. Let's keep the momentum, and use this dev kit in interesting ways.

## What can be done with this hardware?

This board has been developped for pedagogical purposes, to understand how ultrasound imaging and non-desctrucive testing work. This structure can be used to develop:

* other modalities of ultrasound imaging - and be used as a platform for A-mode, or B-mode imaging; 
* it can also be used for array imaging - the modules can be used with a multiplexer for do synthetic aperture beamforming; 
* new signal processing methods;
* test transducers - which can be used as well for maintenance and repairs of ultrasound probes;
* other non-destructive testing apparatus.

Why are you doing this ? or besides pedagogical uses of your prototype, we want to know if you are thinking about other applications ? Where your prototype can be more useful? In Africa for example, can your prototype solve some problems? 


# General principles of ultrasound imaging

## Using echoes to map interfaces

Medical ultrasound is based on the use of high frequency sound to aid in the diagnosis and treatment of patients. Ultrasound frequencies range from 2 MHz to approximately 15 MHz, although even higher frequencies may be used in some situations.

The ultrasound beam originates from mechanical oscillations of numerous crystals in a transducer, which are excited by electrical pulses (piezoelectric effect). The transducer converts one type of energy into another (electrical <--> mechanical/sound). 

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/20161016/concept1.PNG)

The ultrasound waves (pulses of sound) are sent from the transducer, propagate through different tissues, and then return to the transducer as reflected echoes when crossing an interface. The returned echoes are converted back into electrical impulses by the transducer crystals and are further processed - _mostly to extract the enveloppe of the signal, a process that transforms the electrical signal in an image_ -  in order to form the ultrasound image presented on the screen.

Ultrasound waves are reflected at the surfaces between the tissues of different density, the reflection being proportional to the difference in impedance. If the difference in density is increased, the proportion of reflected sound is increased and the proportion of transmitted sound is proportionately decreased.

If the difference in tissue density is very different, then sound is completely reflected, resulting in total acoustic shadowing. Acoustic shadowing is present behind bones, calculi (stones in kidneys, gallbladder, etc.) and air (intestinal gas). Echoes are not produced on the other hand if there is no difference in a tissue or between tissues. Homogenous fluids like blood, bile, urine, contents of simple cysts, ascites and pleural effusion are seen as echo-free structures.

## Creating a 2D image

If the process is repeated with the probe sweeping the area to image, one can build a 2D image. In practice, in the setups we'll be discussing, this sweep is done with a transducer coupled to a servo, or using a probe that has an built-in motor to create the sweep.

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/20161016/concept2.PNG)


# Plugging the Pi to an existing probe

## Not a first shot

1. A beaglebone black had been used with its [high-speed DAQ](https://kelu124.gitbooks.io/echomods/content/Chapter2/toadkiller.md) to be connected to an existing [mechanical probe](https://kelu124.gitbooks.io/echomods/content/Chapter2/retroATL3.html), with [some results](https://kelu124.gitbooks.io/echomods/content/Chapter2/basicdevkit.html). 
2. The next step has been to interface a __Raspberry Pi W__ to this probe through the [24Msps Pi ADC pHAT](https://kelu124.gitbooks.io/echomods/content/Chapter2/elmo.html), to see if one can get the same quality of image, and produce a ultrasound loop. This was [summarized here](https://kelu124.gitbooks.io/echomods/content/RPI.html)

## Comparing improvements on signal capture

Below is represented the improvement in signal capture.

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/20180417a/details.jpg)

## This setup

### Picture of the setup

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180225a/IMG_20180225_184226.jpg)

### Results

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180225a/probe.jpg)


## Making it better

I'll definitely need to use the on-board __Time Gain Compensation__, did the tests on the benchmark unit.. but haven't been using it on this rig.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180403b/TGC.jpg)



# What's next?

1. Just a name ... Kruizinga ;)
2. Plugin a real probe (I'm thinking about Shenzen, there are good prodes)
3. Assembling with an old ultrasound machine.

# Working together

## Who's working on this?

A summary of the contributors using this family of hardware is detailed below. Some continents are still to be represented!

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/map.jpg)

## And you?

* Want to learn more? You can join the [slack channel](https://join.slack.com/usdevkit/shared_invite/MTkxODU5MjU0NjI1LTE0OTY1ODgxMDEtMmYyZTliZDBlZA) if you want to discuss, but there are plenty of other sources:
* [Hackaday page too](https://hackaday.io/project/28375-un0rick-an-ice40-ultrasound-board)
* You can also __fork the [project repo](https://github.com/kelu124/un0rick/)__, 
* Or, you can go vintage and see:
  * [Old repo](https://github.com/kelu124/echomods/) can be used for an extensive archive for the source files, raw data and raw experiment logs or explore the [hackaday page](https://hackaday.io/project/9281-murgen-open-source-ultrasound-imaging), where I tried to blog day-to-day experiments in a casual format
  * Obviously, you can __read the [online manual/book](https://www.gitbook.com/book/kelu124/echomods/details)__ for a easily readable and searchable archive of the whole work on this family of hardware

# Articles

Under CC-BY-4.0, [main article here](https://openhardware.metajnl.com/articles/10.5334/joh.2/) 

