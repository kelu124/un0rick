//-------------------------------------------------------------------
// Control/Status Register (CSR) map
//
//-------------------------------------------------------------------
module csr #(
    parameter CSR_ADDR_W     = 8,                  // CSR address width
    parameter CSR_DATA_W     = 16,                 // CSR data width
    parameter RAM_DATA_W     = 16,                 // External RAM data bus width
    parameter RAM_ADDR_W     = 19,                 // External RAM address bus width
    parameter PULSER_LEN_W   = 8,                  // Bit width of pulser interval length
    parameter DAC_DATA_W     = 10,                 // DAC data width
    parameter DAC_GAIN_N     = 32,                 // Number of DAC gain values
    parameter DAC_GAIN_PTR_W = $clog2(DAC_GAIN_N), // Bit width of pointer to select DAC gain value
    parameter ACQ_LINES_W    = 5,                  // Bit width of lines counter
    parameter LED_N          = 3,                  // Number of leds, connected to FPGA
    parameter TOPTURN_N      = 3,                  // Number of TOPTURN pins, connected to FPGA
    parameter JUMPER_N       = 3,                  // Number of jumpers, connected to FPGA
    parameter OUTICE_N       = 3,                  // Number of OUTICE pins, connected to FPGA
    parameter HVMUX_SWITCH_W = 16                  // Number of HV mux switches
)(
    // System
    input  wire                      clk,              // System clock
    input  wire                      rst,              // System reset
    // CSR map interface
    input  wire [CSR_ADDR_W-1:0]     csr_addr,         // CSR address
    input  wire                      csr_wen,          // CSR write enable
    input  wire [CSR_DATA_W-1:0]     csr_wdata,        // CSR write data
    input  wire                      csr_ren,          // CSR read enable
    output reg                       csr_rvalid,       // CSR read data is valid
    output reg  [CSR_DATA_W-1:0]     csr_rdata,        // CSR read data
    // Application
    input  wire [RAM_DATA_W-1:0]     ramctl_rdata,     // RAM controller read data
    input  wire                      ramctl_rvalid,    // RAM controller read data is valid
    output reg  [RAM_ADDR_W-1:0]     ramctl_raddr,     // RAM controller read address
    output wire                      ramctl_ren,       // RAM controller read enable
    output reg                       ramf_inc,         // Start RAM filling with incrementing data pattern
    output reg                       ramf_dec,         // Start RAM filling with decrementing data pattern
    input  wire                      ramf_done,        // RAM filler is done
    output reg  [PULSER_LEN_W-1:0]   pulser_init_len,  // Length of the initial delay before on pulse (in pulser_clk ticks)
    output reg  [PULSER_LEN_W-1:0]   pulser_on_len,    // Length of the on pulse (in pulser_clk ticks)
    output reg  [PULSER_LEN_W-1:0]   pulser_off_len,   // Length of the off pulse (in pulser_clk ticks)
    output reg  [PULSER_LEN_W-1:0]   pulser_inter_len, // Length of the delay between on and off pulses (in pulser_clk ticks)
    output reg                       pulser_drmode,    // Pulser double rate mode enable
    output reg  [DAC_DATA_W-1:0]     dac_idle,         // DAC value in idle
    output reg  [DAC_DATA_W-1:0]     dac_gain,         // DAC gain value
    input  wire [DAC_GAIN_PTR_W-1:0] dac_gain_ptr,     // DAC gain pointer to select gain value
    output reg                       acq_start,        // Acquisition start
    input  wire                      acq_start_ext,    // Acquisition start external
    input  wire                      acq_done,         // Acquisition is done
    input  wire                      acq_busy,         // Acquisition is in progress
    output reg  [ACQ_LINES_W-1:0]    acq_lines,        // Acquisition lines
    output reg  [LED_N-1:0]          led,              // Leds, connected to FPGA
    input  wire [TOPTURN_N-1:0]      topturn,          // TOPTURN pins, connected to FPGA
    input  wire [JUMPER_N-1:0]       jumper,           // Jumpers, connected to FPGA
    output reg  [OUTICE_N-1:0]       outice,           // OUTICE pins, connected to FPGA
    output reg                       hvmux_en,         // Enable HV mux driver
    output reg  [HVMUX_SWITCH_W-1:0] hvmux_sw,         // State of HV mux switches
    output reg                       hvmux_sw_upd      // Strobe to update HV mux switches
);
//-----------------------------------------------------------------------------
// Generated address decoder with read data logic
//-----------------------------------------------------------------------------
`include "csr_decoder.vh"

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam AUTHOR_W  = 8;
localparam VERSION_W = 8;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg  [DAC_DATA_W-1:0]     dac_gain_ram_wdata;
reg                       dac_gain_ram_wen;
reg  [DAC_GAIN_PTR_W-1:0] dac_gain_ram_waddr;
wire [DAC_DATA_W-1:0]     dac_gain_ram_rdata;
reg  [DAC_DATA_W-1:0]     dac_gain_ram_rdata_ff;
reg  [DAC_GAIN_PTR_W-1:0] dac_gain_ram_raddr;
reg                       dac_gain_ram_rvalid;
reg                       dac_gain_ram_rvalid_ff;
reg                       dac_gain_ram_ren;

reg ramctl_raddr_rst;

//-----------------------------------------------------------------------------
// INITDEL - Initial pulse delay
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pulser_init_len <= INITDEL_RST;
    end else if (csr_wen && sel_bus[INITDEL_POS]) begin
        pulser_init_len <= csr_wdata[0 +: PULSER_LEN_W];
    end
end
// read
assign rdata_bus[INITDEL_POS * CSR_DATA_W + PULSER_LEN_W +: CSR_DATA_W - PULSER_LEN_W] = '0;
assign rdata_bus[INITDEL_POS * CSR_DATA_W +: PULSER_LEN_W] = pulser_init_len;
assign rvalid_bus[INITDEL_POS] = 1'b1;

//-----------------------------------------------------------------------------
// PONW - Pon width
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pulser_on_len <= PONW_RST;
    end else if (csr_wen && sel_bus[PONW_POS]) begin
        pulser_on_len <= csr_wdata[0 +: PULSER_LEN_W];
    end
end
// read
assign rdata_bus[PONW_POS * CSR_DATA_W + PULSER_LEN_W +: CSR_DATA_W - PULSER_LEN_W] = '0;
assign rdata_bus[PONW_POS * CSR_DATA_W +: PULSER_LEN_W] = pulser_on_len;
assign rvalid_bus[PONW_POS] = 1'b1;

//-----------------------------------------------------------------------------
// POFFW - Poff width
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pulser_off_len <= POFFW_RST;
    end else if (csr_wen && sel_bus[POFFW_POS]) begin
        pulser_off_len <= csr_wdata[0 +: PULSER_LEN_W];
    end
end
// read
assign rdata_bus[POFFW_POS * CSR_DATA_W + PULSER_LEN_W +: CSR_DATA_W - PULSER_LEN_W] = '0;
assign rdata_bus[POFFW_POS * CSR_DATA_W +: PULSER_LEN_W] = pulser_off_len;
assign rvalid_bus[POFFW_POS] = 1'b1;

//-----------------------------------------------------------------------------
// INTERW - Intermediate delay width
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pulser_inter_len <= INTERW_RST;
    end else if (csr_wen && sel_bus[INTERW_POS]) begin
        pulser_inter_len <= csr_wdata[0 +: PULSER_LEN_W];
    end
end
// read
assign rdata_bus[INTERW_POS * CSR_DATA_W + PULSER_LEN_W +: CSR_DATA_W - PULSER_LEN_W] = '0;
assign rdata_bus[INTERW_POS * CSR_DATA_W +: PULSER_LEN_W] = pulser_inter_len;
assign rvalid_bus[INTERW_POS] = 1'b1;

//-----------------------------------------------------------------------------
// DRMODE - Double resolution mode
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pulser_drmode <= DRMODE_RST;
    end else if (csr_wen && sel_bus[DRMODE_POS]) begin
        pulser_drmode <= csr_wdata[0];
    end
end
// read
assign rdata_bus[DRMODE_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[DRMODE_POS * CSR_DATA_W +: 1] = pulser_drmode;
assign rvalid_bus[DRMODE_POS] = 1'b1;

//-----------------------------------------------------------------------------
// DACOUT - DAC out
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dac_idle <= DACOUT_RST;
    end else if (csr_wen && sel_bus[DACOUT_POS]) begin
        dac_idle <= csr_wdata[0 +: DAC_DATA_W];
    end
end
// read
assign rdata_bus[DACOUT_POS * CSR_DATA_W + DAC_DATA_W +: CSR_DATA_W - DAC_DATA_W] = '0;
assign rdata_bus[DACOUT_POS * CSR_DATA_W +: DAC_DATA_W] = dac_idle;
assign rvalid_bus[DACOUT_POS] = 1'b1;

//-----------------------------------------------------------------------------
// DACGAIN - DAC gain
//-----------------------------------------------------------------------------
// write address, data and enable
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dac_gain_ram_waddr <= '0;
        dac_gain_ram_wdata <= '0;
        dac_gain_ram_wen   <= 1'b0;
    end else begin
        dac_gain_ram_waddr <= csr_addr[0 +: DAC_GAIN_PTR_W];
        dac_gain_ram_wdata <= csr_wdata[0 +: DAC_DATA_W];
        dac_gain_ram_wen   <= csr_wen && sel_bus[DACGAIN_POS];
    end
end

// read address
always @(posedge clk or posedge rst) begin
    if (rst)
        dac_gain_ram_raddr <= '0;
    else if (csr_ren && sel_bus[DACGAIN_POS])
        dac_gain_ram_raddr <= csr_addr[0+:DAC_GAIN_PTR_W];
    else
        dac_gain_ram_raddr <= dac_gain_ptr;
end
// read data, enable and valid
always @(posedge clk or posedge rst) begin
    if (rst) begin
        dac_gain_ram_ren       <= 1'b0;
        dac_gain_ram_rvalid    <= 1'b0;
        dac_gain_ram_rdata_ff  <= '0;
        dac_gain_ram_rvalid_ff <= 1'b0;
    end else begin
        dac_gain_ram_ren       <= csr_ren && sel_bus[DACGAIN_POS];
        dac_gain_ram_rvalid    <= dac_gain_ram_ren;
        dac_gain_ram_rvalid_ff <= dac_gain_ram_rvalid;
        dac_gain_ram_rdata_ff  <= dac_gain_ram_rdata;
    end
end

dpram #(
    .ADDR_W    (DAC_GAIN_PTR_W),
    .DATA_W    (DAC_DATA_W),
    .INIT_FILE ("../../src/rtl/dacgain.mem")
) dac_gain_ram (
    // Write interface
    .wclk  (clk),   // Write clock
    .wdata (dac_gain_ram_wdata), // Write data
    .waddr (dac_gain_ram_waddr), // Write address
    .wr    (dac_gain_ram_wen),    // Write operation
    // Read interface
    .rclk  (clk),   // Read clock
    .rdata (dac_gain_ram_rdata), // Read data
    .raddr (dac_gain_ram_raddr), // Read address
    .rd    (~dac_gain_ram_wen)    // Read operation
);

// assignment to common bus
assign rdata_bus[DACGAIN_POS * CSR_DATA_W + DAC_DATA_W +: CSR_DATA_W - DAC_DATA_W] = '0;
assign rdata_bus[DACGAIN_POS * CSR_DATA_W +: DAC_DATA_W] = dac_gain_ram_rdata_ff;
assign rvalid_bus[DACGAIN_POS] = dac_gain_ram_rvalid_ff;

// assignment to port
always @(*) begin
    dac_gain = dac_gain_ram_rdata_ff;
end

//-----------------------------------------------------------------------------
// ACQSTART - Start acquisition
//-----------------------------------------------------------------------------
// pulse will be generated on write or with external signal
always @(posedge clk or posedge rst) begin
    if (rst) begin
        acq_start <= 1'b0;
    end else if (csr_wen && sel_bus[ACQSTART_POS]) begin
        acq_start <= 1'b1;
    end else if (acq_start_ext) begin
        acq_start <= 1'b1;
    end else begin
        acq_start <= 1'b0;
    end
end
// read
assign rdata_bus[ACQSTART_POS * CSR_DATA_W +: CSR_DATA_W] = '0;
assign rvalid_bus[ACQSTART_POS] = 1'b1;

//-----------------------------------------------------------------------------
// ACQDONE - Acquisition is done
//-----------------------------------------------------------------------------
// read
assign rdata_bus[ACQDONE_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[ACQDONE_POS * CSR_DATA_W +: 1] = acq_done;
assign rvalid_bus[ACQDONE_POS] = 1'b1;

//-----------------------------------------------------------------------------
// ACQBUSY - Acquisition is busy
//-----------------------------------------------------------------------------
// read
assign rdata_bus[ACQBUSY_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[ACQBUSY_POS * CSR_DATA_W +: 1] = acq_busy;
assign rvalid_bus[ACQBUSY_POS] = 1'b1;

//-----------------------------------------------------------------------------
// NBLINES - Number of lines
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        acq_lines <= NBLINES_RST;
    end else if (csr_wen && sel_bus[NBLINES_POS]) begin
        acq_lines <= csr_wdata[0 +: ACQ_LINES_W];
    end
end
// read
assign rdata_bus[NBLINES_POS * CSR_DATA_W + ACQ_LINES_W +: CSR_DATA_W - ACQ_LINES_W] = '0;
assign rdata_bus[NBLINES_POS * CSR_DATA_W +: ACQ_LINES_W] = acq_lines;
assign rvalid_bus[NBLINES_POS] = 1'b1;

//-----------------------------------------------------------------------------
// LED1, LED2, LED3 - LED control
//-----------------------------------------------------------------------------
reg acq_done_ff;
always @(posedge clk or posedge rst) begin
    if (rst)
        acq_done_ff <= 1'b0;
    else
        acq_done_ff <= acq_done;
end

// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        led <= {LED3_RST, LED2_RST, LED1_RST};
    end else begin
        // LED1
        if (csr_wen && sel_bus[LED1_POS])
            led[0] <= csr_wdata[0];
        else if (acq_start)
            led[0] <= 1'b1;
        else if (acq_done && (!acq_done_ff)) // done pulse
            led[0] <= 1'b0;
        // LED2
        if (csr_wen && sel_bus[LED2_POS])
            led[1] <= csr_wdata[0];
        //LED3
        if (csr_wen && sel_bus[LED3_POS])
            led[2] <= csr_wdata[0];
    end
end
// read
// LED1
assign rdata_bus[LED1_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[LED1_POS * CSR_DATA_W +: 1] = led[0];
assign rvalid_bus[LED1_POS] = 1'b1;
// LED2
assign rdata_bus[LED2_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[LED2_POS * CSR_DATA_W +: 1] = led[1];
assign rvalid_bus[LED2_POS] = 1'b1;
// LED3
assign rdata_bus[LED3_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[LED3_POS * CSR_DATA_W +: 1] = led[2];
assign rvalid_bus[LED3_POS] = 1'b1;

//-----------------------------------------------------------------------------
// TOPTURN1, TOPTURN2, TOPTURN3 - TOPTURN lines status
//-----------------------------------------------------------------------------
// read
// TOPTURN1
assign rdata_bus[TOPTURN1_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[TOPTURN1_POS * CSR_DATA_W +: 1] = topturn[0];
assign rvalid_bus[TOPTURN1_POS] = 1'b1;
// TOPTURN2
assign rdata_bus[TOPTURN2_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[TOPTURN2_POS * CSR_DATA_W +: 1] = topturn[1];
assign rvalid_bus[TOPTURN2_POS] = 1'b1;
// TOPTURN3
assign rdata_bus[TOPTURN3_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[TOPTURN3_POS * CSR_DATA_W +: 1] = topturn[2];
assign rvalid_bus[TOPTURN3_POS] = 1'b1;

//-----------------------------------------------------------------------------
// JUMPER1, JUMPER2, JUMPER3 - JUMPER lines status
//-----------------------------------------------------------------------------
// read
// JUMPER
assign rdata_bus[JUMPER1_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[JUMPER1_POS * CSR_DATA_W +: 1] = jumper[0];
assign rvalid_bus[JUMPER1_POS] = 1'b1;
// JUMPER2
assign rdata_bus[JUMPER2_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[JUMPER2_POS * CSR_DATA_W +: 1] = jumper[1];
assign rvalid_bus[JUMPER2_POS] = 1'b1;
// JUMPER3
assign rdata_bus[JUMPER3_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[JUMPER3_POS * CSR_DATA_W +: 1] = jumper[2];
assign rvalid_bus[JUMPER3_POS] = 1'b1;

//-----------------------------------------------------------------------------
// OUT1ICE, OUT2ICE, OUT3ICE - OUTICE control
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        outice <= {OUT3ICE_RST, OUT2ICE_RST, OUT1ICE_RST};
    end else if (csr_wen)begin
        if (sel_bus[OUT1ICE_POS])
            outice[0] <= csr_wdata[0];
        else if (sel_bus[OUT2ICE_POS])
            outice[1] <= csr_wdata[0];
        else if (sel_bus[OUT3ICE_POS])
            outice[2] <= csr_wdata[0];
    end
end
// read
// OUT1ICE
assign rdata_bus[OUT1ICE_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[OUT1ICE_POS * CSR_DATA_W +: 1] = outice[0];
assign rvalid_bus[OUT1ICE_POS] = 1'b1;
// OUT2ICE
assign rdata_bus[OUT2ICE_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[OUT2ICE_POS * CSR_DATA_W +: 1] = outice[1];
assign rvalid_bus[OUT2ICE_POS] = 1'b1;
// OUT3ICE
assign rdata_bus[OUT3ICE_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[OUT3ICE_POS * CSR_DATA_W +: 1] = outice[2];
assign rvalid_bus[OUT3ICE_POS] = 1'b1;

//-----------------------------------------------------------------------------
// HVMUXEN, HVMUXSW - HV mux control
//-----------------------------------------------------------------------------
// write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        hvmux_en     <= HVMUXEN_RST;
        hvmux_sw     <= HVMUXSW_RST;
        hvmux_sw_upd <= 1'b0;
    end else if (csr_wen) begin
        if (sel_bus[HVMUXEN_POS]) begin
            hvmux_en <= csr_wdata[0];
        end
        if (sel_bus[HVMUXSW_POS]) begin
            hvmux_sw     <= csr_wdata[15:0];
            hvmux_sw_upd <= 1'b1;
        end
    end else begin
        hvmux_sw_upd <= 1'b0;
    end
end

// read
// HVMUXEN
assign rdata_bus[HVMUXEN_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[HVMUXEN_POS * CSR_DATA_W +: 1] = hvmux_en;
assign rvalid_bus[HVMUXEN_POS] = 1'b1;
// HVMUXSW
assign rdata_bus[HVMUXSW_POS * CSR_DATA_W +: CSR_DATA_W] = hvmux_sw;
assign rvalid_bus[HVMUXSW_POS] = 1'b1;

//-----------------------------------------------------------------------------
// RAMDATA - Read data from the external RAM (address increments after every read)
//-----------------------------------------------------------------------------
reg ramctl_rvalid_ff;
always @(posedge clk or posedge rst) begin
    if (rst)
        ramctl_rvalid_ff <= 1'b0;
    else
        ramctl_rvalid_ff <= ramctl_rvalid;
end

// read
assign rdata_bus[RAMDATA_POS * CSR_DATA_W +: RAM_DATA_W] = ramctl_rdata;
assign rvalid_bus[RAMDATA_POS] = ramctl_rvalid;
// delayed ram_rvalid is needed to clear ren right after handshake
// original csr_len goes to spi2csr and clears one tick later
assign ramctl_ren = csr_ren & sel_bus[RAMDATA_POS] & (~ramctl_rvalid_ff);

always @(posedge clk or posedge rst) begin
    if (rst)
        ramctl_raddr <= '0;
    else if (ramctl_raddr_rst)
        ramctl_raddr <= '0;
    else if (ramctl_ren && ramctl_rvalid)
        ramctl_raddr <= ramctl_raddr + 1;
end

//-----------------------------------------------------------------------------
// RAMRADDRRST - Reset external RAM read address
//-----------------------------------------------------------------------------
// pulse will be generated on write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ramctl_raddr_rst <= 1'b0;
    end else if (csr_wen && sel_bus[RAMRADDRRST_POS]) begin
        ramctl_raddr_rst <= 1'b1;
    end else begin
        ramctl_raddr_rst <= 1'b0;
    end
end
// read
assign rdata_bus[RAMRADDRRST_POS * CSR_DATA_W +: CSR_DATA_W] = '0;
assign rvalid_bus[RAMRADDRRST_POS] = 1'b1;

//-----------------------------------------------------------------------------
// RAMFINC - Fill external RAM with incrementing data pattern
//-----------------------------------------------------------------------------
// pulse will be generated on write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ramf_inc <= 1'b0;
    end else if (csr_wen && sel_bus[RAMFINC_POS]) begin
        ramf_inc <= 1'b1;
    end else begin
        ramf_inc <= 1'b0;
    end
end
// read
assign rdata_bus[RAMFINC_POS * CSR_DATA_W +: CSR_DATA_W] = '0;
assign rvalid_bus[RAMFINC_POS] = 1'b1;

//-----------------------------------------------------------------------------
// RAMFDEC - Fill external RAM with decrementing data pattern
//-----------------------------------------------------------------------------
// pulse will be generated on write
always @(posedge clk or posedge rst) begin
    if (rst) begin
        ramf_dec <= 1'b0;
    end else if (csr_wen && sel_bus[RAMFDEC_POS]) begin
        ramf_dec <= 1'b1;
    end else begin
        ramf_dec <= 1'b0;
    end
end
// read
assign rdata_bus[RAMFDEC_POS * CSR_DATA_W +: CSR_DATA_W] = '0;
assign rvalid_bus[RAMFDEC_POS] = 1'b1;

//-----------------------------------------------------------------------------
// RAMFDONE - Filling of external RAM is done
//-----------------------------------------------------------------------------
// read
assign rdata_bus[RAMFDONE_POS * CSR_DATA_W + 1 +: CSR_DATA_W - 1] = '0;
assign rdata_bus[RAMFDONE_POS * CSR_DATA_W +: 1] = ramf_done;
assign rvalid_bus[RAMFDONE_POS] = 1'b1;

//-----------------------------------------------------------------------------
// AUTHOR - Author
//-----------------------------------------------------------------------------
// read
assign rdata_bus[AUTHOR_POS * CSR_DATA_W + AUTHOR_W +: CSR_DATA_W - AUTHOR_W] = '0;
assign rdata_bus[AUTHOR_POS * CSR_DATA_W +: AUTHOR_W] = AUTHOR_RST;
assign rvalid_bus[AUTHOR_POS] = 1'b1;

//-----------------------------------------------------------------------------
// VERSION - Version
//-----------------------------------------------------------------------------
// read
assign rdata_bus[VERSION_POS * CSR_DATA_W + VERSION_W +: CSR_DATA_W - VERSION_W] = '2;
assign rdata_bus[VERSION_POS * CSR_DATA_W +: VERSION_W] = VERSION_RST;
assign rvalid_bus[VERSION_POS] = 1'b1;

endmodule
