//-------------------------------------------------------------------
// Test for acq module
//-------------------------------------------------------------------
module tb_acq();

//-------------------------------------------------------------------
// Clock and reset
//-------------------------------------------------------------------
reg pulser_clk = 0;
reg tb_clk = 0;

always begin
    #(7.8125/2); // 128 MHz
    pulser_clk <= ~pulser_clk;
end

always @(posedge pulser_clk)
    tb_clk <= ~tb_clk;

reg tb_rst = 1;
initial begin
    repeat(3) @(posedge tb_clk);
    @(negedge tb_clk);
    tb_rst <= 0;
end

//-------------------------------------------------------------------
// DUT
//-------------------------------------------------------------------
localparam ADC_DATA_W         = 10;
localparam DAC_DATA_W         = 10;
localparam DAC_SCK_DIV        = 8;
localparam DAC_GAIN_N         = 32;
localparam DAC_GAIN_PTR_W     = $clog2(DAC_GAIN_N);
localparam PULSER_LEN_W       = 8;
localparam ACQ_LINES_MAX      = 32;
localparam ACQ_LINES_W        = 8;
localparam ACQ_WORDS_PER_LINE = 16384;
localparam RAM_DATA_W         = 16;
localparam RAM_ADDR_W         = 19;
localparam INICE_N            = 3;

// Pulser
wire                      pulser_on;
wire                      pulser_off;
reg  [PULSER_LEN_W-1:0]   pulser_on_len = 31;
reg  [PULSER_LEN_W-1:0]   pulser_off_len = 255;
reg  [PULSER_LEN_W-1:0]   pulser_init_len = 12;
reg  [PULSER_LEN_W-1:0]   pulser_inter_len = 12;
reg                       pulser_drmode = 1'b1;
// DAC
wire [DAC_DATA_W-1:0]     dac_din;
wire                      dac_dvalid;
wire [DAC_GAIN_PTR_W-1:0] dac_gain_ptr;
reg  [DAC_DATA_W-1:0]     dac_gain = '0;
reg  [DAC_DATA_W-1:0]     dac_idle = '0;
// ADC
reg  [ADC_DATA_W-1:0]     adc_dout = '0;
// Acquisition
reg                       acq_start = '0;
wire                      acq_busy;
wire                      acq_done;
reg  [ACQ_LINES_W-1:0]    acq_lines = 31;
wire [RAM_ADDR_W-1:0]     acq_waddr;
wire [RAM_DATA_W-1:0]     acq_wdata;
wire                      acq_wen;
// Misc
reg  [INICE_N-1:0]        inice = '0;

