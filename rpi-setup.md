# How to setup the board using only a raspberry pi 4

## Putting the board together

Need a few feet, two 2x20 headers, and a SMA.

### Board in a bag

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_150726.jpg)

### What do we need ?

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_151518_good.jpg)

### Assembled !

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_163216_good.jpg)

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/black/P_20191214_163247_good.jpg)

## Installing iceprog

iceprog is the software used to put the fpga on the flash storage on the board, which will be read by the fpga on boot.

The easiest way is to 

```
sudo apt install fpga-icestorm
```

If this doesn't work, then this may work:

```
sudo apt-get install libftdi-dev git gcc 
git clone https://github.com/cliffordwolf/icestorm.git
cd iceprog
make 
sudo make install
```

This will create and install the iceprog utility, used to flash the fpga program (bitstream).

Prepare the jumper here :

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/program.jpg)

Then, plug an usb cable from the RPi to the board (not connected using the raspberry pi header).

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/P_20191123_144920.jpg)

Check that the FTDI device is well created by typing:

```
dmesg
```

and then flash the FPGA by doing:

```
wget https://github.com/kelu124/un0rick/raw/master/bins/v1.1.bin
iceprog v1.1.bin
```

This should flash the board:

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/v1.01/iceprog.png)

## Physical setup for the lib acquisitions

I've been using a RPi4 with a ribbon cable to connect to the board, leaving the jumper on, putting one to select the high voltage level, connecting a piezo.. and that's it.

![](https://raw.githubusercontent.com/kelu124/echomods/master/matty/images/P_20191123_161358.jpg)

## Running an acquisition

Then, for example to discover the board using Python, you can use the library:

```
git clone git@github.com:kelu124/pyUn0-lib.git
cd pyUn0-lib
python pyUn0.py test
python pyUn0.py single
```

It will download the lib, then you should see with the 'test' option a LED blink, then the "single" option will allow you to capture a single line.


## Results

I've used this exact setup to get the lib examples ( https://github.com/kelu124/pyUn0-lib ).
* [Raw files are here](https://github.com/kelu124/pyUn0-lib/tree/master/data)
* [Images here]()

Example of an acq : 

![](https://raw.githubusercontent.com/kelu124/pyUn0-lib/master/images/20191123a-1.jpg)

with a clean spectrum: 

![](https://raw.githubusercontent.com/kelu124/pyUn0-lib/master/images/20191123a-1-fft.jpg)
