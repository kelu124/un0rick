---
layout: default
title: Pulse-echo
parent: Use Cases
nav_order: 1
---

# Using the hardware for pulse-echo experiments

The following examples are made on a test-bench, ie a piezo with a simple reflector immerged in water, a few centimeters away from the piezo. There are other experiments with probes, such as with a [bard probe](bard.md).

## Examples from lit3rick

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_i2s/lit3_i2s.jpg)

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_i2s/lit3_i2s_detailed.jpg)

## Examples from un0rick

### Setup

The setup is a classical one, header of the board connected to the Raspberry pi through a ribbon, the transducer being connected to the board.

![](https://github.com/kelu124/echomods/blob/master/matty/20190713/P_20190713_223932.jpg)

### Acquisitions.

The pyUn0 lib was used to acquire a single line, which yielded:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190713/20190713b/images/20190713a-1.jpg)

One will find the bandwidth of the transducer itself from the FFT of the signal:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20190713/20190713b/images/20190713a-2-fft.jpg)

# Video

A demo in [video](https://www.youtube.com/watch?v=rv-Ag_TcnP8&feature=youtu.be) was done.




