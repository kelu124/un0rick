---
layout: default
title: Older designs
nav_order: 30
has_children: true
---

# Older designs



## Two boards

For this project, I had developped a couple of boards, the [un0rick](un0rick.md) and the [lit3rick](lit3rick.md) boards, based on the hx4k and up5k lattice fpga, respectively. Both are open hardware certified (check for [un0rick](https://certification.oshwa.org/fr000005.html) and [lit3rick](https://certification.oshwa.org/fr000006.html) ).

### un0rick

![](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_black.png)

### lit3rick

![](https://raw.githubusercontent.com/kelu124/lit3rick/master/images/top.jpg)



### Comparing the two designs

They have their own specificities:

|                      	|                un0rick                	|        lit3rick        	|
|---------------------:	|:-------------------------------------:	|:----------------------:	|
|                 FPGA 	|               HX4K, HX8K              	|          UP5K          	|
| Onboard high voltage 	|             0, 24, 48, 72V            	|           5V           	|
|                  RAM 	|              External 8Mb             	|      Internal 1Mb      	|
|                  ADC 	| 64Msp, 10bits, interleaved at 128Msps 	|     64Msps 12 bits     	|
|  Amplification / VGA 	|                 AD8331                	|         AD8331         	|
|               Pulser 	|          Unipolar, 0 to 100V          	| Bipolar, -100V to 100V 	|
|                 Size 	|                 Larger                	|   Raspberry pHAT size  	|
|          USB capable 	|               Yes (FTDI)              	|           No           	|
|                      	|                                       	|                        	|
|                      	|                                       	|                        	|




## ice40 - a specificity

These two boards build in particular on the famouse ice40 FPGA family which is low-cost, ... and open-sourced.

It can use the "Project IceStorm", which aims at reverse engineering and documenting the bitstream format of Lattice iCE40 FPGAs and providing simple tools for analyzing and creating bitstream files.

There's a bit of action around these FPGAs these days, be it for tools, extensions, DIP designs,... and I thought using those for a ultrasound imaging device would permit to mix both FPGA and OpenSource.
