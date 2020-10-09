---
layout: default
title: lit3rick uses
parent: lit3rick
nav_order: 1
---

# Pulse echo uses

This board uses the i2c, spi and i2s buses to communicate with any device. Basically, the i2c bus is self sufficient, with a device appearing at `0x25` but can also be used more efficiently through spi.

# Sample of acquisitions.

A simple pulse-echo experiment is done here, with multiple echoes from a reflector a few centimeters away from the transducer.

The board allows for onboard signal filtering and envelop extraction. 

The images below represent acquisitions on the lit3rick, medium gain, using onboard enveloppe detection

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_i2s/lit3_i2s.jpg)

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_i2s/lit3_i2s_detailed.jpg)

# Parameters

The board can be set up using different parameters, that allow to set up :

* an initial delay
* the length of positive hv pulse
* the length of negative hv pulse
* the damping period

By default, all acquisitions are 128us long, which is normally enough for most uses.

The i2s bus can be used to get filtered data (enveloppe already extracted) for several consecutive acquisitions.


