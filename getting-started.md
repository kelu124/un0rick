---
layout: default
title: Get started
nav_order: 2
---

# Get started with the pic0rick

This guide takes you from an unboxed pic0rick to your first ultrasound acquisition. No prior ultrasound or embedded systems experience is required.

---

## Step 1: What you need

Before you begin, make sure you have the following:

| Item | Notes |
|---|---|
| **pic0rick main board** | Available on [Tindie](https://www.tindie.com/stores/kelu124/) or build from [KiCad sources](https://github.com/kelu124/pic0rick/) |
| **Pulser board** | Connects via the single PMOD header — generates the transmit pulse |
| **HV board** | Generates +-25V for the pulser. Plugs into the pulser board |
| **A single-element ultrasound transducer** | Any single-element probe in the 1–10 MHz range will work. See [compatible probes](http://un0rick.cc/probes) for suggestions |
| **SMA cable** | To connect the transducer to the board's receive SMA connector |
| **USB-C cable** | For power and data connection to your computer |
| **A computer** | Any OS with Python 3 installed (Windows, macOS, Linux) |
| **A test target** (optional) | A glass of water with a coin at the bottom, a metal block, or any solid object for reflection testing |

### The assembled stack

The three boards connect together like this: HV board → Pulser board → pic0rick main board (via the single PMOD header). The double PMOD header on the other side can optionally connect to a VGA output or MUX extension.

![Assembled pic0rick](https://raw.githubusercontent.com/kelu124/pic0rick/refs/heads/main/documentation/images/20240406_153634.jpg)

---

## Step 2: Flash the firmware

The pic0rick uses an RP2040 microcontroller, which appears as a USB mass storage device when put into boot mode.

1. **Enter boot mode**: Hold the BOOTSEL button on the pic0rick board while plugging in the USB cable. The board should appear as a USB drive named `RPI-RP2`.
2. **Copy the firmware**: Download the latest `.uf2` firmware file from the [pic0rick releases page](https://github.com/kelu124/pic0rick/releases) and drag it onto the `RPI-RP2` drive.
3. **Wait for reboot**: The board will automatically reboot once the file is copied. The USB drive will disappear — this is normal.

If you prefer to build from source, the firmware code is in the [pic0rick repository](https://github.com/kelu124/pic0rick/) under the `software/` directory.

---

## Step 3: Connect the transducer

1. Connect your single-element transducer to the **Receive SMA** connector on the pic0rick main board using an SMA cable.
2. Point the transducer at your test target. For a simple first test, press the transducer against a flat metal surface or immerse it in a glass of water aimed at the bottom.
3. Make sure the HV board and pulser board are connected and the full stack is powered via USB.

---

## Step 4: Install the software

The pic0rick communicates over USB serial. You need Python 3 and a few libraries.

```bash
pip install pyserial numpy matplotlib
```

Clone the software repository:

```bash
git clone https://github.com/kelu124/pic0rick.git
cd pic0rick/software
```

---

## Step 5: Your first acquisition

Run the acquisition script to capture your first ultrasound echo:

```bash
python pico_shell.py
```

This script connects to the pic0rick over serial, triggers a pulse, and captures the reflected signal through the ADC. You should see a waveform plot showing the initial pulse and any echoes from your test target.

### What you should see

A typical acquisition looks like this — the large spike on the left is the transmit pulse, and the smaller peaks to the right are reflections from your target:

![Example acquisition](https://github.com/kelu124/pic0rick/raw/main/software/imgs/pico_shell/pic0gain_at_6.jpg)

### Adjusting the gain

The pic0rick features a Time-Gain Compensation (TGC) system using an AD8331 amplifier (7.5 dB to 55.5 dB range), controlled via an MCP4812 SPI DAC. You can adjust the gain curve in your acquisition script to compensate for signal attenuation at depth. The gain setting in the example above is set to 6 — try different values to see how they affect the signal.

---

## Step 6: What's next?

Now that you have your first acquisition working, here are some directions to explore:

* **Try different use cases**: [Pulse-echo](http://un0rick.cc/UseCase/pulse_echo), [NDT](http://un0rick.cc/UseCase/NDT), or [Tomography](http://un0rick.cc/UseCase/tomo)
* **Add extensions**: The double PMOD connector supports a [VGA output](http://un0rick.cc/goodies/pmods) for real-time display and a [MUX board](http://un0rick.cc/goodies/pmods) for driving multiple transducers
* **Explore the hardware**: Full [KiCad design files](https://github.com/kelu124/pic0rick/) are available if you want to modify the board
* **Read the research**: See how others have used the hardware in [30+ academic publications](http://un0rick.cc/research)
* **Join the community**: Ask questions on [Slack](https://join.slack.com/t/usdevkit/shared_invite/zt-2g501obl-z53YHyGOOMZjeCXuXzjZow) or [Matrix](https://app.element.io/#/room/#un0rick:matrix.org)

---

## Troubleshooting

### Board not detected over USB

* Make sure you are using a **data-capable** USB-C cable (some cables are charge-only).
* Try a different USB port. Some hubs may not provide enough power.
* Check that the firmware was flashed correctly — re-enter boot mode and re-flash the `.uf2` file.

### No echo signal visible

* Check the SMA cable connection — make sure the transducer is firmly connected.
* Verify the pulser and HV boards are connected and powered. The pulser needs the HV board to generate transmit pulses.
* Try a simpler target: press the transducer flat against a thick metal plate. You should see a strong back-wall echo.
* Increase the gain setting in your acquisition script.

### Signal looks very noisy

* Make sure the HV board is properly seated on the pulser board. Loose connections introduce noise.
* Keep the USB cable and SMA cable separated — they can couple electromagnetically.
* Try averaging multiple acquisitions to improve the signal-to-noise ratio.
* If using a breadboard or loose wires for any connections, switch to direct board-to-board connections.

### Serial port permission issues (Linux)

On Linux, you may need to add your user to the `dialout` group:

```bash
sudo usermod -aG dialout $USER
```

Then log out and back in for the change to take effect.

---

## Going deeper

* [pic0rick hardware details](http://un0rick.cc/pic0rick) — full specs, block diagram, and PMOD extensions
* [pic0rick GitHub repository](https://github.com/kelu124/pic0rick/) — firmware source, KiCad files, and documentation
* [Board comparison table](http://un0rick.cc/pic0rick#board-comparison) — how pic0rick compares to older un0rick-family boards