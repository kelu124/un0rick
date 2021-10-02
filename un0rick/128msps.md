---
layout: default
title: Up to 128Msps
parent: un0rick
nav_order: 7
---


[Source experiment](https://github.com/kelu124/echomods/tree/master/matty/20180814a)

* __Tip: reaching 128msps__

Playing with the trigger, it's possible to [interleave two signals](https://github.com/kelu124/echomods/blob/master/matty/20180814a/20180814a-Server.ipynb) and artificially double to acquisition speed, yielding clean images.

The version used for this is the [GPIO](http://un0rick.cc/un0rick/rpi-setup) firmware, but it is natively integrated in the [usb version](http://un0rick.cc/un0rick/usb-setup) of the firmware.

# Setup 

The usual fixed target. But [code](https://github.com/kelu124/echomods/blob/master/matty/20180814a/20180814a-Server.ipynb) has changed.

```python
x.setNLines(1)				            # Setting the number of lines
x.setMultiLines(False)				    # Multi lines acquisition	
x.setMsps(0) 					    # Acquisition Freq
for k in range(10):
    A = x.setTimings(200,100,2000,25000+5*k,105000) # Settings the series of pulses
    #print A
    # Do the acquisition
    x.JSON["data"] = x.doAcquisition()
    x.JSON["N"] = x.JSON["N"] + 1
```

# Images

On the pictures below, we take two consecutive sampling. Blue dots then red dots.

We start with blue dots, and we take a point every 1/64us (sampling speed at 64Msps). Then we do a second acquisition, but we delay this second sampling start with 1/128us. We can do this because the thing we sample is the same between two acquisitions.

We then plot red and blue dots (interleaving). Because we have this 1/128us (half a period) shift, it is equivalent to an interleaving.

So the blue dots would be at time 0/64, 1/64, 2/64 (or 0/128, 2/128, 4/128) and the red dots would be at times (0/64+1/128, 1/128+1/64) that is equal to (1/128, 3/128, 5/128...). So if you join the two series you have 0, 1, 2, 3, 4 (/128) equivalent to a 128msps sampling
## Overview 

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180814a/128Msps_20180813a-9-detail.jpg)

## In detail 

It seems that the different series interleave quite nicely, even in the detail.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/20180814a/128Msps_20180813a-9-fft.jpg)
