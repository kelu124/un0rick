---
layout: default
title: Legacy boards
nav_order: 9
has_children: true
---

# Legacy boards

{: .warning }
> **For new projects, we recommend the [pic0rick](http://un0rick.cc/pic0rick).** It offers comparable performance with much simpler tooling — no FPGA experience required. The boards below are no longer actively developed but remain fully documented.

The un0rick project has gone through several hardware iterations since 2016. Each board solved specific problems and pushed the design forward. If you already own one of these boards, the documentation and setup guides below are still maintained.

---

## Board timeline

| Board | Years | Controller | Key feature | Status |
|---|---|---|---|---|
| [Murgen](http://un0rick.cc/murgen) | 2016 | Discrete components | First proof of concept | Archived |
| [echOmods](http://un0rick.cc/modules) | 2016–2018 | Modular (breadboard) | Hackable, individual stages separated | Archived |
| [un0rick](http://un0rick.cc/un0rick) | 2018–2025 | iCE40 HX4K/HX8K | First integrated FPGA board, 64 Msps, onboard HV | Legacy — documented |
| [lit3rick](http://un0rick.cc/lit3rick) | 2020–2024 | iCE40 UP5K | RPi pHAT format, smaller and cheaper | Legacy — documented |
| [lit3-32](http://un0rick.cc/lit3-32) | 2021–2024 | iCE40 UP5K + AD8332 | 92 dB gain for weak signal detection | Legacy — documented |
| **[pic0rick](http://un0rick.cc/pic0rick)** | **2024–now** | **RP2040/RP2350** | **No FPGA, Arduino-like, lowest cost** | **Active** |

---

## un0rick (iCE40 HX4K/HX8K)

![un0rick board](https://raw.githubusercontent.com/kelu124/un0rick/master/images/un0rick_black.png)

The un0rick was the first integrated FPGA board in the project. It consolidated the best of the earlier echOmods modules into a single PCB with a Lattice iCE40 HX4K or HX8K FPGA, achieving up to 64 Msps sampling with precise FPGA-controlled timing.

| Parameter | Value |
|---|---|
| FPGA | Lattice iCE40 HX4K or HX8K |
| ADC | 64 Msps, 10-bit (interleaved to 128 Msps) |
| RAM | External 8 Mb |
| TGC | AD8331 (7.5–55.5 dB) |
| Onboard HV | Yes — 0, 24, 48, or 72 V selectable |
| Pulser | Unipolar, 0–100 V |
| Interface | USB (FTDI) or 40-pin RPi header |
| OSHWA | [FR000005](https://certification.oshwa.org/fr000005.html) |

**Why you might still use it**: Full FPGA flexibility for custom gateware, onboard high voltage (no separate HV board needed), higher pulse voltage than the pic0rick, and USB interface via FTDI chip.

**Documentation**:
* [un0rick hardware details](http://un0rick.cc/un0rick/hardware)
* [Raspberry Pi setup](http://un0rick.cc/un0rick/rpi-setup)
* [USB setup](http://un0rick.cc/un0rick/usb-setup)
* [Experiments](http://un0rick.cc/un0rick/experiments)
* [128 Msps interleaved mode](http://un0rick.cc/un0rick/128msps)
* [M5Stack connection](http://un0rick.cc/un0rick/m5stack)
* [Dual NDT setup](http://un0rick.cc/un0rick/ndt)
* [GitHub repository](https://github.com/kelu124/un0rick)

---

## lit3rick (iCE40 UP5K)

![lit3rick board](https://raw.githubusercontent.com/kelu124/lit3rick/master/images/top.jpg)

The lit3rick simplified the un0rick design into a Raspberry Pi pHAT form factor using an iCE40 UP5K FPGA. Smaller and cheaper, but without onboard high voltage — the HV source must be provided externally.

| Parameter | Value |
|---|---|
| FPGA | Lattice iCE40 UP5K |
| ADC | 64 Msps, 12-bit |
| RAM | Internal 1 Mb (UP5K SPRAM) |
| TGC | AD8331 (7.5–55.5 dB) |
| Onboard HV | No — external 5 V supply, HV provided separately |
| Pulser | Bipolar, -100 V to +100 V |
| Interface | Raspberry Pi GPIO (SPI) |
| OSHWA | [FR000006](https://certification.oshwa.org/fr000006.html) |

**Why you might still use it**: RPi pHAT integration, bipolar pulser with higher voltage range, and 12-bit ADC resolution.

**Documentation**:
* [lit3rick introduction and uses](http://un0rick.cc/lit3rick/intro)
* [Board setup](http://un0rick.cc/lit3rick/setup)
* [py_fpga library](http://un0rick.cc/lit3rick/lib)
* [Benchmarking](http://un0rick.cc/lit3rick/benchmark)
* [MicroPython support](http://un0rick.cc/lit3rick/upython)
* [Experiments](http://un0rick.cc/lit3rick/questions)
* [GitHub repository](https://github.com/kelu124/lit3rick)

---

## lit3-32 (iCE40 UP5K + AD8332)

A variant of the lit3rick with upgraded gain amplifiers. The AD8332 dual VGA provides up to 92 dB of gain, making this board the best choice for detecting very weak signals (e.g. highly attenuating materials, deep targets, or small defects).

| Parameter | Value |
|---|---|
| FPGA | Lattice iCE40 UP5K |
| TGC | AD8332 (up to 92 dB total gain) |
| Interface | Raspberry Pi GPIO (SPI) |
| Origin | Co-developed with the [National Research Council of Canada](https://nrc.canada.ca/en) |

**Why you might still use it**: Best gain performance in the family — essential for weak signal detection where the pic0rick's 48 dB AD8331 range is insufficient.

**Documentation**:
* [lit3-32 overview](http://un0rick.cc/lit3-32/overview)
* [AD8332 dev board details](http://un0rick.cc/ad8332)

---

## Murgen and echOmods (archived)

### Murgen (2016)

The very first board in the project. A single integrated PCB that proved the concept of affordable open-source ultrasound acquisition. No longer in production, but historically significant as the project's starting point.

[Murgen documentation →](http://un0rick.cc/murgen)

### echOmods (2016–2018)

A modular approach where each stage of the ultrasound signal chain (pulser, TGC, ADC, DAC, etc.) lived on a separate breadboard-style module. This made it easy to experiment with individual components, at the cost of more noise from the breadboard connections.

The echOmods concept directly informed the design of the integrated un0rick board.

[echOmods documentation →](http://un0rick.cc/modules)

---

## The iCE40 FPGA ecosystem

Both the un0rick and lit3rick boards use the Lattice iCE40 FPGA family, which is notable for being fully supported by open-source synthesis tools:

* **[Project IceStorm](http://www.clifford.at/icestorm/)** — reverse-engineered bitstream format and open-source synthesis/place-and-route
* **[Yosys](http://www.clifford.at/yosys/)** — open-source Verilog synthesis
* **[nextpnr](https://github.com/YosysHQ/nextpnr)** — open-source place-and-route

This means the entire hardware and software toolchain for these boards is open source — from the KiCad PCB design files to the FPGA gateware synthesis.

For a comprehensive list of iCE40-based projects, see the [awesome-latticeFPGAs](https://github.com/kelu124/awesome-latticeFPGAs) curated list.

---

## Migrating to pic0rick

If you are currently using an un0rick or lit3rick board and considering switching to the pic0rick:

**What you gain**: Simpler development (C/C++ instead of Verilog), faster iteration, lower cost, PMOD extensibility (VGA, MUX, PSRAM), no FPGA synthesis toolchain needed.

**What you lose**: Direct FPGA timing control (PIO is close but not identical), onboard HV (need separate HV board), and the lit3-32's 92 dB gain range (pic0rick has 48 dB via AD8331).

**Python code compatibility**: The Python acquisition scripts are different between the FPGA boards (SPI-based) and the pic0rick (USB serial). However, the data format and processing pipeline (FFT, envelope extraction, TGC curves) remain the same.

For a full spec comparison, see the [board comparison table on the pic0rick page](http://un0rick.cc/pic0rick#board-comparison).

---

## License

All legacy boards are open source:

* Hardware: TAPR Open Hardware License (www.tapr.org/OHL)
* Software: GPLv3
* Documentation: CC BY-SA 3.0