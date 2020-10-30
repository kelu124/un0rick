set_hierarchy_separator /
# 12 MHz from external generator 
create_clock -period 83.333 -name {ref_clk} [get_ports {ICE_CLK}]
# 128 MHz from PLL
create_clock -period 7.843 -name {pll_clk} [get_pins {pll/clk_out}]
# 64 MHz from PLL clock divider
create_generated_clock -name {sys_clk} -source [get_pins {pll/clk_out}] -divide_by 2 [get_pins {pll_clk_div/clk_div2}]

