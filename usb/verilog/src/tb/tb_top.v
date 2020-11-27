//-------------------------------------------------------------------
// Test for top module
//-------------------------------------------------------------------
module tb_top();

//-------------------------------------------------------------------
// Clock and reset
//-------------------------------------------------------------------
reg tb_clk = 0;

// 12 MHz
always #(41.666) tb_clk <= ~tb_clk;

reg tb_rst_n = 1'b0;
initial #342 tb_rst_n = 1'b1;

//-------------------------------------------------------------------
// DUT
//-------------------------------------------------------------------
localparam RAM_DATA_W = 16;
localparam RAM_ADDR_W = 19;

localparam ADC_DATA_W = 10;

reg button_trig = 1'b0;

reg jumper1 = 1'b0;
reg jumper2 = 1'b1;
reg jumper3 = 1'b0;

reg trig_ice = 1'b0;
reg in1_ice = 1'b0;
reg in2_ice = 1'b0;
reg in3_ice = 1'b0;

reg top_turn1 = 1'b0;
reg top_turn2 = 1'b0;
reg top_turn3 = 1'b0;

wire ice_sclk_ft;
wire ice_miso_ft;
wire ice_mosi_ft;
wire ise_cs_ft;
reg  ice_reset_ft = 1'b0;

wire dac_spi_sclk;
wire dac_spi_cs;
wire dac_spi_mosi;

wire                  ram_lb_n;
wire                  ram_ub_n;
wire                  ram_oe_n;
wire                  ram_we_n;
wire                  ram_ce_n;
wire [RAM_DATA_W-1:0] ram_io;
wire [RAM_ADDR_W-1:0] ram_a;

wire                  adc_clk;
wire [ADC_DATA_W-1:0] adc_d;

wire vga_hsync;
wire vga_vsync;
wire vga_r;
wire vga_g;
wire vga_b;

top dut (
    // Clock and reset
    .ICE_RESET (tb_rst_n), // Active low reset from supervisor
    .ICE_CLK   (tb_clk),   // Clock from 12 MHz generator

    // Buttons
    .BUTTON_TRIG (button_trig),

    // Leds
    .LED_ACQUISITION  (),
    .LED_SINGLE_nLOOP (),
    .LED3             (),

    // Jumpers
    //.JUMPER1 (jumper1),
    .JUMPER2 (jumper2),
    .JUMPER3 (jumper3),

    // RPI header
    .IO1_RPI (vga_g),
    .IO2_RPI (vga_vsync),
    .IO3_RPI (),
    .IO4_RPI (vga_hsync),

    //Application IO
    .PON_ICE   (),
    .POFF_ICE  (),
    .TRIG_ICE  (trig_ice),
    .IN1_ICE   (in1_ice),
    .IN2_ICE   (in2_ice),
    .IN3_ICE   (in3_ice),
    .OUT1_ICE  (),
    .OUT2_ICE  (),
    .OUT3_ICE  (),
    .TOP_TURN1 (top_turn1),
    .TOP_TURN2 (top_turn2),
    .TOP_TURN3 (top_turn3),

    // FTDI IO
    .ICE_SCLK_FT  (ice_sclk_ft),
    .ICE_MISO_FT  (ice_miso_ft),
    .ICE_MOSI_FT  (ice_mosi_ft),
    .ISE_CS_FT    (ise_cs_ft),
    .ICE_RESET_FT (ice_reset_ft),

    // DAC
    .DAC_SPI_SCLK (dac_spi_sclk),
    .DAC_SPI_CS   (dac_spi_cs),
    .DAC_SPI_MOSI (dac_spi_mosi),

    // RAM
    .RAM_nLB (ram_lb_n),
    .RAM_nUB (ram_ub_n),
    .RAM_nOE (ram_oe_n),
    .RAM_nWE (ram_we_n),
    .RAM_nCE (ram_ce_n),
    .RAM_IO  (ram_io),
    .RAM_A   (ram_a),

    // ADC
    .ADC_CLK (adc_clk),
    .ADC_D   (adc_d)
);

//-------------------------------------------------------------------
// SPI master
//-------------------------------------------------------------------
localparam CSR_ADDR_W     = 8;
localparam CSR_DATA_W     = 16;
localparam SPI_CTRL_LEN_W = 14;
localparam SPI_FREQ_MHZ   = 8;

spi_mst_beh #(
    .FREQ_MHZ (SPI_FREQ_MHZ),
    .LEN_W    (SPI_CTRL_LEN_W),
    .DATA_W   (CSR_DATA_W),
    .ADDR_W   (CSR_ADDR_W)
) spi_mst (
    .miso (ice_miso_ft), // SPI master input / slave output
    .mosi (ice_mosi_ft), // SPI master output / slave input
    .sck  (ice_sclk_ft),  // SPI clock
    .cs_n (ise_cs_ft)  // SPI chip select (active low)
);


//-------------------------------------------------------------------
// ADC
//-------------------------------------------------------------------
adc10065 #(
    .DATA_W (ADC_DATA_W)
) adc (
    .clk  (adc_clk),
    .data (adc_d)
);

//-------------------------------------------------------------------
// DAC
//-------------------------------------------------------------------
localparam DAC_DATA_W = 10;

