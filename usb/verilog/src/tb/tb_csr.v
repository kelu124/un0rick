//-------------------------------------------------------------------
// Test for csr module
//-------------------------------------------------------------------
module tb_csr();

//-------------------------------------------------------------------
// Clock and reset
//-------------------------------------------------------------------
reg tb_clk = 0;
always begin
    #7.8125; // 64 MHz
    tb_clk <= ~tb_clk;
end

reg tb_rst = 1;
initial begin
    repeat(3) @(posedge tb_clk);
    @(negedge tb_clk);
    tb_rst <= 0;
end

//-------------------------------------------------------------------
// DUT
//-------------------------------------------------------------------
localparam CSR_ADDR_W     = 8;
localparam CSR_DATA_W     = 16;
localparam RAM_DATA_W     = 16;
localparam RAM_ADDR_W     = 19;
localparam PULSER_LEN_W   = 8;
localparam DAC_DATA_W     = 10;
localparam DAC_GAIN_N     = 32;
localparam DAC_GAIN_PTR_W = $clog2(DAC_GAIN_N);
localparam ACQ_LINES_W    = 5;
localparam LED_N          = 3;
localparam TOPTURN_N      = 3;
localparam JUMPER_N       = 3;
localparam OUTICE_N       = 3;

// CSR map interface
reg  [CSR_ADDR_W-1:0]     csr_addr = '0;
reg                       csr_wen = '0;
reg  [CSR_DATA_W-1:0]     csr_wdata = '0;
reg                       csr_ren = '0;
wire                      csr_rvalid;
wire [CSR_DATA_W-1:0]     csr_rdata;
// Application
reg  [RAM_DATA_W-1:0]     ramctl_rdata = '0;
reg                       ramctl_rvalid = '0;
wire [RAM_ADDR_W-1:0]     ramctl_raddr;
wire                      ramctl_ren;
wire                      ramf_inc;
wire                      ramf_dec;
reg                       ramf_done = '0;
wire [PULSER_LEN_W-1:0]   pulser_init_len;
wire [PULSER_LEN_W-1:0]   pulser_on_len;
wire [PULSER_LEN_W-1:0]   pulser_off_len;
wire [PULSER_LEN_W-1:0]   pulser_inter_len;
wire                      pulser_drmode;
wire [DAC_DATA_W-1:0]     dac_idle;
wire [DAC_DATA_W-1:0]     dac_gain;
reg  [DAC_GAIN_PTR_W-1:0] dac_gain_ptr = '0;
wire                      acq_start;
reg                       acq_start_ext = 1'b0;
reg                       acq_done = '0;
reg                       acq_busy = '0;
wire [ACQ_LINES_W-1:0]    acq_lines;
wire [LED_N-1:0]          led;
reg  [TOPTURN_N-1:0]      topturn = '0;
reg  [JUMPER_N-1:0]       jumper = '0;
wire [OUTICE_N-1:0]       outice;

csr #(
    .CSR_ADDR_W     (CSR_ADDR_W),     // CSR address width
    .CSR_DATA_W     (CSR_DATA_W),     // CSR data width
    .RAM_DATA_W     (RAM_DATA_W),     // External RAM data bus width
    .RAM_ADDR_W     (RAM_ADDR_W),     // External RAM address bus width
    .PULSER_LEN_W   (PULSER_LEN_W),   // Bit width of pulser interval length
    .DAC_DATA_W     (DAC_DATA_W),     // DAC data width
    .DAC_GAIN_N     (DAC_GAIN_N),     // Number of DAC gain values
    .DAC_GAIN_PTR_W (DAC_GAIN_PTR_W), // Bit width of pointer to select DAC gain value
    .ACQ_LINES_W    (ACQ_LINES_W),    // Bit width of lines counter
    .LED_N          (LED_N),          // Number of leds, connected to FPGA
    .TOPTURN_N      (TOPTURN_N),      // Number of TOPTURN pins, connected to FPGA
    .JUMPER_N       (JUMPER_N),       // Number of jumpers, connected to FPGA
    .OUTICE_N       (OUTICE_N)        // Number of OUTICE pins, connected to FPGA
) csr (
    // System
    .clk              (tb_clk),          // System clock
    .rst              (tb_rst),          // System reset
    // CSR map interface
    .csr_addr         (csr_addr),         // CSR address
    .csr_wen          (csr_wen),          // CSR write enable
    .csr_wdata        (csr_wdata),        // CSR write data
    .csr_ren          (csr_ren),          // CSR read enable
    .csr_rvalid       (csr_rvalid),       // CSR read data is valid
    .csr_rdata        (csr_rdata),        // CSR read data
    // Application
    .ramctl_rdata     (ramctl_rdata),     // RAM controller read data
    .ramctl_rvalid    (ramctl_rvalid),    // RAM controller read data is valid
    .ramctl_raddr     (ramctl_raddr),     // RAM controller read address
    .ramctl_ren       (ramctl_ren),       // RAM controller read enable
    .ramf_inc         (ramf_inc),         // Start RAM filling with incrementing data pattern
    .ramf_dec         (ramf_dec),         // Start RAM filling with decrementing data pattern
    .ramf_done        (ramf_done),        // RAM filler is done
    .pulser_init_len  (pulser_init_len),  // Length of the initial delay before on pulse (in pulser_clk ticks)
    .pulser_on_len    (pulser_on_len),    // Length of the on pulse (in pulser_clk ticks)
    .pulser_off_len   (pulser_off_len),   // Length of the off pulse (in pulser_clk ticks)
    .pulser_inter_len (pulser_inter_len), // Length of the delay between on and off pulses (in pulser_clk ticks)
    .pulser_drmode    (pulser_drmode),    // Pulser double rate mode enable
    .dac_idle         (dac_idle),         // DAC value in idle
    .dac_gain         (dac_gain),         // DAC gain value
    .dac_gain_ptr     (dac_gain_ptr),     // DAC gain pointer to select gain value
    .acq_start        (acq_start),        // Acquisition start
    .acq_start_ext    (acq_start_ext),    // Acquisition start external
    .acq_done         (acq_done),         // Acquisition is done
    .acq_busy         (acq_busy),         // Acquisition is in progress
    .acq_lines        (acq_lines),        // Acquisition lines
    .led              (led),              // Leds, connected to FPGA
    .topturn          (topturn),          // TOPTURN pins, connected to FPGA
    .jumper           (jumper),           // Jumpers, connected to FPGA
    .outice           (outice)            // OUTICE pins, connected to FPGA
);