acq #(
    .ADC_DATA_W         (ADC_DATA_W),         // ADC data width
    .DAC_DATA_W         (DAC_DATA_W),         // DAC data width
    .DAC_SCK_DIV        (DAC_SCK_DIV),        // Divider to obtain DAC SCK from system clock
    .DAC_GAIN_N         (DAC_GAIN_N),         // Number of DAC gain values
    .DAC_GAIN_PTR_W     (DAC_GAIN_PTR_W),     // Bit width of pointer to select DAC gain value
    .PULSER_LEN_W       (PULSER_LEN_W),       // Bit width of pulser interval length
    .ACQ_LINES_MAX      (ACQ_LINES_MAX),      // Maximum number of lines per acquisition 
    .ACQ_LINES_W        (ACQ_LINES_W),        // Bit width of lines counter
    .ACQ_WORDS_PER_LINE (ACQ_WORDS_PER_LINE), // Number of words per line
    .RAM_DATA_W         (RAM_DATA_W),         // External RAM data bus width
    .RAM_ADDR_W         (RAM_ADDR_W),         // External RAM address bus width
    .INICE_N            (INICE_N)             // Number of INICE pins, connected to FPGA
) dut (
    // System
    .clk              (tb_clk),           // System clock
    .rst              (tb_rst),           // System reset
    // Pulser
    .pulser_clk       (pulser_clk),       // Clock for pulse generation (2x faster than system clock)
    .pulser_on        (pulser_on),        // Pulser on pin
    .pulser_off       (pulser_off),       // Pulser off pin
    .pulser_on_len    (pulser_on_len),    // Length of the on pulse (in pulser_clk ticks)
    .pulser_off_len   (pulser_off_len),   // Length of the off pulse (in pulser_clk ticks)
    .pulser_init_len  (pulser_init_len),  // Length of the initial delay before on pulse (in pulser_clk ticks)
    .pulser_inter_len (pulser_inter_len), // Length of the delay between on and off pulses (in pulser_clk ticks)
    .pulser_drmode    (pulser_drmode),    // Pulser double rate mode enable
    // DAC
    .dac_din          (dac_din),          // DAC data to control output voltage
    .dac_dvalid       (dac_dvalid),       // DAC data is valid
    .dac_gain_ptr     (dac_gain_ptr),     // DAC gain pointer to select gain value
    .dac_gain         (dac_gain),         // DAC gain value
    .dac_idle         (dac_idle),         // DAC value in idle
    // ADC
    .adc_dout         (adc_dout),         // ADC output data
    // Acquisition
    .acq_start        (acq_start),        // Acquisition start
    .acq_busy         (acq_busy),         // Acquisition is in progress
    .acq_done         (acq_done),         // Acquisition is done
    .acq_lines        (acq_lines),        // Acquisition lines
    .acq_waddr        (acq_waddr),        // Address to save current acquisition sample
    .acq_wdata        (acq_wdata),        // Current acquisition sample value
    .acq_wen          (acq_wen),          // Acquisition sample write enable
    // Misc
    .inice            (inice)             // Inputs from PMOD header, connected to FPGA
);

//-------------------------------------------------------------------
// DAC
//-------------------------------------------------------------------
dacctl #(
    .DATA_W  (DAC_DATA_W),  // DAC data width
    .SCK_DIV (DAC_SCK_DIV)  // Divider to obtain SCK from system clock
) dacctl (
    // System
    .clk        (tb_clk),      // System clock
    .rst        (tb_rst),      // System reset
    // DAC input data interface
    .din        (dac_din),      // DAC data to set output voltage
    .dvalid     (dac_dvalid),   // DAC data is valid (pulse)
    // DAC SPI output
    .spi_cs_n   (), // DAC SPI chip select (active low)
    .spi_sck    (),  // DAC SPI clock
    .spi_sdi    (),  // DAC SPI data output
    .spi_ldac_n (), // DAC SPI load data (active low)
    // Misc
    .busy       () // DAC controller is busy (SPI exchange is in progress)
);

reg [DAC_DATA_W-1:0] dac_gain_mem [0:DAC_GAIN_N-1];

initial begin : init_dac
    integer i;
    dac_idle = 10'h100;
    for (i=0; i<DAC_GAIN_N; i=i+1) begin
        dac_gain_mem[i] = 10'h200 + i;
    end
end

always @(posedge tb_clk) begin
    dac_gain <= dac_gain_mem[dac_gain_ptr];
end

//-------------------------------------------------------------------
// ADC
//-------------------------------------------------------------------
wire [ADC_DATA_W-1:0] adc_data_raw;

adc10065 #(
    .DATA_W (ADC_DATA_W)
) adc10065 (
    .clk  (tb_clk),
    .data (adc_data_raw)
);

always @(posedge tb_clk) begin
    adc_dout <= adc_data_raw;
end

//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------

// Main test
initial begin : tb_main
    integer err_cnt;
    err_cnt = 0;

    wait(tb_rst);
    repeat (20) @(posedge tb_clk);

    @(posedge tb_clk);
    acq_start <= 1'b1;
    @(posedge tb_clk);
    acq_start <= 1'b0;
    @(posedge tb_clk);
    wait(acq_done);

    repeat (5) @(posedge tb_clk);
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
    $dumpvars(0, tb_acq);
end
`endif

endmodule