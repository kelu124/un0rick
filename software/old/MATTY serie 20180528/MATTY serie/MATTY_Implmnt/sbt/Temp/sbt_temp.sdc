####---- CreateClock list ----2
create_clock  -period 83.33 -waveform {0.00 41.67} -name {clk} [get_ports {clk}] 
create_clock  -period 1000.00 -waveform {0.00 500.00} -name {MATTY_MAIN_VHDL|spi_sclk_inferred_clock} [get_pins {spi_slave_inst.spi_sclk/O}] 

