---
layout: default
title: Welcome!
nav_order: 1
---

[![Patreon](https://img.shields.io/badge/patreon-donate-orange.svg)](https://www.patreon.com/kelu124) [![Kofi](https://badgen.net/badge/icon/kofi?icon=kofi&label)](https://ko-fi.com/G2G81MT0G) [![Slack](https://badgen.net/badge/icon/slack?icon=slack&label)](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow) [![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org)

{: .highlight }
If you are coming for the original echomods, pic0rick or lit3rick projects, you can find them back in the references section. This site now focuses on the latest (and supported) project.

# Open-source ultrasound hardware for education, research, and NDT

The `un0rick` project provides affordable, open-source ultrasound pulse-echo hardware — designed for learning, prototyping, and non-destructive testing. The project has been actively developed since 2016 and is used by researchers, students, and makers worldwide.

The current board is the **[pic0rick](http://un0rick.cc/pic0rick)** — an RP2040-based design that delivers 60 Msps, 10-bit acquisition with no FPGA expertise required.

![pic0rick board](https://cdn.tindiemedia.com/images/resize/Kn3s65qieAvQ6NCM_oXqx2dLEXg=/p/full-fit-in/2336x1752/i/17175/products/2025-01-08T20%3A52%3A36.763Z-20240406_153634.jpg?1736340770)

---

## Where do you want to start?

| I want to... | Go here |
|---|---|
| **Learn and build my first echo** | [Get started](http://un0rick.cc/getting-started) — everything you need to go from zero to your first ultrasound acquisition |
| **Evaluate this for research** | [Research](http://un0rick.cc/research) — 30+ citing papers, BibTeX entries, and a community map |
| **Use this for NDT or prototyping** | [pic0rick specs](http://un0rick.cc/pic0rick) — hardware specs, block diagram, and board comparison |
| **See what others have built** | [Use cases](http://un0rick.cc/use_cases) — pulse-echo, tomography, NDT, array imaging |

---

## The project at a glance

| | |
|---|---|
| **Active since** | 2016 (nearly a decade) |
| **Current board** | [pic0rick](http://un0rick.cc/pic0rick) — RP2040/RP2350, 60 Msps ADC, 10-bit |
| **Citing papers** | [30+ academic publications](http://un0rick.cc/research) |
| **Certification** | [Open Source Hardware (OSHWA)](http://certificate.oshwa.org/certification-directory/) |
| **License** | TAPR OHL (hardware), GPLv3 (software), CC BY-SA 3.0 (docs) |
| **Community** | [Slack](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow) · [Matrix](https://app.element.io/#/room/#un0rick:matrix.org) · [GitHub](https://github.com/kelu124/pic0rick/) |

---

## The journey to pic0rick

The project has evolved through several hardware iterations, each solving a specific problem:

| Year | Board | What it solved |
|---|---|---|
| 2016 | [Murgen](http://un0rick.cc/murgen) | First integrated board — proved the concept |
| 2016–2018 | [echOmods](http://un0rick.cc/modules) | Modular breadboard approach — hackable but noisy |
| 2018–2025 | [un0rick](http://un0rick.cc/un0rick) | First FPGA board (iCE40 HX4K/HX8K) — 64 Msps, great timing, but complex |
| 2020–2024 | [lit3rick](http://un0rick.cc/lit3rick) | Smaller RPi pHAT format (iCE40 UP5K) — cheaper, no onboard HV |
| 2021–2024 | [lit3-32](http://un0rick.cc/lit3-32) | High-gain variant with AD8332 — 92 dB, for weak signals |
| 2024–now | **[pic0rick](http://un0rick.cc/pic0rick)** | **RP2040-based — no FPGA, Arduino-like, lowest cost and complexity** |

Each older board is documented under [Legacy boards](http://un0rick.cc/older). For new projects, we recommend the **pic0rick**.

---

## What can you build with this?

The hardware is designed for pedagogical and prototyping purposes. Common applications include:

* **Pulse-echo / A-mode imaging** — the core use case ([details](http://un0rick.cc/UseCase/pulse_echo))
* **Non-destructive testing** — crack detection, material characterization ([details](http://un0rick.cc/UseCase/NDT))
* **Ultrasound tomography** — transmission and reflection modes ([details](http://un0rick.cc/UseCase/tomo))
* **Array imaging** — synthetic aperture beamforming with the MUX PMOD extension
* **Transducer characterization** — test and evaluate piezoelectric probes ([compatible probes](http://un0rick.cc/probes))
* **Signal processing research** — a flexible platform for new methods

![Example acquisition](https://github.com/kelu124/pic0rick/raw/main/software/imgs/pico_shell/pic0gain_at_6.jpg)

---

## Who uses this hardware?

Contributors and users span multiple continents and disciplines.

![Community map](https://raw.githubusercontent.com/kelu124/echomods/master/include/community/map.jpg)

Want to join? Check the [community page](http://un0rick.cc/partners), or come chat on [Slack](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow) or [Matrix](https://app.element.io/#/room/#un0rick:matrix.org).

---

## Why open-source ultrasound?

NDT and imaging ultrasound have been around since the 1950s. Many open-source projects focus on image processing, but hardware has been left behind. Commercial ultrasound dev kits exist but are expensive and closed.

*I couldn't find designs to play with that would be affordable or open, so I decided to make one — for makers, researchers, and hackers.*

---

## Articles

The hardware designs have been documented in openly accessible publications:

* [Arduino-like development kit for single-element ultrasound imaging](https://doi.org/10.5334/joh.2) (JOH, 2016)
* [Review of current simple ultrasound hardware considerations, designs, and processing opportunities](https://doi.org/10.5334/joh.28) (JOH, 2022)
* [A rp2040-based ultrasound pulse-echo acquisition device](https://doi.org/10.5281/zenodo.10968503) (Zenodo, 2024)

See the full list of [30+ citing papers](http://un0rick.cc/research).

---

## Disclaimer

This project is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.

* This is **not** a medical ultrasound scanner. It is a development kit for pedagogical and academic purposes, with possible use as a non-destructive testing tool.
* As with all electronics, be careful — especially with high-voltage components.
* Ultrasound raises questions. If you build a scanner, use caution and good sense.



## License

This work is based on a previous TAPR project, the [pic0rick project](https://github.com/kelu124/pic0rick), the [echOmods project](https://github.com/kelu124/echomods/). The [un0rick project](https://github.com/kelu124/un0rick), the [lit3rick project](https://github.com/kelu124/lit3rick) and their boards are open hardware and software, developped with open-source elements, as much as possible.

Copyright Kelu124 (kelu124@gmail.com) 2018-2025

* The hardware is licensed under TAPR Open Hardware License (www.tapr.org/OHL)
* The software components are free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
* The documentation is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).
