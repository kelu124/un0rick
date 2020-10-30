//-------------------------------------------------------------------
// MCP4811 DAC controller
//
//-------------------------------------------------------------------

module dacctl #(
    parameter DATA_W   = 10, // DAC data width
    parameter SCK_DIV  = 8,  // Divider to obtain SCK from system clock
    parameter LDAC_USE = 0   // 0 - LDACn tied to low, 1 - LDACn generation is used
)(
    // System
    input  wire              clk,        // System clock
    input  wire              rst,        // System reset
    // DAC input data interface
    input  wire [DATA_W-1:0] din,        // DAC data to set output voltage
    input  wire              dvalid,     // DAC data is valid (pulse)
    // DAC SPI master
    output reg               spi_cs_n,   // DAC SPI chip select (active low)
    output reg               spi_sck,    // DAC SPI clock
    output reg               spi_sdi,    // DAC SPI data output
    output reg               spi_ldac_n, // DAC SPI load data (active low)
    // Misc
    output reg               busy        // DAC controller is busy (SPI exchange is in progress)
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam DIV_CNT_MAX = (SCK_DIV / 2) - 1;
localparam CMD_WORD_W  = 16;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg [$clog2(CMD_WORD_W + 3)-1:0] bit_cnt;
reg [$clog2(DIV_CNT_MAX)-1:0] clk_div_cnt;
wire clk_div_cnt_ovf;
reg sck_int;
reg [CMD_WORD_W-1:0] shifter;
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
assign busy_clr = (bit_cnt == (CMD_WORD_W + (LDAC_USE? 2 : 0))) ? clk_div_cnt_ovf : 0;

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
        shifter <= {4'b0011, din, 2'b00};
        bit_cnt <= '0;
    end else if (clk_div_cnt_ovf && sck_int) begin
        shifter <= {shifter[CMD_WORD_W-2:0], 1'b0};
        bit_cnt <= bit_cnt + 1;
    end
end
// DAC SPI outputs
always @(posedge clk or posedge rst) begin
    if (rst) begin
        spi_cs_n   <= 1'b1;
        spi_sck    <= 1'b0;
        spi_sdi    <= 1'b0;
        // If LDAC is tied to low, data update will be performed on CSn posedge
        spi_ldac_n <= LDAC_USE ? 1'b1 : 1'b0;
    end else begin
        spi_sck    <= sck_int & (~spi_cs_n);
        spi_cs_n   <= (bit_cnt < CMD_WORD_W) ? ~busy : 1'b1;
        spi_sdi    <= shifter[CMD_WORD_W-1];
        spi_ldac_n <= LDAC_USE ? ((bit_cnt == (CMD_WORD_W + 1)) ? 1'b0 : 1'b1) : 1'b0;
    end
end

endmodule
