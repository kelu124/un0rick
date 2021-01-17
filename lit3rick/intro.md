---
layout: default
title: lit3rick uses
parent: lit3rick
nav_order: 1
---

# Pulse echo uses

This board can use the i2c, spi and i2s buses to communicate with any device. Basically, the i2c bus is self sufficient, with a device appearing at `0x25` (with the basic firmware) but can also be used more efficiently through SPI.

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

# Validating the AD8331 gain range

We observe a ~42dB range (close to the 48dB claimed by the AD8331) of amplification. On some values (for example the blue line), we're looking at the first echo on HI gain - hence it saturates quickly. The dashed brown line on the contrary is the 3rd peak, at LO setting, so the full range can be represented. [Experiment source](https://github.com/kelu124/lit3rick/blob/master/sample_acqs/lit3rick_5v/1.CheckingGainSetup.ipynb).

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_5v/lit3_5V_gaintrends.jpg)

We also find back the 7.5dB attenuation between the HI and the LO setting.

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/sample_acqs/lit3rick_5v/lit3_5V_hilo.jpg)




