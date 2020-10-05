## Reference for PMODs designs

### Reference sheets

See  https://reference.digilentinc.com/_media/reference/pmod/pmod-interface-specification-1_2_0.pdf

### Examples

#### Classical

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/images/pmods/P_20200103_212537.jpg)

#### Example stacked

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/images/pmods/P_20200103_212553.jpg)

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/images/pmods/P_20200103_212615.jpg)


## PMOD_1 split in two (a+b): see attached picture above (2 boards, stacked)

#### PMOD_1a: HV generation - 3.3V in

- Logic: SPI (x3), Enable
- Analog design: Jorge's
- LEDs: Enable, SPI_CS (see below)
- Reference design: https://github.com/kelu124/un0rick/blob/master/images/LM3478%20HVPS.pdf , or below (with correction):

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/hv/lm/LM3478.png)

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/hv/lm/new_rectifier_480.jpg)

#### PMOD_1b: Pulse control + SMA

- Analog design: See un0rick
- Logic: HvP, HvN, PDamp, LogicA
- LEDs: all 4 logics
- Reference design: https://github.com/kelu124/un0rick/blob/master/hardware/v1.1/MATTY-V11.pdf with the MD1210K6 / TC6320TG design.

## PMOD_2 for fast ADC: connectors: SMA + PMODx2

- 10 bit, 64Msps or above, ADC 
- AD8331 + MD0100
- Low noise ampli
- Logic: ADC (x11), AD8331 HILO (x1), DAC: SPI (x3), LogicB
- LEDs: HILO, SPI_CS
- Reference design: https://github.com/kelu124/un0rick/blob/master/hardware/v1.1/MATTY-V11.pdf

## Preamp (not a PMOD, but small design)

- Amp based on OPA847
- SMA inputs / outputs
- 5V / GND in
- Design as in:

![](https://raw.githubusercontent.com/kelu124/echomods/master/include/hv/lm/preamplifier.jpg)




