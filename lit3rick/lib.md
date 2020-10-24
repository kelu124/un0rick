---
layout: default
title: The lib
parent: lit3rick
nav_order: 3
---

The main lib is the [py_fpga.py](https://github.com/kelu124/lit3rick/blob/master/py_fpga/py_fpga.py) file.

So far, we have the following main functions:

## TGC control

### set_HILO

```python
    def set_HILO(self, val):
```

Sets a gain on HI or LO values (7db difference, from AD8331).

### set_dac

```python
    def set_dac(self, val, channel='A', gain=1, shutdown=0, mem=None):
```
The function for setup DAC value.
Parameters val, channel, and gain setup the DAC value, channel for write and gain respectivelly. 
Parameter shutdown perform shutdown mode of the DAC. 
Parameter mem setup the memory cell for the DAC values during acquisition. 
For setup the common DAC value (which applyes not during acquisition) type Nono into the mem parameter or dont initialize it. 
For setup one of memory cells for the DAC value during acquisition set into mem parameter a cell address. 
Cells into memory have a word addressing from 0 to 15.
These 16 values will applied during acquisition sequentially from 0 to 15 after the constant period (512 samples).

## Pulser control

```python
    def set_waveform(self, pdelay = 1, PHV_time = 1, PnHV_time = 1, PDamp_time = 1):
```

## Reading the signal once acquired

```python
    def read_signal_through_spi(self):
```
```python
    def read_signal_through_i2c(self):
```

## Capturing the signal

```python
    def capture_signal(self):
```

## Calculating and reading the filtered signal

```python
    def calc_fft(self):
```

```python
    def read_fft_through_spi(self):
```


