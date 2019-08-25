# Looking for Verilog help

## Why I need help ?

I am looking for someone proficient in Verilog to write a Verilog boilerplate. It is centered around a up5k open-source board, designed to be used in conjunction with a rapsberry pi, that has to acquire 200us worth of signal on a trigger. Data is to be stored in RAM, and made available through SPI.

## The board

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/lit3.png)

and [schematics are here](https://github.com/kelu124/un0rick/raw/master/images/15626199370000-default.pdf).

## Details

As you will see in the schematics, at the heart is a up5k, used in conjunction with a few ICs:
* High voltage pulser (HV7361), that needs 3 variables to be controled, all in logic (schematics is PHV, pnHV, Pdamp)
* Dual output DAC (MCP4812) that needs to be driven to half value.
* Variable Gain Amplifier (AD8331) that is controled by the DAC, that has only one logic to be controled by the FPGA, through its HILO pin.
* Finally, the ADC used is a AD9629 (12bits, 65Msps)

For the operation of the board, and based on the schematics the following would be  :
* DaughterGPIO2 going low triggers a digitization for 200us from the ADC. Each sample can be stored on 2-byte words, as 1 sampling is 12bit ADC. The MSB word starts with 11, LSB starts with 00.
* The HV7361 PHV (default low) goes high for 200ns (approx), then back to low, waits 100ns, pnHV goes high for 200ns (approx), then low for 100ns, then Pdamp goes high for 2us.
* HILO needs to be connected to the daughter_GPIO01.
* After sampling for 200us at ideally 64Msps, (hence with 64x200x2 bytes in RAM). These values have to be read from the SPI using the SPI lines (MOSI, MISO, SCLK on the header), using the CS called RPI2ICE_CS.

In terms of indicators, RGB led indicator would be : 
* _Red_ for ready to start the 200us period
* _Green_ when 200 us acquisition is over
* _Blue_ when SPI master is reading the memory.

If interested, feel free to drop me a message at up5k@un0rick.cc !

## Focus on fpga connections

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/up5k_centered.png)