mcp4811 #(
    .DAC_DATA_W (DAC_DATA_W)
) dac (
    .cs_n   (dac_spi_cs),
    .sck    (dac_spi_sclk),
    .sdi    (dac_spi_mosi),
    .ld_n   (1'b0)
);

//-------------------------------------------------------------------
// RAM
//-------------------------------------------------------------------
is61wv51216 ram (
    .Address (ram_a),
    .dataIO  (ram_io),
    .OE_bar  (ram_oe_n),
    .CE_bar  (ram_ce_n),
    .WE_bar  (ram_we_n),
    .LB_bar  (ram_lb_n),
    .UB_bar  (ram_ub_n)
);

//-------------------------------------------------------------------
// VGA
//-------------------------------------------------------------------
localparam H_ACTIVE = 800;
localparam V_ACTIVE = 600;
localparam H_ACTIVE_W = $clog2(H_ACTIVE);
localparam V_ACTIVE_W = $clog2(V_ACTIVE);

// lazy backdoor synchronization with lines
reg line_active_ff0 = 0, line_active_ff1 = 0;
always @(posedge dut.vga_clk or negedge tb_rst_n) begin
    if (!tb_rst_n) begin
        line_active_ff0 <= 1'b0;
        line_active_ff1 <= 1'b0;
    end else begin
        line_active_ff0 <= dut.display_line_active;
        line_active_ff1 <= line_active_ff0;
    end
end

vga_recv #(
    .WIDTH     (H_ACTIVE),
    .HEIGHT    (V_ACTIVE),
    .DUMP_PATH ("frame")
) vga_recv (
    .pixel_clk   (dut.vga_clk),
    .pixel_r     ({8{1'b0}}),
    .pixel_g     ({8{vga_g}}),
    .pixel_b     ({8{1'b0}}),
    .line_active (line_active_ff1),
    .frame_end   (dut.display.frame_end)
);

//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------
//initial #10000000 jumper2 = 1'b1;

reg [11:0] acq_raw [16383:0];

initial begin : acq_raw_gen
    integer i;
    $readmemh("../../util/vga_layout/mem/acq_raw.mem", acq_raw);
    wait(adc.tick_cnt == 1090343); // wait to fill frame1 with real data
    force adc.data_orig = acq_raw[0];
    for(i=0; i<16384; i=i+1) begin
        @(posedge adc.clk);
        force adc.data_orig = acq_raw[i];
    end
    @(posedge adc.clk);
    release adc.data_orig;
end

initial begin
    #100;
    dut.csr.dac_gain_ram.mem[0] = 100;
    dut.csr.dac_gain_ram.mem[1] = 100;
    dut.csr.dac_gain_ram.mem[2] = 100;
    dut.csr.dac_gain_ram.mem[3] = 100;
    dut.csr.dac_gain_ram.mem[4] = 101;
    dut.csr.dac_gain_ram.mem[5] = 103;
    dut.csr.dac_gain_ram.mem[6] = 105;
    dut.csr.dac_gain_ram.mem[7] = 109;
    dut.csr.dac_gain_ram.mem[8] = 114;
    dut.csr.dac_gain_ram.mem[9] = 120;
    dut.csr.dac_gain_ram.mem[10] = 127;
    dut.csr.dac_gain_ram.mem[11] = 136;
    dut.csr.dac_gain_ram.mem[12] = 147;
    dut.csr.dac_gain_ram.mem[13] = 160;
    dut.csr.dac_gain_ram.mem[14] = 175;
    dut.csr.dac_gain_ram.mem[15] = 192;
    dut.csr.dac_gain_ram.mem[16] = 212;
    dut.csr.dac_gain_ram.mem[17] = 234;
    dut.csr.dac_gain_ram.mem[18] = 260;
    dut.csr.dac_gain_ram.mem[19] = 288;
    dut.csr.dac_gain_ram.mem[20] = 319;
    dut.csr.dac_gain_ram.mem[21] = 354;
    dut.csr.dac_gain_ram.mem[22] = 392;
    dut.csr.dac_gain_ram.mem[23] = 434;
    dut.csr.dac_gain_ram.mem[24] = 479;
    dut.csr.dac_gain_ram.mem[25] = 529;
    dut.csr.dac_gain_ram.mem[26] = 582;
    dut.csr.dac_gain_ram.mem[27] = 640;
    dut.csr.dac_gain_ram.mem[28] = 702;
    dut.csr.dac_gain_ram.mem[29] = 769;
    dut.csr.dac_gain_ram.mem[30] = 800;
    dut.csr.dac_gain_ram.mem[31] = 841;
    dut.csr.dac_gain_ram.mem[32] = 918;
end

// Main test
initial begin : tb_main
    integer err_cnt;
    err_cnt = 0;

    wait(!tb_rst_n);

    @(negedge vga_vsync);
    @(negedge vga_vsync);
    @(negedge vga_vsync);
    @(negedge vga_vsync);

    if (err_cnt)
        $error("Test failed with %0d errors!", err_cnt);
    else
        $display("Test passed!");

    `ifdef __ICARUS__
        $finish;
    `else
        $stop;
    `endif
end

`ifdef __ICARUS__
initial begin
    $dumpfile("work.vcd");
    $dumpvars(0, tb_top);
end
`endif

endmodule