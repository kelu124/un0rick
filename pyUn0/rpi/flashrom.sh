./gpio.sh
flashrom -p linux_spi:dev=/dev/spidev0.1,spispeed=2048
./creset.sh
