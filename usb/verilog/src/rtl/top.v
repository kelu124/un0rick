module top #(
    parameter RAM_DATA_W = 16, // External RAM data bus width
    parameter RAM_ADDR_W = 19, // External RAM address bus width
    parameter ADC_DATA_W = 10  // ADC data bus width
)(
    // Clock and reset
    input wire ICE_RESET, // Active low reset from supervisor
    input wire ICE_CLK,   // Clock from 12 MHz generator

    // Buttons
    input wire BUTTON_TRIG,
    //input wire BUTTON_SINGLE_nLOOP,
    //input wire BUTTON3,

    // Leds
    //output wire SPI_SELECT_LED,
    output wire LED_ACQUISITION,
    output wire LED_SINGLE_nLOOP,
    output wire LED3,

    // Jumpers
    //input wire JUMPER1, // conflict with PLLs
    input wire JUMPER2,
    input wire JUMPER3,
    //input wire SPI_SELECT,

    // RPI header
    //input  wire TRIG_RPI,
    //input  wire ICE_SCLK_RPI,
    //output wire ICE_MISO_RPI,
    //input  wire ICE_MOSI_RPI,
    //input  wire ICE_CS_RPI,
    //input  wire RPI2FLASH_CS,
    //input  wire ICE_RESET_RPI,
    output  wire IO1_RPI, // VGA R
    output  wire IO2_RPI, // VGA G
    output  wire IO3_RPI, // VGA HS
    output  wire IO4_RPI, // VGA VS

    //Application IO
    output wire PON_ICE,
    output wire POFF_ICE,
    input  wire TRIG_ICE,
    input  wire IN1_ICE,
    input  wire IN2_ICE,
    input  wire IN3_ICE,
    output wire OUT1_ICE,
    output wire OUT2_ICE,
    output wire OUT3_ICE,
    input  wire TOP_TURN1,
    input  wire TOP_TURN2,
    input  wire TOP_TURN3,

    // FTDI IO
    input  wire ICE_SCLK_FT,
    output wire ICE_MISO_FT,
    input  wire ICE_MOSI_FT,
    input  wire ISE_CS_FT,
    input  wire ICE_RESET_FT,
    //input  wire TRIG_FT,
    //input  wire IO1_FT,
    //input  wire IO2_FT,
    //input  wire IO3_FT,
    //input  wire IO4_FT,

    // Flash
    //output wire FLASH_MOSI,
    //input  wire FLASH_MISO,
    //output wire FLASH_SCLK,
    //output wire FLASH_CS,

    // DAC
    output wire DAC_SPI_SCLK,
    output wire DAC_SPI_CS,
    output wire DAC_SPI_MOSI,

    // RAM
    output wire                  RAM_nLB,
    output wire                  RAM_nUB,
    output wire                  RAM_nOE,
    output wire                  RAM_nWE,
    output wire                  RAM_nCE,
    inout  wire [RAM_DATA_W-1:0] RAM_IO,
    output wire [RAM_ADDR_W-1:0] RAM_A,

    // ADC
    output wire                  ADC_CLK,
    input  wire [ADC_DATA_W-1:0] ADC_D
);
//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
// CSR
localparam CSR_ADDR_W = 8;
localparam CSR_DATA_W = 16;

// SPI
localparam SPI_CTRL_LEN_W = 14;

// Pulse
localparam PULSER_LEN_W = 8;

// DAC
localparam DAC_DATA_W     = 10;
localparam DAC_GAIN_N     = 32;
localparam DAC_GAIN_PTR_W = $clog2(DAC_GAIN_N);
localparam DAC_SCK_DIV    = 8;

// HV MUX control
localparam HVMUX_SWITCH_N = 16;
localparam HVMUX_CLK_DIV  = 8;

// Acquisition
localparam ACQ_LINES_MAX        = 32;
localparam ACQ_LINES_W          = 8;//$clog2(ACQ_LINES_MAX);
localparam ACQ_WORDS_PER_LINE   = 16384;
localparam ACQ_WORDS_PER_GAIN   = 16384 / DAC_GAIN_N;
localparam ACQ_BUFF_DATA_W      = 24;
localparam ACQ_BUFF_ADDR_W      = 9;
localparam ACQ_BUFF_WORDS       = 2**ACQ_BUFF_ADDR_W;
localparam ACQ_ENV_WORDS        = ACQ_WORDS_PER_LINE / ACQ_BUFF_WORDS; // number of samples to generate one envelope sample
localparam ACQ_ENV_DATA_W       = 8;
localparam ACQ_BUFF_ADDR_OFFSET = $clog2(ACQ_ENV_WORDS);

