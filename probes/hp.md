---
layout: default
title: HP21412A
parent: Using probes
nav_order: 3
---

[Source of the experiment](https://github.com/kelu124/echomods/tree/master/matty/20181104a) - with a un0rick board

# Probe model

* `HP 21412A` (seems like `HP 21402A` would work too). A good choice to try mechanical scanning. Simple piezo, simple motor.

Make sure that the liquid is present in the head.

# Connections

* The motor (black/white pair) is driven by a DRV8834 at 5V. Setup is as follows:
  * STEP: 400us period square wave.
  * M1: HIGH
  * !SLEEP: HIGH
  * Connection to motor: A1/A2 or B1/B2
* Piezo: yellow coax

# Experiment

## Setup

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20181104a/photos/P_20181104_130033.jpg)

## Raw image

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20181104a/images/2DArray_20181104a-3.jpg)


# Result

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20181104a/images/SC_20181104a-3-fft.jpg)
