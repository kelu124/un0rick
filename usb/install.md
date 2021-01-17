# Install guide

1. Connect the un0rick through usb 
2. program it with `iceprog usb.bin`
3. Run the `Readme.ipynb` jupyter notebook or simply:

```
import un0usb as USB # neeeds `pip3 install un0usb` before
fpga = USB.FpgaControl('ftdi://ftdi:2232:/', spi_freq=8E6) # init FTDI device 
fpga.reload() # reload configuration
fpga.reset() # reset fpga

file = fpga.stdNDTacq() # Running a standard NDT acquisition
plot = USB.FView() # Opens a viewing object
data = plot.readfile(file) # plots it
```

This will create images of your acquisition.


# Connecting to VGA

For this binary, you will need	
* IO1_RPI = GREEN (color of your choice really)
  * A 270 Ohm R should be inserted in series with the line.
* IO2_RPI = VSYNC
  * A 120 Ohm R should be inserted in series with the line.
* IO4_RPI = HSYNC
  * A 120 Ohm R should be inserted in series with the line.
* GND = GND

__Beware, IO3 seems not to be working on this bin__.




