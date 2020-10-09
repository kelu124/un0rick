---
layout: default
title: NDT
parent: Use Cases 
nav_order: 3
---


# Use of the hardware for NDT

In the experiments below, NDT tests were done on a steel block used for calibration. A dual transducer element was used, with a jumper removed from the board to allow for different TX and RX paths. 

## Setup

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190329a/photos/P_20190329_214504.jpg)

## Overview of the results

Unsurprisingly, one will see multiple echoes at different depths, depending on the calibration block. 

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20200325a/hilbert_thickness_measurement.png)

## Example of an acquisition 

### Raw signal

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190329a/images/20190329a-2.jpg)

15mm block

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190404a/images/20190404a-4.jpg)


### Enveloppe

The enveloppe can be extracted

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190404a/images/EnveloppeThickness_20190404a-3.jpg)


### FFT

And the fourier content of the acquisition verified.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190329a/images/20190329a-2-fft.jpg)


