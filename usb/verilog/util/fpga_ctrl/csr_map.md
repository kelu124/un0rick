Generated by util/csr_map/gen_csr.py.

Please do not edit manually!

|Address|Name|Size|Reset|Mode|Description|
|:-|:-|:-|:-|:-|:-|
|0x00|     INITDEL|08|  0x07| rw|Initial pulse delay -- 0 - 1 period of 127.5 MHz, 1 - 2 periods, etc.|
|0x01|        PONW|08|  0x10| rw|Pon width -- 0 - 1 period of 127.5 MHz, 1 - 2 periods, etc.|
|0x02|       POFFW|08|  0x80| rw|Poff width -- 0 - 1 period of 127.5 MHz, 1 - 2 periods, etc.|
|0x03|      INTERW|08|  0x07| rw|Intermediate delay width -- 0 - 1 period of 127.5 MHz, 1 - 2 periods, etc.|
|0x04|      DRMODE|01|   0x0| rw|Double resolution mode -- add 1 to INITDEL whe line is even|
|0x07|      DACOUT|10| 0x100| rw|DAC out -- value for the DAC idle state|
|0x20|   DACGAIN00|10| 0x200| rw|DAC gain 0|
|0x21|   DACGAIN01|10| 0x200| rw|DAC gain 1|
|0x22|   DACGAIN02|10| 0x200| rw|DAC gain 2|
|0x23|   DACGAIN03|10| 0x200| rw|DAC gain 3|
|0x24|   DACGAIN04|10| 0x200| rw|DAC gain 4|
|0x25|   DACGAIN05|10| 0x200| rw|DAC gain 5|
|0x26|   DACGAIN06|10| 0x200| rw|DAC gain 6|
|0x27|   DACGAIN07|10| 0x200| rw|DAC gain 7|
|0x28|   DACGAIN08|10| 0x200| rw|DAC gain 8|
|0x29|   DACGAIN09|10| 0x200| rw|DAC gain 9|
|0x2a|   DACGAIN10|10| 0x200| rw|DAC gain 10|
|0x2b|   DACGAIN11|10| 0x200| rw|DAC gain 11|
|0x2c|   DACGAIN12|10| 0x200| rw|DAC gain 12|
|0x2d|   DACGAIN13|10| 0x200| rw|DAC gain 13|
|0x2e|   DACGAIN14|10| 0x200| rw|DAC gain 14|
|0x2f|   DACGAIN15|10| 0x200| rw|DAC gain 15|
|0x30|   DACGAIN16|10| 0x200| rw|DAC gain 16|
|0x31|   DACGAIN17|10| 0x200| rw|DAC gain 17|
|0x32|   DACGAIN18|10| 0x200| rw|DAC gain 18|
|0x33|   DACGAIN19|10| 0x200| rw|DAC gain 19|
|0x34|   DACGAIN20|10| 0x200| rw|DAC gain 20|
|0x35|   DACGAIN21|10| 0x200| rw|DAC gain 21|
|0x36|   DACGAIN22|10| 0x200| rw|DAC gain 22|
|0x37|   DACGAIN23|10| 0x200| rw|DAC gain 23|
|0x38|   DACGAIN24|10| 0x200| rw|DAC gain 24|
|0x39|   DACGAIN25|10| 0x200| rw|DAC gain 25|
|0x3a|   DACGAIN26|10| 0x200| rw|DAC gain 26|
|0x3b|   DACGAIN27|10| 0x200| rw|DAC gain 27|
|0x3c|   DACGAIN28|10| 0x200| rw|DAC gain 28|
|0x3d|   DACGAIN29|10| 0x200| rw|DAC gain 29|
|0x3e|   DACGAIN30|10| 0x200| rw|DAC gain 30|
|0x3f|   DACGAIN31|10| 0x200| rw|DAC gain 31|
|0x50|    ACQSTART|01|   0x0| wo|Start acquisition|
|0x51|     ACQDONE|01|   0x0| ro|Acquisition is done|
|0x52|     NBLINES|08|  0x00| rw|Number of lines per acquisition -- 0 - 1 line, 1 - 2 lines, etc.|
|0x53|     ACQBUSY|01|   0x0| ro|Acquisition is busy|
|0x63|        LED1|01|   0x0| rw|LED1 (LED_ACQUISITION) control|
|0x64|        LED2|01|   0x0| rw|LED2 (LED_SiNGLE/nLOOP) control|
|0x65|        LED3|01|   0x0| rw|LED3 control|
|0x66|    TOPTURN1|01|   0x0| ro|TOP_TURN1 status|
|0x67|    TOPTURN2|01|   0x0| ro|TOP_TURN2 status|
|0x68|    TOPTURN3|01|   0x0| ro|TOP_TURN3 status|
|0x69|     JUMPER1|01|   0x0| ro|Jumper1 status|
|0x6A|     JUMPER2|01|   0x0| ro|Jumper2 status|
|0x6B|     JUMPER3|01|   0x0| ro|Jumper3 status|
|0x6C|     OUT1ICE|01|   0x1| rw|OUT1_ICE output control|
|0x6D|     OUT2ICE|01|   0x0| rw|OUT2_ICE output control|
|0x6E|     OUT3ICE|01|   0x1| rw|OUT3_ICE output control|
|0x6F|     HVMUXEN|01|   0x0| rw|Enable HV mux driver|
|0x70|     HVMUXSW|16|   0x0| rw|Control HV mux switches|
|0xA0|     RAMDATA|16|0x0000| ro|Read data from the external RAM|
|0xA1| RAMRADDRRST|01|   0x0| wo|Reset external RAM read address|
|0xA4|     RAMFINC|01|   0x0| wo|Fill external RAM with incrementing data pattern|
|0xA5|     RAMFDEC|01|   0x0| wo|Fill external RAM with decrementing data pattern|
|0xA6|    RAMFDONE|01|   0x0| ro|Filling of external RAM is done|
|0xF0|      AUTHOR|08|  0x01| ro|Author|
|0xF1|     VERSION|08|  0x01| ro|Version|
