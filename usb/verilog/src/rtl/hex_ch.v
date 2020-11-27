//-------------------------------------------------------------------
// Hexademical characters set for a display.
//
// Characters have size of 8x8 pixels. One row is stored in a byte (little-endian).
//
//-------------------------------------------------------------------

module hex_ch #(
    parameter CH_W = 4,
    parameter CH_ROW_W = 3,
    parameter CH_COL_W = 3
)(
    input  wire clk,
    input  wire rst,
    // Pixel control
    input  wire [CH_W-1:0]     ch_sel,      // Select character 0 ... F
    input  wire [CH_ROW_W-1:0] row_sel,     // Select character pixel row
    input  wire                ch_px_rd,    // Read character pixel
    output reg                 ch_px_valid, // Output pixel is valid
    output wire                ch_px_out    // Output pixel value
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam ROM_WORD_N = 128;
localparam ROM_ADDR_W = $clog2(ROM_WORD_N);
localparam ROM_DATA_W = 8;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg ch_px_rd_ff;

wire [ROM_DATA_W-1:0] rom_rdata;
wire [ROM_ADDR_W-1:0] rom_raddr;

reg [ROM_DATA_W-1:0] rdata_shifter;

reg [CH_COL_W-1:0] px_cnt;

//-----------------------------------------------------------------------------
// Character pixels ROM
//-----------------------------------------------------------------------------
assign rom_raddr = {ch_sel, row_sel};

rom #(
    .WORD_N    (ROM_WORD_N),
    .DATA_W    (ROM_DATA_W),
    .INIT_FILE ("../../src/rtl/hex_ch.mem")
) rom (
    // System
    .clk   (clk),   // System clock
    // Read interface
    .rdata (rom_rdata), // Read data
    .raddr (rom_raddr), // Read address
    .rd    (1'b1)    // Read operation
);

//-----------------------------------------------------------------------------
// Pixel reader
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst)
        ch_px_rd_ff <= 1'b0;
    else
        ch_px_rd_ff <= ch_px_rd;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        ch_px_valid <= 1'b0;
    else
        ch_px_valid <= ch_px_rd_ff;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        px_cnt <= 0;
    else if (ch_px_valid)
        px_cnt <= px_cnt + 1;
    else
        px_cnt <= 0;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        rdata_shifter <= '0;
    else if (ch_px_valid && (px_cnt == '1))
        rdata_shifter <= rom_rdata;
    else if (ch_px_valid)
        rdata_shifter <= rdata_shifter >> 1;
    else
        rdata_shifter <= rom_rdata;
    
end

assign ch_px_out = rdata_shifter[0];

endmodule
