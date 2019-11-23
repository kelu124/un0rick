# How to setup the board using only a raspberry pi 4


## Installing iceprog

iceprog is the software used to put the fpga on the flash storage on the board, which will be read by the fpga on boot.

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

Then, plug an usb cable from the RPi to the board (not connected using the raspberry pi header), check that the FTDI device is well created by typing:

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

## Running an acquisition

Then, for example to discover the board using Python, you can use the library:

```
git clone git@github.com:kelu124/pyUn0-lib.git
cd pyUn0-lib
python pyUn0.py test
python pyUn0.py single
```

It will download the lib, then you should see with the 'test' option a LED blink, then the "single" option will allow you to capture a single line.