// IO
localparam LED_N     = 3;
localparam TOPTURN_N = 3;
localparam JUMPER_N  = 3;
localparam OUTICE_N  = 3;
localparam INICE_N   = 3;

// VGA
localparam VGA_H_ACTIVE   = 800;
localparam VGA_PX_CNT_W   = $clog2(VGA_H_ACTIVE);
localparam VGA_V_ACTIVE   = 600;
localparam VGA_LINE_CNT_W = $clog2(VGA_V_ACTIVE);
localparam VGA_COLOR_W    = 1;

// Misc
`ifdef SIM
localparam DEBOUNCE_DELAY = 20;
`else
localparam DEBOUNCE_DELAY = 2000000;
`endif
localparam LED_CNT_W      = 26;
localparam EXT_RST_CNT_W  = 6;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
// Clock and reset
wire por_rst_n;
wire ftdi_rst;
wire ext_rst_async;
wire ext_rst_async_filtered;
wire ref_clk;
wire pulser_clk;
wire pulser_rst;
wire sys_clk;
wire sys_rst;
wire vga_clk;
wire vga_rst;
wire sys_pll_lock;
wire vga_pll_lock;
reg [EXT_RST_CNT_W-1:0] ext_rst_cnt;
reg  ext_rst;

// SPI
wire spi_miso;
wire spi_mosi;
wire spi_sck;
wire spi_cs_n;

// CSR
wire [CSR_ADDR_W-1:0] csr_addr;
wire                  csr_wen;
wire [CSR_DATA_W-1:0] csr_wdata;
wire                  csr_ren;
wire                  csr_rvalid;
wire [CSR_DATA_W-1:0] csr_rdata;

// Pulse
wire                    pulser_on;
wire                    pulser_off;
wire [PULSER_LEN_W-1:0] pulser_init_len;
wire [PULSER_LEN_W-1:0] pulser_on_len;
wire [PULSER_LEN_W-1:0] pulser_off_len;
wire [PULSER_LEN_W-1:0] pulser_inter_len;
wire                    pulser_drmode;

// Gain
wire [DAC_DATA_W-1:0]     dac_idle;
wire [DAC_DATA_W-1:0]     dac_gain;
wire [DAC_GAIN_PTR_W-1:0] dac_gain_ptr;

// Acquisition
wire                   acq_start_muxed;
wire                   acq_start;
wire                   acq_start_ext;
wire                   acq_done;
wire                   acq_busy;
wire [ACQ_LINES_W-1:0] acq_lines_muxed;
wire [ACQ_LINES_W-1:0] acq_lines;
wire [RAM_ADDR_W-1:0]  acq_waddr;
wire [RAM_DATA_W-1:0]  acq_wdata;
wire                   acq_wen;

reg  acq_run_mode;
wire acq_run_mode_next;
wire acq_run_mode_sysclk;

reg                        acq_buff_fill_en;
wire [ACQ_BUFF_DATA_W-1:0] acq_buff_wdata;
reg [ACQ_BUFF_ADDR_W-1:0]  acq_buff_waddr;
reg                        acq_buff_wr;
wire [ACQ_BUFF_DATA_W-1:0] acq_buff_rdata;
wire [ACQ_BUFF_ADDR_W-1:0] acq_buff_raddr;
wire                       acq_buff_rd;
reg                        acq_buff_rvalid;
wire                       acq_buff_chunk_end;
reg  [TOPTURN_N-1:0]       acq_buff_topturn;
reg  [ACQ_ENV_DATA_W-1:0]  acq_buff_dacgain;
reg  [15:0]                acq_buff_env;
wire [8:0]                 acq_buff_env_next;
wire [ACQ_ENV_DATA_W-1:0]  acq_buff_env_mean;


// IO
reg  [JUMPER_N-1:0]  jumper_ff;
reg  [INICE_N-1:0]   inice_ff;
reg  [TOPTURN_N-1:0] topturn_ff;
wire [LED_N-1:0]     led;
wire [TOPTURN_N-1:0] topturn;
wire [JUMPER_N-1:0]  jumper;
wire [OUTICE_N-1:0]  outice;
wire [INICE_N-1:0]   inice;
wire                 btn_trig;
reg                  btn_trig_ff;
wire                 btn_trig_pulse;
wire                 trigice;
reg                  trigice_ff;
wire                 trigice_pulse;

// External RAM
wire [RAM_ADDR_W-1:0] ram_addr;
wire [RAM_DATA_W-1:0] ram_data_i;
wire [RAM_DATA_W-1:0] ram_data_o;
wire                  ram_data_oe;
wire                  ram_we_n;

wire [RAM_DATA_W-1:0] ramctl_rdata_muxed;
wire [RAM_DATA_W-1:0] ramctl_rdata;
wire                  ramctl_rvalid;
wire [RAM_ADDR_W-1:0] ramctl_addr;
wire [RAM_ADDR_W-1:0] ramctl_raddr;
wire [RAM_ADDR_W-1:0] ramctl_waddr;
wire                  ramctl_ren_muxed;
wire                  ramctl_ren;
wire [RAM_DATA_W-1:0] ramctl_wdata;
wire                  ramctl_wen;

wire                  ramf_wen;
wire [RAM_DATA_W-1:0] ramf_wdata;
wire [RAM_ADDR_W-1:0] ramf_addr;
wire                  ramf_inc;
wire                  ramf_dec;
wire                  ramf_active;
wire                  ramf_done;

reg                  ram_data_oe_ff;
reg                  ram_we_n_ff;
reg [RAM_ADDR_W-1:0] ram_addr_ff;
reg [RAM_DATA_W-1:0] ram_data_o_ff;
reg [RAM_DATA_W-1:0] ram_data_i_ff;

// DAC
wire [DAC_DATA_W-1:0] dac_din;
reg  [DAC_DATA_W-1:0] dac_gain_last;
wire dac_dvalid;
wire dac_spi_cs_n;
wire dac_spi_sck;
wire dac_spi_sdi;

// HV MUX
wire [HVMUX_SWITCH_N-1:0] hvmux_din;
wire hvmux_dvalid;
wire hvmux_spi_le;
wire hvmux_spi_clk;
wire hvmux_spi_din;
wire hvmux_en;

// ADC
reg  [ADC_DATA_W-1:0] adc_d_ff;
wire [ADC_DATA_W-1:0] adc_dout;

// VGA
wire vga_hsync;
wire vga_vsync;
wire vga_ch_r;
wire vga_ch_g;
wire vga_ch_b;

wire                      vga_en;
wire [VGA_COLOR_W-1:0]    display_pixel_r;
wire [VGA_COLOR_W-1:0]    display_pixel_g;
wire [VGA_COLOR_W-1:0]    display_pixel_b;
wire                      display_line_active;
wire                      display_frame_active;
wire [VGA_PX_CNT_W-1:0]   display_px_cnt;
wire [VGA_LINE_CNT_W-1:0] display_line_cnt;

wire display_acq_start, display_acq_start_synced;
wire display_acq_done;
wire display_acq_busy;

// Misc
reg                 led3_csr_sel;
reg [LED_CNT_W-1:0] led3_cnt;

//-----------------------------------------------------------------------------
// Clock and reset
//-----------------------------------------------------------------------------
assign ref_clk   = ICE_CLK;
assign por_rst_n = ICE_RESET;
assign ftdi_rst  = ICE_RESET_FT;

// Pulser 128 MHz clock + System (ADC) 64 MHz clock
sys_pll sys_pll (
    .ref_clk    (ref_clk),
    .pulser_clk (pulser_clk),
    .sys_clk    (sys_clk),
    .lock       (sys_pll_lock)
);

// VGA 36 MHz clock
vga_pll vga_pll (
    .ref_clk    (ref_clk),
    .vga_clk    (vga_clk),
    .lock       (vga_pll_lock)
);

// external reset
assign ext_rst_async = (~por_rst_n) | (~sys_pll_lock) | (~vga_pll_lock) | ftdi_rst;

// external reset glitch filter
glitch_filter ext_rst_filter (
    .clk  (ref_clk),
    .din  (ext_rst_async),
    .dout (ext_rst_async_filtered)
);

// async reset assertion and synchronous (after 64 ticks) removal
always @(posedge ref_clk or posedge ext_rst_async_filtered) begin
    if (ext_rst_async_filtered) begin
        ext_rst_cnt <= '0;
        ext_rst     <= 1'b1;
    end else if (ext_rst_cnt == '1) begin
        ext_rst <= 1'b0;
    end else begin
        ext_rst_cnt <= ext_rst_cnt + 1;
    end
end

// reset removal sequence: external reset -> pulser_rst -> vga_rst -> sys_rst
sync_2ff #(
    .FF_INIT (1'b1)
) pulser_rst_sync (
    .clk  (pulser_clk),
    .rst  (ext_rst_async_filtered),
    .din  (ext_rst),
    .dout (pulser_rst)
);
// pulser_rst -> vga_rst
sync_2ff #(
    .FF_INIT (1'b1)
) vga_rst_sync (
    .clk  (vga_clk),
    .rst  (ext_rst_async_filtered),
    .din  (pulser_rst),
    .dout (vga_rst)
);
// vga_rst -> sys_rst
sync_2ff #(
    .FF_INIT (1'b1)
) sys_rst_sync(
    .clk  (sys_clk),
    .rst  (ext_rst_async_filtered),
    .din  (vga_rst),
    .dout (sys_rst)
);

//-----------------------------------------------------------------------------
// SPI to CSR
//-----------------------------------------------------------------------------
// Connect to FTDI SPI
assign ICE_MISO_FT = spi_miso;
assign spi_mosi    = ICE_MOSI_FT;
assign spi_sck     = ICE_SCLK_FT;
assign spi_cs_n    = ISE_CS_FT;

spi2csr #(
    .CSR_ADDR_W     (CSR_ADDR_W),    // CSR address width
    .CSR_DATA_W     (CSR_DATA_W),    // CSR data width
    .SPI_CTRL_LEN_W (SPI_CTRL_LEN_W) // SPI control word "length" width
) spi2csr (
    // System
    .clk        (sys_clk),    // System clock
    .rst        (sys_rst),    // System reset
    // SPI Slave interface
    .spi_miso   (spi_miso),   // SPI master input / slave output
    .spi_mosi   (spi_mosi),   // SPI master output / slave input
    .spi_sck    (spi_sck),    // SPI clock
    .spi_cs_n   (spi_cs_n),   // SPI chip select (active low)
    // CSR map interface
    .csr_addr   (csr_addr),   // CSR address
    .csr_wen    (csr_wen),    // CSR write enable
    .csr_wdata  (csr_wdata),  // CSR write data
    .csr_ren    (csr_ren),    // CSR read enable
    .csr_rvalid (csr_rvalid), // CSR read data is valid
    .csr_rdata  (csr_rdata)   // CSR read data
);

//-----------------------------------------------------------------------------
// CSR map
//-----------------------------------------------------------------------------
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
    .clk              (sys_clk),          // System clock
    .rst              (sys_rst),          // System reset
    // CSR map interface
    .csr_addr         (csr_addr),         // CSR address
    .csr_wen          (csr_wen),          // CSR write enable
    .csr_wdata        (csr_wdata),        // CSR write data
    .csr_ren          (csr_ren),          // CSR read enable
    .csr_rvalid       (csr_rvalid),       // CSR read data is valid
    .csr_rdata        (csr_rdata),        // CSR read data
    // Application
    .ramctl_rdata     (ramctl_rdata_muxed), // RAM controller read data
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
    .outice           (outice),           // OUTICE pins, connected to FPGA
    .hvmux_en         (hvmux_en),         // Enable HV mux driver
    .hvmux_sw         (hvmux_din),        // State of HV mux switches
    .hvmux_sw_upd     (hvmux_dvalid)   // Strobe to update HV mux switches
);

//-----------------------------------------------------------------------------
// External RAM controller
//-----------------------------------------------------------------------------
ramctl #(
    .DATA_W (RAM_DATA_W), // RAM data width
    .ADDR_W (RAM_ADDR_W)  // RAM address width
) ramctl (
    // System
    .clk         (sys_clk),       // System clock
    .rst         (sys_rst),       // System reset
    // External async ram interface
    .ram_addr    (ram_addr),      // External RAM address
    .ram_data_i  (ram_data_i),    // External RAM data input
    .ram_data_o  (ram_data_o),    // External RAM data output
    .ram_data_oe (ram_data_oe),   // External RAM data output enable
    .ram_we_n    (ram_we_n),      // External RAM write enable (active low)
    // Internal fpga interface
    .addr        (ramctl_addr),   // RAM controller address
    .wdata       (ramctl_wdata),  // RAM controller write data
    .wen         (ramctl_wen),    // RAM controller write enable
    .rdata       (ramctl_rdata),  // RAM controller read data
    .rvalid      (ramctl_rvalid), // RAM controller read data is valid
    .ren         (ramctl_ren_muxed) // RAM controller read enable
);

// external ram can not be read in run mode
assign ramctl_rdata_muxed = acq_run_mode_sysclk ? '0   : ramctl_rdata;
assign ramctl_ren_muxed   = acq_run_mode_sysclk ? 1'b0 : ramctl_ren;

// Add ff to external RAM IO
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
        ram_we_n_ff    <= 1'b1;
        ram_addr_ff    <= '0;
        ram_data_oe_ff <= 1'b0;
        ram_data_o_ff  <= '0;
        ram_data_i_ff  <= '0;
    end else begin
        ram_we_n_ff    <= ram_we_n;
        ram_addr_ff    <= ram_addr;
        ram_data_oe_ff <= ram_data_oe;
        ram_data_o_ff  <= ram_data_o;
        ram_data_i_ff  <= RAM_IO;
    end
end

// External RAM connections
assign RAM_nLB    = 1'b0;
assign RAM_nUB    = 1'b0;
assign RAM_nOE    = 1'b0;
assign RAM_nCE    = 1'b0;
assign RAM_nWE    = ram_we_n_ff;
assign RAM_A      = ram_addr_ff;
assign RAM_IO     = ram_data_oe_ff ? ram_data_o_ff : 'z;
assign ram_data_i = ram_data_i_ff;

// RAM controller bus muxes
assign ramctl_wen   = ramf_active ? ramf_wen   : acq_wen;
assign ramctl_wdata = ramf_active ? ramf_wdata : acq_wdata;
assign ramctl_addr  = ramf_active ? ramf_addr  : ramctl_ren ? ramctl_raddr : acq_waddr;

//-----------------------------------------------------------------------------
// External RAM filler
//-----------------------------------------------------------------------------
ram_filler #(
    .DATA_W  (RAM_DATA_W), // RAM data width
    .ADDR_W  (RAM_ADDR_W)  // RAM address width
) ram_filler (
    // System
    .clk         (sys_clk),     // System clock
    .rst         (sys_rst),     // System reset
    // Test control
    .fill_inc    (ramf_inc),    // Start filling with incremental data pattern
    .fill_dec    (ramf_dec),    // Start filling with decremental data pattern
    .fill_active (ramf_active), // Filling is active
    .fill_done   (ramf_done),   // Filling is done
    // RAM controller
    .addr        (ramf_addr),   // Address for RAM controller
    .wdata       (ramf_wdata),  // Write data for RAM controller
    .wen         (ramf_wen)     // Write enable for RAM controller
);

//-----------------------------------------------------------------------------
// DAC controler
//-----------------------------------------------------------------------------
dacctl #(
    .DATA_W  (DAC_DATA_W),  // DAC data width
    .SCK_DIV (DAC_SCK_DIV)  // Divider to obtain SCK from system clock
) dacctl (
    // System
    .clk        (sys_clk),      // System clock
    .rst        (sys_rst),      // System reset
    // DAC input data interface
    .din        (dac_din),      // DAC data to set output voltage
    .dvalid     (dac_dvalid),   // DAC data is valid (pulse)
    // DAC SPI output
    .spi_cs_n   (dac_spi_cs_n), // DAC SPI chip select (active low)
    .spi_sck    (dac_spi_sck),  // DAC SPI clock
    .spi_sdi    (dac_spi_sdi),  // DAC SPI data output
    .spi_ldac_n (),             // DAC SPI load data (active low)
    // Misc
    .busy       ()              // DAC controller is busy (SPI exchange is in progress)
);

always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        dac_gain_last <= '0;
    else if (dac_dvalid)
        dac_gain_last <= dac_din;
end

assign DAC_SPI_SCLK = dac_spi_sck;
assign DAC_SPI_CS   = dac_spi_cs_n;
assign DAC_SPI_MOSI = dac_spi_sdi;

//-----------------------------------------------------------------------------
// HV MUX controler
//-----------------------------------------------------------------------------
hvmuxctl #(
    .SWITCH_N (HVMUX_SWITCH_N), // HVMUX number of switches
    .CLK_DIV  (HVMUX_CLK_DIV)   // Divider to obtain mux CLK from system clock
) hvmuxctl (
    // System
    .clk        (sys_clk),        // System clock
    .rst        (sys_rst),        // System reset
    // HVMUX input data interface
    .din        (hvmux_din),        // HVMUX data to set output voltage
    .dvalid     (hvmux_dvalid),     // HVMUX data is valid (pulse)
    // HVMUX output SPI interface
    .spi_le_n   (hvmux_spi_le),   // HVMUX latch enable (active low)
    .spi_clk    (hvmux_spi_clk),  // HVMUX clock
    .spi_din    (hvmux_spi_din),  // HVMUX data output
    // Misc
    .busy       ()        // HVMUX controller is busy (SPI exchange is in progress)
);

//-----------------------------------------------------------------------------
// ADC controler
//-----------------------------------------------------------------------------
assign ADC_CLK = sys_clk;

always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        adc_d_ff <= '0;
    else
        adc_d_ff <= ADC_D;
end

assign adc_dout = adc_d_ff;

//-----------------------------------------------------------------------------
// Acquisition module
//-----------------------------------------------------------------------------
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
) acq (
    // System
    .clk              (sys_clk),          // System clock
    .rst              (sys_rst),          // System reset
    // Pulser
    .pulser_clk       (pulser_clk),       // Clock for pulse generation (2x faster than system clock)
    .pulser_rst       (pulser_rst),       // Reset for pulser logic
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
    .acq_start        (acq_start_muxed),  // Acquisition start
    .acq_busy         (acq_busy),         // Acquisition is in progress
    .acq_done         (acq_done),         // Acquisition is done
    .acq_lines        (acq_lines_muxed),  // Acquisition lines
    .acq_waddr        (acq_waddr),        // Address to save current acquisition sample
    .acq_wdata        (acq_wdata),        // Current acquisition sample value
    .acq_wen          (acq_wen),          // Acquisition sample write enable
    // Misc
    .inice            (inice)             // Inputs from PMOD header, connected to FPGA
);

// Mux for display mode
assign acq_start_muxed = acq_run_mode_sysclk ? display_acq_start_synced : acq_start;
assign acq_lines_muxed = acq_run_mode_sysclk ?                        0 : acq_lines;

assign acq_start_ext = btn_trig_pulse | trigice_pulse;

assign PON_ICE  = pulser_on;
assign POFF_ICE = pulser_off;

//-----------------------------------------------------------------------------
// Acqusition buffer
//-----------------------------------------------------------------------------
// enable filling buffer only with first line
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_buff_fill_en <= 1'b0;
    else if (acq_start_muxed)
        acq_buff_fill_en <= 1'b1;
    else if (acq_buff_wr && (!acq_wen))
        acq_buff_fill_en <= 1'b0;
end
// buffer write enable
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_buff_wr <= 1'b0;
    else if (acq_buff_fill_en)
        acq_buff_wr <= acq_wen;
    else if (!acq_buff_fill_en)
        acq_buff_wr <= 1'b0;
end
// buffer write address
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_buff_waddr <= '0;
    else if (acq_buff_fill_en)
        acq_buff_waddr <= acq_waddr[ACQ_BUFF_ADDR_OFFSET +: ACQ_BUFF_ADDR_W];
    else if (!acq_buff_fill_en)
        acq_buff_waddr <= '0;
end

assign acq_buff_chunk_end = acq_waddr[0+:ACQ_BUFF_ADDR_OFFSET] == '0;

assign acq_buff_env_next = acq_wdata[ADC_DATA_W-1] ? acq_wdata[0+:9] : 511 - acq_wdata[0+:9]; // abs
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_buff_env <= '0;
    else if (acq_buff_fill_en) begin
        if (acq_buff_chunk_end)
            acq_buff_env <= {{7{1'b0}}, acq_buff_env_next};
        else
            acq_buff_env <= acq_buff_env + {{7{1'b0}}, acq_buff_env_next};
    end else
        acq_buff_env <= '0;
end
// resulting value is mean( abs (sample - midrange))
assign acq_buff_env_mean = acq_buff_env[6+:ACQ_ENV_DATA_W]; //6 = 5 (mean for 32 samples) + 1 (scale for plot)

// dacgain sampling for acq buffer
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_buff_dacgain <= '0;
    else if (acq_buff_fill_en && (acq_waddr[0+:$clog2(ACQ_WORDS_PER_GAIN)] == '0))
        // gain is updated only every 512 samples
        acq_buff_dacgain <= dac_gain_last[2+:ACQ_ENV_DATA_W];
    else if (!acq_buff_fill_en)
        acq_buff_dacgain <= '0;
end

// topturn sampling for acq buffer
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_buff_topturn <= '0;
    else if (acq_buff_fill_en && acq_buff_chunk_end)
        acq_buff_topturn <= topturn;
    else if (!acq_buff_fill_en)
        acq_buff_topturn <= '0;
end

assign acq_buff_wdata[ 7: 0] = acq_buff_env_mean;
assign acq_buff_wdata[15: 8] = acq_buff_dacgain;
assign acq_buff_wdata[18:16] = acq_buff_topturn;
assign acq_buff_wdata[23:19] = '0;

acq_buff #(
    .ADDR_W (ACQ_BUFF_ADDR_W), // Memory depth
    .DATA_W (ACQ_BUFF_DATA_W)  // Data width
) acq_buff (
    // Write interface
    .wclk   (sys_clk),             // Write clock
    .wdata  (acq_buff_wdata), // Write data
    .waddr  (acq_buff_waddr), // Write address
    .wr     (acq_buff_wr),    // Write operation enable
    // Read interface
    .rclk   (vga_clk),             // Read clock
    .rdata  (acq_buff_rdata), // Read data
    .raddr  (acq_buff_raddr), // Read address
    .rd     (acq_buff_rd)     // Read operation enable
);

// acquisition buffer data valid
always @(posedge vga_clk or posedge vga_rst) begin
    if (vga_rst)
        acq_buff_rvalid <= 1'b0;
    else
        acq_buff_rvalid <= acq_buff_rd;
end

//-----------------------------------------------------------------------------
// VGA interface
//-----------------------------------------------------------------------------
vga #(
    .H_ACTIVE (VGA_H_ACTIVE), // Active video horizontal size (pixels)
    .V_ACTIVE (VGA_V_ACTIVE), // Active video vertical size (pixels)
    .COLOR_W  (VGA_COLOR_W)   // Color bitwidth
) vga (
    // System
    .clk          (vga_clk),       // System clock (pixel clock)
    .rst          (vga_rst),       // System reset
    // VGA interface
    .vga_hsync    (vga_hsync),    // VGA horizontal sync
    .vga_vsync    (vga_vsync),    // VGA vertical sync
    .vga_r        (vga_ch_r),        // VGA red channel
    .vga_g        (vga_ch_g),        // VGA green channel
    .vga_b        (vga_ch_b),        // VGA blue channel
    // Display control
    .en           (vga_en),               // VGA enable
    .pixel_r      (display_pixel_r),      // Display pixel red channel
    .pixel_g      (display_pixel_g),      // Display pixel green channel
    .pixel_b      (display_pixel_b),      // Display pixel blue channel
    .line_active  (display_line_active),  // Line is active
    .frame_active (display_frame_active), // Frame is active
    .px_cnt       (display_px_cnt),       // Horizontal (active pixel) counter
    .line_cnt     (display_line_cnt)      // Vertical (active line) counter
);

assign IO1_RPI = vga_ch_g;
assign IO2_RPI = vga_vsync;
//assign IO3_RPI = ;
assign IO4_RPI = vga_hsync;

//-----------------------------------------------------------------------------
// Display controller
//-----------------------------------------------------------------------------
display #(
    .H_ACTIVE (VGA_H_ACTIVE),
    .V_ACTIVE (VGA_V_ACTIVE),
    .COLOR_W  (VGA_COLOR_W)
) display (
    .clk              (vga_clk),
    .rst              (vga_rst),
    // Display control
    .vga_en           (vga_en),                // Display enable
    .pixel_r          (display_pixel_r),       // Display pixel red channel
    .pixel_g          (display_pixel_g),       // Display pixel green channel
    .pixel_b          (display_pixel_b),       // Display pixel blue channel
    .line_active      (display_line_active),   // Line is active
    .frame_active     (display_frame_active),  // Frame is active
    .px_cnt           (display_px_cnt),        // Horizontal (active pixel) counter
    .line_cnt         (display_line_cnt),      // Vertical (active line) counter
    .run_mode         (acq_run_mode),          // Display run mode active
    // Acquisition interface
    .acq_start        (display_acq_start),     // Start aquisition
    .acq_done         (display_acq_done),      // Aquisition is done
    .acq_buff_rvalid  (acq_buff_rvalid),       // Aquisition buffer data is valid
    .acq_buff_rdata   (acq_buff_rdata),        // Acquisition buffer read data
    .acq_buff_raddr   (acq_buff_raddr),        // Acuisition buffer read address
    .acq_buff_rd      (acq_buff_rd),           // Acuisition buffer read enable
    // Pulser parameters
    .pulser_init_len  (pulser_init_len),       // Pulser initial delay
    .pulser_on_len    (pulser_on_len),         // Pulser on width
    .pulser_off_len   (pulser_off_len),        // Pulser off width
    .pulser_inter_len (pulser_inter_len)       // Pulser intermediate delay
);

sync_2ff display_acq_start_sync (
    .clk  (sys_clk),                 // Destination domain clock
    .rst  (sys_rst),                 // Destination domain active low reset
    .din  (display_acq_start),       // Source domain data
    .dout (display_acq_start_synced) // Destination domain data
);

sync_2ff acq_done_sync (
    .clk  (vga_clk),         // Destination domain clock
    .rst  (vga_rst),         // Destination domain active low reset
    .din  (acq_done),        // Source domain data
    .dout (display_acq_done) // Destination domain data
);

sync_2ff acq_busy_sync (
    .clk  (vga_clk),         // Destination domain clock
    .rst  (vga_rst),         // Destination domain active low reset
    .din  (acq_busy),        // Source domain data
    .dout (display_acq_busy) // Destination domain data
);

//-----------------------------------------------------------------------------
// JUMPERn sampling
//-----------------------------------------------------------------------------
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        jumper_ff <= '0;
    else
        jumper_ff <= {JUMPER3, JUMPER2, 1'b0};
end

assign jumper = jumper_ff;

debouncer #(
    .DELAY (DEBOUNCE_DELAY) // delay in clk ticks
) jumper2_debouncer (
    .clk    (sys_clk),
    .rst    (sys_rst),
    .din    (jumper[1]),
    .dout   (acq_run_mode_next)
);

always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        acq_run_mode <= 1'b0;
    else if ((!display_acq_busy) && (!vga_vsync))
        acq_run_mode <= acq_run_mode_next;
end

sync_2ff acq_run_mode_sync (
    .clk  (sys_clk),         // Destination domain clock
    .rst  (sys_rst),         // Destination domain active low reset
    .din  (acq_run_mode),       // Source domain data
    .dout (acq_run_mode_sysclk) // Destination domain data
);

//-----------------------------------------------------------------------------
// INn_ICE sampling
//-----------------------------------------------------------------------------
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        inice_ff <= '0;
    else
        inice_ff <= {IN3_ICE, IN2_ICE, IN1_ICE};
end

assign inice = inice_ff;

//-----------------------------------------------------------------------------
// TOP_TURNn sampling
//-----------------------------------------------------------------------------
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
        topturn_ff <= '0;
    else
        topturn_ff <= {TOP_TURN3, TOP_TURN2, TOP_TURN1};
end

assign topturn = topturn_ff;

//-----------------------------------------------------------------------------
// OUTn_ICE control
//-----------------------------------------------------------------------------
assign OUT1_ICE = hvmux_en ? hvmux_spi_le  : outice[0];
assign OUT2_ICE = hvmux_en ? hvmux_spi_clk : outice[1];
assign OUT3_ICE = hvmux_en ? hvmux_spi_din : outice[2];

//-----------------------------------------------------------------------------
// External triggers
//-----------------------------------------------------------------------------
// Trigger input
debouncer #(
    .DELAY (DEBOUNCE_DELAY) // delay in clk ticks
) trigice_debouncer (
    .clk    (sys_clk),
    .rst    (sys_rst),
    .din    (TRIG_ICE),
    .dout   (trigice)
);
// latch trigger intput to create pulse
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
        trigice_ff <= 1'b0;
    end else begin
        trigice_ff <= trigice;
    end
end
assign trigice_pulse = trigice & (~trigice_ff);

//-----------------------------------------------------------------------------
// Buttons sampling
//-----------------------------------------------------------------------------
// Trigger button
debouncer #(
    .DELAY (DEBOUNCE_DELAY) // delay in clk ticks
) btn_trig_debouncer (
    .clk    (sys_clk),
    .rst    (sys_rst),
    .din    (BUTTON_TRIG),
    .dout   (btn_trig)
);
// latch button intput to create pulse
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
        btn_trig_ff <= 1'b0;
    end else begin
        btn_trig_ff <= btn_trig;
    end
end
assign btn_trig_pulse = btn_trig & (~btn_trig_ff);

//-----------------------------------------------------------------------------
// LED control
//-----------------------------------------------------------------------------
// simple clock divider for led3 blinking
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
        led3_cnt <= '0;
    end else begin
        led3_cnt <= led3_cnt + 1;
    end
end
// select between csr and hw drivers of led3
always @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
        led3_csr_sel <= 1'b0;
    end else if (csr_wen || csr_ren) begin
        // after reset LED3 is blinking, but after any csr access - csr become the driver
        led3_csr_sel <= 1'b1;
    end
end

assign LED_ACQUISITION  = led[0];
assign LED_SINGLE_nLOOP = led[1];
assign LED3             = led3_csr_sel ? led[2] : led3_cnt[LED_CNT_W-1];

endmodule
