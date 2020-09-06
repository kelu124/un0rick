create_clock -period 83.33 -name {clk} -waveform [list 0.00 41.67] [get_ports clk]
create_clock -period 1000.00 -name {MATTY_MAIN_VHDL|spi_sclk_inferred_clock} -waveform [list 0.00 500.00] [get_pins spi_slave_inst.spi_sclk/O]
