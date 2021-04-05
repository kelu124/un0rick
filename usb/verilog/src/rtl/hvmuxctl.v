//-------------------------------------------------------------------
// MAX141866 HM mux controller
//
//-------------------------------------------------------------------

module hvmuxctl #(
    parameter SWITCH_N = 16, // HVMUX number of switches
    parameter CLK_DIV  = 8   // Divider to obtain mux CLK from system clock
)(
    // System
    input  wire              clk,        // System clock
    input  wire              rst,        // System reset
    // HVMUX input data interface
    input  wire [SWITCH_N-1:0] din,        // HVMUX data to set output voltage
    input  wire              dvalid,     // HVMUX data is valid (pulse)
    // HVMUX output SPI interface
    output reg               spi_le_n,   // HVMUX latch enable (active low)
    output reg               spi_clk,    // HVMUX clock
    output reg               spi_din,    // HVMUX data output
    // Misc
    output reg               busy        // HVMUX controller is busy (SPI exchange is in progress)
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam DIV_CNT_MAX = (CLK_DIV / 2) - 1;
localparam SHIFTER_W   = SWITCH_N + 2; // count to SWITCH_N bits + 1 for LE generation

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg [$clog2(SHIFTER_W)-1:0] bit_cnt;
reg [$clog2(DIV_CNT_MAX)-1:0] clk_div_cnt;
wire clk_div_cnt_ovf;
reg sck_int;
reg [SHIFTER_W-1:0] shifter;
wire busy_clr;

//-----------------------------------------------------------------------------
// Clock divider
//-----------------------------------------------------------------------------
assign clk_div_cnt_ovf = (clk_div_cnt == DIV_CNT_MAX) ? 1'b1 : 1'b0;

always @(posedge clk or posedge rst) begin
    if (rst)
        clk_div_cnt <= '0;
    else if (clk_div_cnt_ovf || (!busy))
        clk_div_cnt <= '0;
    else
        clk_div_cnt <= clk_div_cnt + 1;
end

//-----------------------------------------------------------------------------
// Busy logic
//-----------------------------------------------------------------------------
assign busy_clr = (bit_cnt == (SHIFTER_W - 1)) ? clk_div_cnt_ovf : 0;

always @(posedge clk or posedge rst) begin
    if (rst)
        busy <= 1'b0;
    else if (busy_clr)
        busy <= 1'b0;
    else if (dvalid)
        busy <= 1;
end

//-----------------------------------------------------------------------------
// SPI
//-----------------------------------------------------------------------------
// SCK generation
always @(posedge clk or posedge rst) begin
    if (rst)
        sck_int <= 1'b0;
    else if (!busy)
        sck_int <= 1'b0;
    else if (clk_div_cnt_ovf)
        sck_int <= ~sck_int;
end
// SPI data shifter
always @(posedge clk or posedge rst) begin
    if (rst) begin
        bit_cnt <= '0;
        shifter <= '0;
    end else if (dvalid) begin
        shifter <= {din, {(SHIFTER_W-SWITCH_N){1'b0}}};
        bit_cnt <= '0;
    end else if (clk_div_cnt_ovf && sck_int) begin
        shifter <= {shifter[SHIFTER_W-2:0], 1'b0};
        bit_cnt <= bit_cnt + 1;
    end
end
// SPI outputs
always @(posedge clk or posedge rst) begin
    if (rst) begin
        spi_clk  <= 1'b0;
        spi_din  <= 1'b0;
        spi_le_n <= 1'b1;
    end else begin
        spi_clk  <= (bit_cnt < (SHIFTER_W - 2))? sck_int : 1'b0;
        spi_din  <= shifter[SHIFTER_W-1];
        spi_le_n <= (bit_cnt == (SHIFTER_W - 2)) ? ~sck_int : 1'b1;
    end
end

endmodule
