# pyUn0 lib

## Working for un0rick !

Been testing it on un0rick v1.1 (with double SMA connectors) on a RPi4, with python2 and python3.

```
python pyUn0.py single
python pyUn0.py process
```

## Setup of the "single" parameter acquisition


```python
UN0RICK = us_spi()
UN0RICK.init()
UN0RICK.test_spi(3)
TGCC = UN0RICK.create_tgc_curve(10, 980, True)[0]    # Gain: linear, 10mV to 980mV 
#                                                    # (1% to 98% gain over 200us)
UN0RICK.set_tgc_curve(TGCC)                          # We then apply the curve
UN0RICK.set_period_between_acqs(int(2500000))        # Setting 2.5ms between shots
UN0RICK.JSON["N"] = 1 				     # Experiment ID of the day
UN0RICK.set_multi_lines(False)                       # Single acquisition
UN0RICK.set_acquisition_number_lines(1)              # Setting the number of lines (1)
UN0RICK.set_msps(0)                                  # Sampling speed setting (64Msps)
A = UN0RICK.set_timings(200, 100, 2000, 5000, 200000)# Settings the series of pulses, 200ns pulse.
UN0RICK.JSON["data"] = UN0RICK.do_acquisition()      # Doing the acquisition and saves
```

## Seems to be working 

![](/images/20201009a-1.png)

![](/images/20201009a-1-fft)
