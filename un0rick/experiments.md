---
layout: default
title: un0rick Experiment
parent: un0rick
nav_order: 5
---

All experiments (on this hardware and other) are [on this repo](https://github.com/kelu124/echomods/).

# How to manage an experiment.

All acquisitions on this page are based on:
* [this version of the python lib](https://github.com/kelu124/pyUn0-lib/blob/b364fe05ac51cf430723e5c0ff27511b7cc9c554/pyUn0.py) (v1.0.0)
* [the v1.1 firmware binary](https://github.com/kelu124/un0rick/raw/master/bins/v1.1.bin)

## Setup

All calibration / basic experiments were using a piezo with a reflector a few cm away, with water in between.

I used in this case a film case, just right for the size of the transducer, filed with water and connected to the board.

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/P_20201009_194611.jpg)

## Acquisition

### From shell 

The code below is equivalent to 

```
python pyUn0.py single
```

### Doing the acquisition

```python
import pyUn0 as us

UN0RICK = us.us_spi()
UN0RICK.init()
UN0RICK.test_spi(3)
TGCC = UN0RICK.create_tgc_curve(10, 980, True)[0]    # Gain: linear, 10mV to 980mV
UN0RICK.set_tgc_curve(TGCC)                          # We then apply the curve
UN0RICK.set_period_between_acqs(int(2500000))        # Setting 2.5ms between shots
UN0RICK.JSON["N"] = 1 				 # Experiment ID of the day
UN0RICK.set_multi_lines(False)                       # Single acquisition
UN0RICK.set_acquisition_number_lines(1)              # Setting the number of lines (1)
UN0RICK.set_msps(0)                                  # Sampling speed setting
A = UN0RICK.set_timings(200, 100, 2000, 5000, 200000)# Settings the series of pulses
UN0RICK.JSON["data"] = UN0RICK.do_acquisition()      # Doing the acquisition and saves
```

We have setup the pulse train with `us.set_timings` :

* A pulse of 200ns
* A deadtime of 100ns
* Damping for 2us
* Start of the acquisition 4us after the pulses
* Acquisition for 200us

Moreover, the TGC profile over the 200us is setup from 1% to 98% gain lineraly from 0 to 200us as:

```python
TGCC = UN0RICK.create_tgc_curve(10, 980, True)[0]    # Gain: linear, 10mV to 980mV
UN0RICK.set_tgc_curve(TGCC)                          # We then apply the curve
```

The acquisition and its parameters are saved in a json file saved close to the lib folder.

```
name_json = self.JSON["experiment"]["id"]+"-"+str(self.JSON["N"])+".json"
```


## Processing

Let's create the actual signals and images

```python
make_clean("./")	# creates a data folder if needed and moves files there
for MyDataFile in os.listdir("./data/"):
	if MyDataFile.endswith(".json"): 
	    y = us.us_json()
	    y.show_images = False
	    y.JSONprocessing("./data/"+MyDataFile) # creating the signal and time values
	    y.mkImg()
	    if y.Nacq > 1:
		y.mk2DArray()
```

which yields

![](https://raw.githubusercontent.com/kelu124/un0rick/master/pyUn0/images/20201009a-1.png)

### Other utilities

There are some other utilities.. to be enhanced ?

```python
y.create_fft() 
y.save_npz() 
```

![](https://raw.githubusercontent.com/kelu124/un0rick/master/pyUn0/images/20201009a-1-fft.png)


