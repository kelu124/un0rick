#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LATTICE-ECP
set_option -part LFECP6E
set_option -package T144C
set_option -speed_grade -5

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency auto
set_option -maxfan 100
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


#-- add_file options
add_file -vhdl {/usr/local/diamond/3.10_x64/cae_library/synthesis/vhdl/ecp.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/16M_Async_SRAM.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/asyn_fifo.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/gray_counter.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/matty_main.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/matty_main248.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/matty.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/mattysimu.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/package_timing.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/package_utility.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/pll100M.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/pll128M2.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/pll248M2_inst.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/pll248M2.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/pll256M2_inst.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/pll256M2.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/sclk_gen.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/spi_data_path.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/spi_master.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/spi_slave_ice.vhd}
add_file -vhdl -lib "work" {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/source/SPI_SLAVE.vhd}

#-- top module name
set_option -top_module SPI_SLAVE

#-- set result format/file last
project -result_file {/home/kelu/ultrasound/un0rick/software/MATTY_Implmnt/MATTY_MATTY_Implmnt.edi}

#-- error message log file
project -log_file {MATTY_MATTY_Implmnt.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
project -run
