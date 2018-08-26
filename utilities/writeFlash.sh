echo 22 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio22/direction

#GP23 is IceResetRPI
#GP22 is FlashResetRPi
#GP27 is FlashCDONE RPi
#D4 is CDONE (between LATTICE anf FTDI)
#D8 is POWER
flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=20000 -w flashBck.sav

echo in > /sys/class/gpio/gpio22/direction

echo 22 > /sys/class/gpio/unexport 
