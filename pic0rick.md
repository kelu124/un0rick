---
layout: default
title: pic0rick
nav_order: 5
---


![GitHub repo size](https://img.shields.io/github/repo-size/kelu124/pic0rick?style=plastic)
![GitHub language count](https://img.shields.io/github/languages/count/kelu124/pic0rick?style=plastic)
![GitHub top language](https://img.shields.io/github/languages/top/kelu124/pic0rick?style=plastic)
![GitHub last commit](https://img.shields.io/github/last-commit/kelu124/pic0rick?color=red&style=plastic)

[![Slack](https://badgen.net/badge/icon/slack?icon=slack&label)](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow)
[![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org)


# the _pic0rick_ project

[![Patreon](https://img.shields.io/badge/patreon-donate-orange.svg)](https://www.patreon.com/kelu124)
[![Kofi](https://badgen.net/badge/icon/kofi?icon=kofi&label)](https://ko-fi.com/G2G81MT0G)

The pic0rick is a very central board for an ultrasound pulse-echo system. It is composed of a main board, based on the famous rp2040 and easy to solder SMD, to which a single, and a double PMOD connector can connect to addons:

* The main board is equipped with a 60Msps, 10bit ADC. Front end is protected against high-voltage pulses, and features a proven time-gain compensation system consisting in a AD8331 (7.5 dB to 55.5dB) with a controlling (MCP4812) SPI DAC.
* The single PMOD connector can plug to the Pulser board, which can be equipped with a simple +-25V generation board. Together, they generate the pulse on behalf of the pic0rick main board. The setup can generate three-level pulses ( with a pair of MD1210 + TC6320 ).
* The double PMOD connector can be used for virtually anything. The current code allows for a VGA to be connected, which displays acquisitions from the board.

The current system uses both PIOs (one for the acquisition, the other for the VGA) which leaves the other resources of the rp2040 relatively free to use for your own priorities.

Published documents include:
* KiCad design files for the main board
* KiCad design files for the pulser + hv boards
* rp2040 firmware for the microcontroller.

I _know_ the PMODs aren't strictly speaking PMODs, I needed to have 5V facility on the header =)

And if you want to discuss the project - [meet us on our slack](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow).

# Setup

## The three boards assemble look like this

![](https://raw.githubusercontent.com/kelu124/pic0rick/refs/heads/main/documentation/images/20240406_153634.jpg)

## Example of acquisitions

![](https://raw.githubusercontent.com/kelu124/pic0rick/refs/heads/main/software/imgs/pico_shell/pic0gain_at_6.jpg)



# Along with the other boards

![](https://raw.githubusercontent.com/kelu124/pic0rick/refs/heads/main/documentation/images/sister_boards.png)

# Scheduled changes

## DONE

* FW: Tie the pulses to the PIO code so that pulses strictly cohappen with the acquisition start (done)

## TODO

* HW: Slight tweaks on the main board to allow more space for the PMODs (Oct 21, 2024)

# Thank you to

* Abdelrahman
* Lap

# License

This work is based on three previous TAPR projects, [the echOmods project](https://github.com/kelu124/echomods/), the [un0rick project](https://doi.org/10.5281/zenodo.377054), and the [lit3rick project](https://doi.org/10.5281/zenodo.5792245) - their boards are open hardware and software, developped with open-source elements as much as possible.

Copyright Luc Jonveaux (<kelu124@gmail.com>) 2024

* The hardware is licensed under TAPR Open Hardware License (<www.tapr.org/OHL>)
* The software components are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
* The documentation is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).

## Disclaimer

This project is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.