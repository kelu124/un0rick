# Guide to flash on the RPi using the 40x2 header


1. Download this archive with `wget https://github.com/kelu124/un0rick/raw/master/pyUn0/rpi.zip` and unzip it on the Pi.
2. Make sure the pi is connected to the board, and that [the jumper located in this picture](https://raw.githubusercontent.com/kelu124/un0rick/master/images/program.jpg) is removed.
3. Compile the programmer by typing `Make` in the shell
4. Check the size of your flash by typing `./creset.sh` first and then `flashrom -p linux_spi:dev=/dev/spidev0.1,spispeed=2048`. It should yield the size of the flash. Edit then `createpadded.sh`, so that `cat v1.1.bin /dev/zero | dd bs=1024 count=2048 of=padded.bin` replacing 2048 with the size of your flash in kB. Run `createpadded.sh` to create a binary to flash your flash.
5. Program your board with `flashrom.sh`
6. Put back the jumper from [this picture](https://raw.githubusercontent.com/kelu124/un0rick/master/images/program.jpg).
7. And voilà! You can use your board with the `pyUn0.py` lib.
