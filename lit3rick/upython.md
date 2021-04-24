---
layout: default
title: uPython
parent: lit3rick
nav_order: 5
---

# What?

A small core to play with micropython on the lit3rick


# Install

Check the [content in the repo](https://github.com/kelu124/lit3rick/tree/master/micropython). To install board the SoC and the firmware, execute the following commands (once the lit3prog program is installed):

```
./creset.sh
./flash_picosoc.sh
./flash_firmware.sh
./reset

```

and to connect

```
sudo picocom -b9600 /dev/ttyS0
```

## Screenshot

Logging in being like:

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/images/micropython.png)

## Configuration notes

[On RPi4](https://www.editions-eni.fr/open/mediabook.aspx?idR=95a74a203820b0ab4eb45008abcaa14f), serial needs to be activated, but not to get a shell to the Pi, using `raspi-config`. Then, to activate UART 5, one needs to add the following to `/boot/config.txt` :

```
enable_uart=1 
dtoverlay=uart5
```

## Credits

* [Miodrag Milanović](https://github.com/mmicko/fpga101-workshop/tree/master/tutorials/12-RiscV) for his awesome work on the fpga101 workshop (one of my first time playing with a lattice =) ).
* [Claire Wolf](https://github.com/cliffordwolf/picorv32) - for the picorv32 but most of all for all that goes with it =)
* Bogdan - thanks mate!

