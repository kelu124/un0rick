---
layout: default
title: Licenses
nav_order: 11
---

# Licenses

## Why licenses matter for this project

The un0rick project exists because affordable, open ultrasound hardware didn't. When we started in 2016, the available options were either closed commercial instruments costing thousands of dollars, or academic prototypes with no clear terms for reuse. The whole point was to make something anyone could study, modify, build on, and share.

But "open" without a license isn't really open — it's ambiguous. Without explicit legal terms, anyone who builds on your work is taking a legal risk. Researchers can't confidently integrate unlicensed hardware into funded projects. Companies can't evaluate whether they can use or adapt the design. Even fellow makers can't be sure they're allowed to share their modifications.

That's why every part of the un0rick project carries a specific, well-established open license:

* **Hardware designs** (schematics, PCB layouts, mechanical drawings) are licensed under the **TAPR Open Hardware License v1.0** — a license purpose-built for physical artifacts, because copyright licenses like the GPL don't cleanly cover the act of *manufacturing a thing* from a design.
* **Software and firmware** (Python libraries, C/C++ firmware, scripts) are licensed under the **GNU General Public License v3.0** — the standard copyleft license for software, ensuring that modifications remain open.
* **Documentation** (this website, guides, articles, images) is licensed under the **Creative Commons Attribution-ShareAlike 3.0 Unported License** — allowing free reuse and adaptation with attribution.

