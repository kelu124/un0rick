---
layout: default
title: USB Probes
parent: Byproducts and goodies
nav_order: 4
---

# Getting ultrasound images from OEM probes

## Objective

The objective for [this python lib](https://github.com/kelu124/pyusbus) is be able to get images from USB probes easily, under python, in a user-friendly API, getting images in 3 lines of code.

```python
import pyusbus as usbProbe
probe = usbProbe.UP20() 
frames = probe.getImages(n=10) # should yield loop of 10 frames
```

Getting signals and images from ultrasound [mechanical probes](http://un0rick.cc/probes) is an interesting step to know what radiofrequency signals mean in ultrasound imaging, be it for non-destructive testing or medical imaging. The [two pulse-echo boards](http://un0rick.cc/) are achieving this, however, this requires extra hardware (electronics, probes, a fair bit of soldering, ..). Getting ultrasound images could be more straightforward, especially considering ~1kUSD usb probes available on the market. Their image quality is quite good at first glance.

![](https://raw.githubusercontent.com/kelu124/pyusbus/main/probes/CONV/202103190001_0001_009.jpg)

## Target devices

This lib was tested on both a convex and a linear probe, each from a different manufacturer. Would you be interested in getting one, let me know so that I can refer to the fab _contact at un0rick.cc_.

## Result

![](https://raw.githubusercontent.com/kelu124/pyusbus/main/experiments/images/20210401/20210401.gif)

# Moar details

## Listening

Even if SDK exists at the OEM level, I have tried and explore the communication protocols using a VM, on which the OEM software is installed. Then listening using wireshark to get packets and understand how the probes communicate. Both were using Cypress chips.

The protocols themselves are not overly complicated, especially for the convex one. The linear one was a bit more tricky, playing between control and bulk transfers.

Once the probe is initiated, getting images is relatively straightforward, using bulk transfers. But the configuration is trickier.

## Configuration

Both probes require a bit of configuration, and byte arrays are sent to them to set items. In the case of the linear, additional short transfers took place.

It would definitely be interesting to get more into these [configuration arrays](https://github.com/kelu124/pyusbus/blob/main/experiments/payloads/UP20L_payloads.ipynb), as one finds back some ultrasound artefacts (beamformers, time gain compensation, gain curves, ...).

## Receiving images

Interestingly, the two probes have different ways of working. The Linear one does send preformed images, for which the images is "ready to be used". All parameters seem to be applied inside the probe head, as seen below:

![](https://raw.githubusercontent.com/kelu124/pyusbus/main/experiments/images/first.gif)

However, the convex one seems to send back RF signals, post-beamforming. I'm curious to see if that is direct sampling or IQ demodulated signals.

![](https://raw.githubusercontent.com/kelu124/pyusbus/main/experiments/images/20210401/20210401_detail.png).


# Next steps

Plenty left to do !
* Understand the packets
* Improve the documentation
* Clean the code
* Streamline the configuration procedures
* Get moar probes
* ...


# Support the project?


Would you like to support the project, anything can go!
* You have ultrasound stuff (probes, phantoms, devices...) : let me know at _luc at un0rick.cc_. Always good to have stuff to explore. Been already playing with a fair bit of [mechanical probes](https://github.com/kelu124/echomods/tree/master/include/probes).
* Contribute to the repos? Straightforward, isn't it?
  * Any type of contribution works!
  * If you are keen on understanding the configuration arrays or have any ideas.. feel free!
* Are you a researcher, startup or student in need of ultrasound hardware? Buy some [open-source hardware](http://un0rick.cc/) and support the cause!
* [Buy me a coffee](https://ko-fi.com/kelu124), it's always appreciated =)
* Wanna chat? [Join the slack](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow) !










