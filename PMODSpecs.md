Reference for PMODs designs  https://reference.digilentinc.com/_media/reference/pmod/pmod-interface-specification-1_2_0.pdf

1. PMOD split in two (a+b): see attached picture (2 boards)

a: HV generation - 3.3V in
- Logic: SPI (x3), Enable
- Analog design: Jorge's
- LEDs: Enable, SPI_CS
- Reference design: https://github.com/kelu124/un0rick/blob/master/images/LM3478%20HVPS.pdf

b: Pulse control + SMA
- Analog design: See un0rick
- Logic: HvP, HvN, PDamp, LogicB
- LEDs: all 4 logics
- Reference design: https://github.com/kelu124/un0rick/blob/master/hardware/v1.1/MATTY-V11.pdf with the MD1210K6 / TC6320TG design.

2. PMOD for fast ADC: connectors: SMA + PMODx2
- 10 bit, 64Msps, ADC 
- AD8331 + MD0100
- Low noise ampli
- Logic: ADC (x11), AD8331 HILO (x1), DAC: SPI (x3), LogicC
- LEDs: HILO, SPI_CS
- Reference design: https://github.com/kelu124/un0rick/blob/master/hardware/v1.1/MATTY-V11.pdf