This three-license structure is common in open hardware projects and is recommended by organizations like [OSHWA](https://www.oshwa.org/) and [CERN](https://ohwr.org/project/cernohl/wikis/home). It ensures that every layer of the project — the physical design, the code that runs on it, and the knowledge around it — is explicitly free to use, study, modify, and share.

### What this means in practice

**If you want to use the hardware for research or education**: You can. Build it, use it, publish your results. Cite the relevant [publications](http://un0rick.cc/research) and you're good.

**If you want to modify the hardware**: You can. Make your changes, but license your modified designs under the same TAPR OHL terms, and make a good-faith effort to share your modifications with the original developers (an email to [kelu124@gmail.com](mailto:kelu124@gmail.com) is sufficient).

**If you want to build and sell products based on the design**: You can. The TAPR OHL allows commercial use, provided you include the documentation or make it available, and license derivative hardware under the OHL.

**If you want to use the software in your own project**: You can, under the terms of the GPLv3. If you distribute modified software, you must also distribute the source under GPLv3.

**If you want to reuse the documentation or images**: You can, under CC BY-SA 3.0. Attribute the original author and share your adapted documentation under the same license.

---

## Open Source Hardware certification

The un0rick-family boards are certified by the [Open Source Hardware Association (OSHWA)](https://www.oshwa.org/):

| Board | OSHWA UID | Link |
|---|---|---|
| un0rick | FR000005 | [Certificate](https://certification.oshwa.org/fr000005.html) |
| lit3rick | FR000006 | [Certificate](https://certification.oshwa.org/fr000006.html) |

OSHWA certification means the hardware meets the [Open Source Hardware Definition](https://www.oshwa.org/definition/) — the design files are publicly available, the license permits study, modification, distribution, and manufacture, and the hardware has been made using open tools as much as possible.

---

## License details

### Hardware: TAPR Open Hardware License v1.0

**Applies to**: All KiCad schematics, PCB layouts, Gerber files, and mechanical design files for the pic0rick, un0rick, lit3rick, lit3-32, echOmods, and Murgen boards.

**Full text**: [TAPR_Open_Hardware_License_v1.0.pdf](https://files.tapr.org/OHL/TAPR_Open_Hardware_License_v1.0.pdf) (also available in [ODF](https://files.tapr.org/OHL/TAPR_Open_Hardware_License_v1.0.odt) and [TXT](https://files.tapr.org/OHL/TAPR_Open_Hardware_License_v1.0.txt))

**Summary of key terms** (from the OHL preamble — the numbered sections of the license take precedence):

* You may modify the documentation and make products based upon it.
* You may use products for any legal purpose without limitation.
* You may distribute unmodified documentation, but you must include the complete package as you received it.
* You may distribute products you make to third parties, if you either include the documentation on which the product is based, or make it available without charge for at least three years to anyone who requests it.
* You may distribute modified documentation or products based on it, if you:
  * License your modifications under the OHL.
  * Include those modifications, following the requirements stated in the license.
  * Attempt to send the modified documentation by email to the original developers (good faith obligation — if the email fails, you need do nothing more).
* If you create a design that you want to license under the OHL, include the OHL document in a file named LICENSE.TXT and a copyright notice in each file.

**Why TAPR OHL and not GPL for hardware?** Copyright protects documentation from unauthorized copying, but it has little to do with your right to *make, distribute, or use a physical product* based on that documentation. The TAPR OHL was specifically designed to address the unique legal issues involved in creating tangible physical things. It does not cover software or firmware — those are licensed separately under the GPL.

For legal background, see John Ackermann's article [*Toward Open Source Hardware*](https://web.tapr.org/Ackermann_Open_Source_Hardware_Article_2009.pdf) (34 U. Dayton L. Rev. 183, 2009).

---

### Software: GNU General Public License v3.0

**Applies to**: All firmware (RP2040 C/C++ code), Python libraries (pyUn0, py_fpga, pico_shell), acquisition scripts, signal processing code, and FPGA gateware (Verilog) for all boards.

**Full text**: [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html)

**Summary of key terms**:

* You are free to run the software for any purpose.
* You are free to study how the software works and modify it.
* You are free to redistribute copies.
* You are free to distribute copies of your modified versions to others.
* If you distribute modified versions, you must also distribute the source code under GPLv3, ensuring that recipients have the same freedoms you received.
* The software is distributed without warranty.

The GPLv3 is a *copyleft* license: it requires that derivative works also be licensed under GPLv3. This ensures that improvements to the software remain available to the community.

---

### Documentation: Creative Commons Attribution-ShareAlike 3.0 Unported

**Applies to**: This website (un0rick.cc), all documentation pages, guides, tutorials, images, diagrams, and articles authored by the un0rick team.

**Full text**: [https://creativecommons.org/licenses/by-sa/3.0/](https://creativecommons.org/licenses/by-sa/3.0/)

**Summary of key terms**:

* **Attribution** — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
* **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
* You are free to share (copy and redistribute) and adapt (remix, transform, and build upon) the material for any purpose, including commercial use, under the above conditions.

---

### Exception: AD8332 dev board (CERN-OHL-S v2)

The [AD8332 development board](http://un0rick.cc/ad8332) is licensed under the **CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S v2)** rather than the TAPR OHL. This is because it was co-developed with a contributor who preferred the CERN license.

**Full text**: [https://ohwr.org/cern_ohl_s_v2.txt](https://ohwr.org/cern_ohl_s_v2.txt)

The CERN-OHL-S v2 is functionally similar to the TAPR OHL — it is a strong reciprocal hardware license that requires derivative works to be licensed under the same terms. The key differences are administrative (different notification requirements and source location obligations).

```
 SPDX-FileCopyrightText: 2020 Jorge Arija, Luc Jonveaux
 SPDX-License-Identifier: CERN-OHL-S-2.0
```

If you produce hardware based on the AD8332 dev board design, you must maintain the source location visible on the external case of the product where practicable (per CERN-OHL-S v2 section 4).

---

## Copyright

Copyright Luc Jonveaux / Kelu124 ([kelu124@gmail.com](mailto:kelu124@gmail.com)) 2016–2025.

Individual contributions by other authors retain their respective copyrights and are licensed under the same terms as the component they contribute to (hardware under TAPR OHL, software under GPLv3, documentation under CC BY-SA 3.0), unless otherwise noted.

---

## Disclaimer

This project is distributed **WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE**. See the GNU General Public License and the TAPR Open Hardware License for more details.

This is **not** a medical ultrasound scanner. It is a development kit for pedagogical and academic purposes, with possible immediate use as a non-destructive testing (NDT) tool. As with all electronics, be careful — especially with high-voltage components.

---

