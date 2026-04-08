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



# Other references

This section collects component-level notes, breakout boards, curated links, and software tools developed alongside the un0rick project. These are useful if you are designing your own ultrasound hardware, debugging analog front-end issues, or looking for background reading.

---

## Component breakout boards

Development boards designed and tested as part of the un0rick ecosystem. These are standalone boards that can be used independently or integrated with un0rick-family hardware.

### AD8332 dual-VGA dev board

A development board for the Analog Devices AD8332 dual variable-gain amplifier. Provides up to 92 dB of gain — used in the [lit3-32](http://un0rick.cc/lit3-32) board variant.

* **Gain range**: -4.5 dB to +43.5 dB per channel (dual channel: up to ~92 dB total)
* **Input filter**: Three 1206 footprints (one serial, two parallel to input signal) — easy to swap components
* **Output filter**: 20 MHz LPF using 0603 SMD parts — replaceable with hot air station and tweezers
* **Source**: [GitHub repository](https://github.com/kelu124/AD8332-devboard)

![AD8332 test board](https://github.com/kelu124/AD8332-devboard/raw/main/tests/ad8332_test_board.jpg)

Test results show clean gain response across the control range:

![AD8332 gain curve](https://github.com/kelu124/AD8332-devboard/raw/main/tests/gain.png)

[Full details →](http://un0rick.cc/ad8332)

---

### FT600 USB 3.0 PMOD

A PMOD board based on the FTDI FT600 chip, providing USB 3.0 data transfer capability. Originally designed as a high-speed data path for FPGA-based un0rick boards.

* **Interface**: USB 3.0 (up to 200 MB/s theoretical)
* **Form factor**: PMOD compatible
* **Source**: [GitHub repository](https://github.com/kelu124/ft600)

[Full details →](http://un0rick.cc/ft600)

---

### MAX14866 multiplexer

A multiplexer board based on the Maxim MAX14866, used for switching between multiple transducer elements. Enables array imaging by sequentially connecting different elements to the TX/RX path.

* **Channels**: Up to 16 elements (shared TX/RX) or 8 elements (separate TX/RX)
* **HV tolerant**: Designed for high-voltage ultrasound pulses
* **Source**: [GitHub repository](https://github.com/kelu124/max14866)

[Full details →](http://un0rick.cc/max14866)

---

## High-voltage power supply designs

Several HV supply designs were developed during the project for generating the transmit pulse voltage:

| Design | Output | Input | Notes | Repository |
|---|---|---|---|---|
| **pic0rick HV board** | +-25 V | 5 V (USB) | Recommended for pic0rick | Included in [pic0rick repo](https://github.com/kelu124/pic0rick/) |
| **LM3478 boost** | +-90 V (adjustable 80–200 V) | 5 V | Higher voltage for deeper penetration | [GitHub](https://github.com/kelu124/lm3478) |
| **HV9150** | Adjustable HV output | 5 V | Alternative HV source | [GitHub](https://github.com/kelu124/HV9150DevKit) |
| **DRV8662** | 250 V unipolar | 5 V | Minimal BOM cost | [GitHub](https://github.com/kelu124/DRV8662-devkit) |
| **HV general tests** | Various | Various | MAX1846 and HV9150 comparison | [GitHub](https://github.com/kelu124/hvpppn) |

---

## Software tools

### pyusbus — Python APIs for USB ultrasound probes

![GitHub repo size](https://img.shields.io/github/repo-size/kelu124/pyusbus?style=plastic) ![GitHub last commit](https://img.shields.io/github/last-commit/kelu124/pyusbus?color=red&style=plastic)

* **Repository**: [github.com/kelu124/pyusbus](https://github.com/kelu124/pyusbus) (27 stars)
* **License**: GPLv3

A number of USB ultrasound probes exist on the consumer market — compact, affordable devices that could be powerful research and education tools. The problem is that their communication protocols are locked behind proprietary drivers, and vendors rarely open their SDKs beyond basic image display.

**pyusbus** is a Python library that reverse-engineers the USB communication of these probes, providing an open API to acquire raw ultrasound frames directly. The goal is to get images from a USB probe in three lines of code:

```python
import pyusbus as usbProbe
probe = usbProbe.UP20()
frames = probe.getImages(n=10)  # returns 10 frames
```

#### Supported probes

| Probe | Type | API class | Notes |
|---|---|---|---|
| **Interson SeeMore** | Mechanical (single-element, motor-driven) | `usbProbe.Interson()` | Variable image width depending on motor speed. Based on [Kitware's IntersonManager](https://github.com/KitwareMedical/IntersonManager) references |
| **BMV Convex** | Convex array | `usbProbe.CONV()` | Returns RF signals (not just envelope) — useful for research |
| **Linear HP20L** | Linear array (B-mode) | `usbProbe.UP20()` | Returns envelope data with correct distance markers (mm) |
| **BMV Doppler** | Linear array (B-mode + Doppler) | `usbProbe.DOPPLER()` | Supports both B-mode and Doppler acquisition modes |

![pyusbus acquisition demo — vein phantom and forearm](https://github.com/kelu124/pyusbus/raw/main/experiments/streamlit/capture.gif)

#### Installation

```bash
git clone https://github.com/kelu124/pyusbus.git
cd pyusbus
bash build.sh
bash install.sh
```

On Linux, you need to set up udev rules so the probes are accessible without root. A `rules.d.sh` script is included in the repository. You may also need to add your user to the `dialout` group.

#### Why this matters

Having open drivers for USB ultrasound probes benefits both probe users (by providing an easy-to-use API with access to raw data) and researchers (by providing insights into probe internals that are normally hidden). The raw RF data from the BMV Convex probe, for example, opens up signal processing experiments that are impossible with the vendor's display-only software.

Not all probe features are fully mapped yet — this is an active reverse-engineering effort. Contributions and bug reports are welcome on [GitHub](https://github.com/kelu124/pyusbus/issues).

#### Related: pyUProbe1

* **[pyUProbe1](https://github.com/kelu124/pyUProbe1)** (15 stars) — A separate Python library for the uProbe-1 ultrasound probe. Similar approach, different probe hardware.

### Signal processing

* **[us_rf_processing](https://github.com/kelu124/us_rf_processing)** — An introduction to ultrasound signal processing with raw RF data. Covers envelope extraction, FFT analysis, time-gain compensation, and basic scan conversion. Good starting point for understanding what to do with the raw data from the board.

---

## Curated links

### Experiments and tutorials

* [Impedance matching experiments (20201108a)](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201108a.md)
* [Testing VNA on different piezos (20201219r)](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20201219r.md)
* [Using different compressions](https://github.com/kelu124/echomods/blob/master/include/experiments/auto/20200421b.md)
* [Older hardware: playing with modules on a Raspberry Pi](https://kelu124.gitbooks.io/echomods/content/RPI.html)

### Videos

* [40-pin header to Raspberry Pi demo](https://www.youtube.com/watch?v=rv-Ag_TcnP8) — un0rick board connected via ribbon cable
* [Streamlit webapp demo](https://www.youtube.com/watch?v=CsLhFRVoXY4) — using a web application for acquisition control

### Research bibliography

* [Full bibliography](https://github.com/kelu124/echomods/blob/master/include/biblio/bib/AllRefs.md) — comprehensive collection of references related to the project
* [Academic publications citing un0rick](http://un0rick.cc/research) — 30+ papers

### Related open-source projects

* [wlmeng11's SimpleRick](https://github.com/wlmeng11/SimpleRick) — analog front-end board for ultrasound
* [awesome-latticeFPGAs](https://github.com/kelu124/awesome-latticeFPGAs) — curated list of Lattice FPGA boards using open-source tools (350+ stars)
* [Project IceStorm](http://www.clifford.at/icestorm/) — reverse-engineered iCE40 FPGA toolchain used by the un0rick and lit3rick boards

---

## Other related hardware

### Analog front-end

* **[Dhvani (MAX2082)](https://github.com/kelu124/Dhvani)** — a board based on the MAX2082 ultrasound AFE. Alternative analog front-end approach.

### echOmods (legacy modular system)

The original modular breadboard components that preceded the integrated boards. Each module handled one stage of the signal chain (pulser, TGC, ADC, etc.) on a separate board. Useful as a reference for understanding the signal chain in isolation.

* [Full module summary](https://github.com/kelu124/echomods/blob/master/include/AddModulesSummary.md)
* [echOmods documentation](http://un0rick.cc/modules)