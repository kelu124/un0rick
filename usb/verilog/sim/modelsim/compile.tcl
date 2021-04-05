# Simply change the project settings in this section
# for each new project. There should be no need to
# modify the rest of the script.

set library_file_list [list \
  work [list \
    ../../src/beh/spi_master/spi_mst_beh.v \
    ../../src/beh/is61wv51216/is61wv51216.v \
    ../../src/beh/mcp4811/mcp4811.v \
    ../../src/beh/max14866/max14866.v \
    ../../src/beh/adc10065/adc10065.v \
    ../../src/beh/vga_recv/vga_recv.v \
    ../../src/rtl/glitch_filter.v \
    ../../src/rtl/rom.v \
    ../../src/rtl/sys_pll.v \
    ../../src/rtl/vga_pll.v \
    ../../src/rtl/dpram.v \
    ../../src/rtl/sync_2ff.v \
    ../../src/rtl/dacctl.v \
    ../../src/rtl/acq.v \
    ../../src/rtl/acq_buff.v \
    ../../src/rtl/hex_ch.v \
    ../../src/rtl/spi2csr.v \
    ../../src/rtl/vga.v \
    ../../src/rtl/debouncer.v \
    ../../src/rtl/display.v \
    ../../src/rtl/ramctl.v \
    ../../src/rtl/stat_px.v \
    ../../src/rtl/csr.v \
    ../../src/rtl/ram_filler.v \
    ../../src/rtl/hvmuxctl.v \
    ../../src/rtl/top.v \
    ../../src/tb/$tb_name.v] \
]
set incdir_list [list \
  ../../src/rtl \
  ../../src/tb \
]
set top_level              work.$tb_name

# After sourcing the script from ModelSim for the
# first time use these commands to recompile.
proc r  {} {
  write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave.do
  uplevel #0 source compile.tcl
}
proc rr {} {global last_compile_time
            set last_compile_time 0
            r                            }
proc q  {} {quit -force                  }

#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

# Compile out of date files
set incdir_str_ ""
foreach incdir $incdir_list {
    append incdir_str_ " +incdir+" $incdir
}
set incdir_str [string trim $incdir_str_ " "]

set time_now [clock seconds]
if [catch {set last_compile_time}] {
  set last_compile_time 0
}
foreach {library file_list} $library_file_list {
  vlib $library
  vmap work $library
  foreach file $file_list {
    if { $last_compile_time < [file mtime $file] } {
      if [regexp {.vhdl?$} $file] {
        vcom -93 $file
      } else {
        vlog +define+SIM -sv05compat -timescale "1 ns / 1 ps" $file {*}[split $incdir_str " "]
      }
      set last_compile_time 0
    }
  }
}
set last_compile_time $time_now

# Load the simulation
eval vsim $top_level

# If waves exists
if [file exist wave.do] {
  source wave.do
}
