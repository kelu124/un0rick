---
layout: default
title: New version of the lit3rick, lit3-32
parent: lit3-32
nav_order: 1
---
## The up5k lit3rick open hardware ultrasound pulse echo board, with -28dB to 92dB gain

Lit3-32 is the younger sibling of the lit3rick board, and keeps the same principles.

Apart from shifting to AD8331 to AD8332 to have more gain, the source code / dev files are moved from upverter to altium, for ease of share. Because of more gain, the ADC goes from 12 bits to 10 bits. The form factor now is strictly a pHAT.

### OSHWA certified !

[https://certification.oshwa.org/fr000016.html](https://certification.oshwa.org/fr000016.html)

## Presentation of the hardware

* Lattice: up5k. Onboard RAM for 64k points saves. (128kB onboard RAM)
* Onboard flash
* Pulser : HV7361GA-G:

  * Can manage +-100V pulses. Onboard is 5V pulse.
  * Integrated circuit protection from HV
* Time gain compensation : [AD8332](https://github.com/kelu124/lit3rick/blob/lit3-32/altium/ad8332.md) using both channels, chained

  * HI setting: -4dB to __92dB__ amp
  * LO setting: -28dB to 68dB amp
* ADC: 10bits, up to 64Msps here. Test in progress for 80MHz acqs.
* Previous iteration: [documentation released: 10.5281/zenodo.5792245](https://zenodo.org/record/5792245#.YhvClITMJuQ)
* [Schematics](https://github.com/kelu124/lit3rick/blob/lit3-32/altium/OUTPUT/Schematics/ice40_schematic.PDF)

![img](https://github.com/kelu124/lit3rick/raw/lit3-32/build/schematics.png)

# Pics


## Design

![img](https://github.com/kelu124/lit3rick/raw/lit3-32/top.png)

![img](https://github.com/kelu124/lit3rick/raw/lit3-32/bot.png)

## Prod

![img](https://github.com/kelu124/lit3rick/raw/lit3-32/build/imagelit3_32.png)

## Python user code

* Principles are [here](https://github.com/kelu124/lit3rick/blob/lit3-32/lit3-32/icestudio/Readme.md)
* Python code is [here](https://github.com/kelu124/lit3rick/blob/lit3-32/icestudio/python/python.py)

## Verilog: using icestudio (work in progress)

![img](https://github.com/kelu124/lit3rick/raw/lit3-32/icestudio/icestudio_screenshot.png)

.. and a list of binaries. `823f03fdc4bc9354f3f7d20d9fca6d58` is the latest stable one.

```
823f03fdc4bc9354f3f7d20d9fca6d58  ./20230114_GainTests/bins/working.bin
e33742aa40016c3d32f804f4f5a2916f  ./20230114_GainTests/bins/pll_test_impl_1.bin
823f03fdc4bc9354f3f7d20d9fca6d58  ./20230114_GainTests/bins/hardware.bin
e3ddac9e455002339cf0d9cd9f03672c  ./program/blink.bin
823f03fdc4bc9354f3f7d20d9fca6d58  ./icestudio/lit3/ice-build/lit3bin/hardware.bin
70a0563b9e889dcdd5ab43a0825b8bfc  ./icestudio/old/corePLL/ice-build/corePLL/hardware.bin
823f03fdc4bc9354f3f7d20d9fca6d58  ./example/bins/working.bin
e33742aa40016c3d32f804f4f5a2916f  ./example/bins/pll_test_impl_1.bin
823f03fdc4bc9354f3f7d20d9fca6d58  ./example/bins/hardware.bin
```

# Outputs

Below are echoes from a 5V pulse, gain at 350/1000, HILO being low.

![img](https://github.com/kelu124/lit3rick/raw/lit3-32/icestudio/G350_HL0_5V.jpg)

[
    Schematics are here](https://github.com/kelu124/lit3rick/raw/lit3-32/build/ice40_schematic.PDF)

## Seen in groups ?

![Boards in group](https://github.com/kelu124/lit3rick/blob/lit3-32/build/imagelit3_32.png?raw=true "Title")
