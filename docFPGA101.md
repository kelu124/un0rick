# Setting up the board

## How to connect

1. Use the Rpi or Computer to connect to the FPGA
2. __Setup the jumper__ according to SPI master choice (USB or Rpi)
3. __Power up__ via a USB cable
4. __Configuration of the acquisition__: send to FPGA the configuration registers via SPI 
5. Set the register _EF_ to initiliaze memory (read and write pointers at 0)
6. __Start the acquisition__, triging it up using the software, or with the onboard hardware trig button
7. Do _one SPI transaction_ and ignore the data received
8. Read the measures via SPI


## How to update the FPGA

1. Use a PC with (for example) diamond programmer
2. Setup the the jumper for FPGA update
3. Connect the USB
4. Program via (for example) the diamong programmer application
5. The LED program shall be ON when ok.


## FPGA setup

SPI is used to configure the DAC values every 5us, using the following addresses and protocol (SPI is only 8bits per CS).	
For each address:			
* Send __0xAA__ to access parameters
* Followed by Send __@__ the address over 8 bits
* Followed by Send __Data__, a parameter over 8 bits

Addresses start at 0xE0 and end at 0xD0 on the default bitstream.

## Details of adresses to setup the board

| Address 	| Name of variable 	| Size (bits) 	| Description                                	| Default value in hex 	| unit          	|  Value    	|
|---------	|------------------	|-------------	|--------------------------------------------	|----------------------	|---------------	|-----------	|
| 0xE0    	| sEEPon           	| 8           	| Lengh of Pon                               	| 0x14                 	| 10ns          	| 200 ns    	|
| 0xD0    	| sEEPonPoff       	| 8           	| Lengh between Pon and Poff                 	| 0x0A                 	| 10ns          	| 100 ns    	|
| 0xE1    	| sEEPoff          	| 8           	| Lengh of Poff MSB                          	|                      	|               	|           	|
| 0xE2    	| sEEPoff          	| 8           	| Lengh of Poff LSB                          	| 0xC8                 	| 10ns          	| 2000 ns   	|
| 0xE3    	| sEEDelayACQ      	| 8           	| Lengh of Delay between Poff and Acq MSB    	| 0x02BC               	| 10ns          	| 7000 ns   	|
| 0xE4    	| sEEDelayACQ      	| 8           	| Lengh of Delay between Poff and Acq LSB    	|                      	|               	|           	|
| 0xE5    	| sEEACQ           	| 8           	| Lengh of acquisition MSB                   	| 0x32C8               	| 10ns          	| 130 us    	|
| 0xE6    	| sEEACQ           	| 8           	| Lengh of acquisition LSB                   	|                      	|               	|           	|
| 0xE7    	| sEEPeriod        	| 8           	| Period of one cycle MSB                    	| 0x186A0              	| 10ns          	| 1 ms      	|
| 0xE8    	| sEEPeriod        	| 8           	| Period of one cycle 15 to 8                	|                      	|               	|           	|
| 0xE9    	| sEEPeriod        	| 8           	| Period of one cycle LSB                    	|                      	|               	|           	|
| 0xEA    	| sEETrigInternal  	| 1           	| Software Trig : Auto clear                 	| 0                    	| N/A           	|           	|
| 0xEB    	| sEESingleCont    	| 1           	| 0: single mode 1 continious mode           	| 0                    	| N/A           	|           	|
| 0xEC    	| sEEDAC           	| 8           	| Voltage gain control: 0V to 1V             	| 0x11                 	| 0,004         	| 68 mV     	|
| 0xED    	| sEEADC_freq      	| 8           	| Frequency of ADC acquisition               	| 0x03                 	|  64/(1+f) MHz 	| 16 MHz    	|
| 0xEE    	| sEETrigCounter   	| 8           	| How many cycles in countinious mode        	| 0x0A                 	| cycles        	| 10 cycles 	|
| 0xEF    	| sEEpointerReset  	| 1           	| Sofware memory reset: set to 1; auto clear 	| 0                    	|               	|           	|

## How to read from the FPGA

SPI is used to read the ADC value. SPI in the case of the basic program is only 8 bits per CS.	

Master send 0. If the FPGA is doing an acquisition, the returned value is 0xAA, else the value is on 2x8 bits.

* MSB					
  * 8th bit: MSB ID: set to 1
  * 6-7th bit: cycle bits: to identify a line in a sequence
  * 4-5th bits: the two inputs (TopTurn 1 and TopTurn2) in case a counter is used.
  * 1st-3th bits: ADC 7 to 9: 3 remaining bits of acquisition
* LSB	
  * 8th bit: LSB ID: set to 0 
  * 1st to 7th bits: ADC 7-0: 7 first bits of acquisition

If the master reads more data than the board has acquired, SPI will return old or incorrect values: the master has to know how many measures were done.


## DAC Configuration

SPI is used to configure the DAC values every 5us, using the following addresses and protocol (SPI is only 8bits per CS).	
For each address:			
* Send __0xAA__ to access parameters
* Followed by Send __@__ the address over 8 bits
* Followed by Send __Data__, a parameter over 8 bits

Addresses start at 0x10 and end at 0x38. This corresponds to t = 0us for 0x10, and t = 200us for 0x38. __Data__ range from 0 to 8 bits for full amplification.