//-------------------------------------------------------------------
// RAM controller imitation
//-------------------------------------------------------------------
initial begin
    forever begin
        @(posedge tb_clk);
        if (ramctl_ren) begin
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);
        @(posedge tb_clk);
        ramctl_rvalid <= 1'b1;
        ramctl_rdata  <= ramctl_raddr + 16'h42;
        @(posedge tb_clk);
        ramctl_rvalid <= 1'b0;
        end
    end
end

//-------------------------------------------------------------------
// CSR tasks
//-------------------------------------------------------------------
task csr_write (
    input reg [CSR_ADDR_W-1:0] addr,
    input reg [CSR_DATA_W-1:0] data
);
begin : task_csr_write
    $display("csr_write: addr=0x%02x data=%04x", addr, data);
    @(posedge tb_clk);
    csr_wdata <= data;
    csr_addr  <= addr;
    csr_wen   <= 1'b1;
    @(posedge tb_clk);
    csr_wdata <= '0;
    csr_addr  <= '0;
    csr_wen   <= 1'b0;
end
endtask

task csr_read (
    input  reg [CSR_ADDR_W-1:0] addr,
    output reg [CSR_DATA_W-1:0] data
);
begin : task_csr_read
    @(posedge tb_clk);
    csr_addr  <= addr;
    csr_ren   <= 1'b1;
    while (!csr_rvalid) begin
        @(posedge tb_clk);
    end
    csr_ren <= 1'b0;
    data = csr_rdata;
    $display("csr_read: addr=0x%02x data=%04x", addr, data);
end
endtask
//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------
reg [CSR_DATA_W-1:0] rdata;
// Main test
initial begin : tb_main
    integer err_cnt;
    err_cnt = 0;

    wait(tb_rst);
    repeat (3) @(posedge tb_clk);
    // read PONW
    csr_read(8'h01, rdata);
    // write to PONW
    csr_write(8'h01, 16'h00AA);
    // read PONW
    csr_read(8'h01, rdata);
    // read DACOUT
    csr_read(8'h07, rdata);
    // read DACGAIN[3]
    csr_read(8'h23, rdata);
    // write to DACGAIN[3]
    csr_write(8'h23, 16'h233);
    // read DACGAIN[3]
    csr_read(8'h23, rdata);
    // write to FILLRAMINC
    csr_write(8'hA4, 16'h0001);
    // read RAMDATA
    csr_read(8'hA0, rdata);
    csr_read(8'hA0, rdata);
    csr_read(8'hA0, rdata);
    // write RSTRAMADDR
    csr_write(8'hA1, 16'h0001);
    // read RAMDATA
    csr_read(8'hA0, rdata);
    csr_read(8'hA0, rdata);
    csr_read(8'hA0, rdata);

    // test external start and LED0
    @(posedge tb_clk);
    acq_start_ext <= 1'b1;
    @(posedge tb_clk);
    acq_start_ext <= 1'b0;
    repeat (3) @(posedge tb_clk);
    acq_done <= 1'b1;

    repeat (10) @(posedge tb_clk);
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
    $dumpvars(0, tb_csr);
end
`endif

endmodule