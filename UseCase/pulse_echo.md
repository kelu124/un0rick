---
layout: default
title: Pulse-echo
parent: Use Cases
nav_order: 1
---

# Using the hardware for pulse-echo experiments

The following examples are made on a test-bench, ie a piezo with a simple reflector immerged in water, a few centimeters away from the piezo. There are other experiments with probes, such as with a [bard probe](bard.md).

Example of setup, with an un0rick board and a bench reflector.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/P_20201009_194611.jpg)

## Examples from lit3rick

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_i2s/lit3_i2s.jpg)

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_i2s/lit3_i2s_detailed.jpg)

## Examples from un0rick

### Setup

The setup is a classical one, header of the board connected to the Raspberry pi through a ribbon, the transducer being connected to the board.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190713/P_20190713_223932.jpg)

### Acquisitions.

The pyUn0 lib was used to acquire a single line, which yielded:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190713/20190713b/images/20190713a-1.jpg)

One will find the bandwidth of the transducer itself from the FFT of the signal:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190713/20190713b/images/20190713a-2-fft.jpg)

# Video

A demo in [video](https://www.youtube.com/watch?v=rv-Ag_TcnP8&feature=youtu.be) was done.

# Along with a servo

That worked on an early prototype (2x20 header reversed, single connector) - but still valid. [Experiment data](https://github.com/kelu124/echomods/tree/master/matty/20180430a) are here.

## Setup

A microcontroller is moving a piezo in front of a wire target.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180430a/image/20180430_181856.jpg)

SPI lines (transmitting the servo position) are connected to the TopTurn entries of the un0rick board. 

Here's the signal I'm sending on the two bits acquired from the TopTurn bits. Here, the piezo is at angle 22, that's a reference of the offset (60) + the position, so I should read 82 in binary. And that's what I'm getting, yeay!

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180430a/wire/clock_check_pos82.jpg)


## Acquisition

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180430a/wire/SCImage.jpg)


