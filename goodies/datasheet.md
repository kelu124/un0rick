---
layout: default
title: Transducer datasheets
parent: Byproducts and goodies
nav_order: 5
---

# Example of a datasheet

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/piezo_datasheet.jpg)

```
New Olympus Harisonic Tubo Ultrasonic Transducer 2.25MHz 0.5"x1.0" 3" Cyl Foc J4

New Olympus Harisonic Tuboscope Ultrasonic Transducer
Part number:  HI-7074, 394479-0010
Frequency: 2.25 MHz
Dimensions:  0.5" x 1.0"
3" cylinder focus
New transducer with inspection documents.

We have a number of these transducers made by various companies: GE, Technisonic, Tuboscope, Olympus, etc. they are all the same.  If you need more than one, or have a preference of manufacturer, contact us before buying.
```

# What it means

## Response curve

Here, what you need to remember from this datasheet are the 2 curves: the shape of an echo (here in return after echo on a block), which determines the impulse response of the piezo (ie the spectrum next to it), which gives its bandwidth at -3dB.

We check that the bandwidth is centered on the claimed frequency (here 2.25MHz, it seems to fit).

## Targets

The datasheet here is much more complete than usual, it specifies a target at 1.9 inches, in the water, which fits the echo timings.

It also specifies the width of the echo at -6dB and at -20dB, respectively 0.8 and 1.4us, which allows to determine the axial resolution of the piezo. In this case, if we want to distinguish two echoes at -6dB, we will need a minimum distance of 0.8us.

The frequency data here is as expected central frequency and bandwidth, the datasheet has however set the limits to 3 and 6dB attenuation.

## Pulse echo measurement

Finally, since this datasheet is nice, we find the details of the pulse/echo that allowed us to make these measurements.

