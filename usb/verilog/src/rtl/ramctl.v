//-------------------------------------------------------------------
// Asynchronous SRAM controller
//
//-------------------------------------------------------------------
module ramctl #(
    parameter DATA_W = 16, // RAM data width
    parameter ADDR_W = 19  // RAM address width
)(
    // System
    input  wire              clk,         // System clock
    input  wire              rst,         // System reset
    // External async ram interface
    output reg  [ADDR_W-1:0] ram_addr,    // External RAM address
    input  wire [DATA_W-1:0] ram_data_i,  // External RAM data input
    output reg  [DATA_W-1:0] ram_data_o,  // External RAM data output
    output reg               ram_data_oe, // External RAM data output enable
    output reg               ram_we_n,    // External RAM write enable (active low)
    // Internal fpga interface
    input  wire [ADDR_W-1:0] addr,        // RAM controller address
    input  wire [DATA_W-1:0] wdata,       // RAM controller write data
    input  wire              wen,         // RAM controller write enable
    output reg  [DATA_W-1:0] rdata,       // RAM controller read data
    output reg               rvalid,      // RAM controller read data is valid
    input  wire              ren          // RAM controller read enable
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
wire [ADDR_W-1:0] ram_addr_next;
wire [DATA_W-1:0] ram_data_o_next;
wire              ram_data_oe_next;
wire              ram_we_n_next;

reg [ADDR_W-1:0] addr_ff;
reg [DATA_W-1:0] wdata_ff;
reg              wen_ff;
reg              ren_ff0, ren_ff1, ren_ff2;

//-----------------------------------------------------------------------------
// Write
//-----------------------------------------------------------------------------
// Delay some signals for write operation
always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr_ff  <= '0;
        wdata_ff <= '0;
        wen_ff   <= 1'b0;
    end else begin
        addr_ff  <= addr;
        wdata_ff <= wdata;
        wen_ff   <= wen;
    end
end

//-----------------------------------------------------------------------------
// Read
//-----------------------------------------------------------------------------
wire ren_del;

assign ren_del = ren_ff2; // ren_ff0 - read is done in 1 cycle, ren_ff1 - in 2 cycles, etc

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ren_ff0 <= 1'b0;
        ren_ff1 <= 1'b0;
        ren_ff2 <= 1'b0;
    end else begin
        ren_ff0 <= ren;
        ren_ff1 <= ren_ff0;
        ren_ff2 <= ren_ff1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst)
        rvalid <= 1'b0;
    else if (ren_del && ren && (!rvalid))
        rvalid <= 1'b1;
    else
        rvalid <= 1'b0;
end

always @(posedge clk or posedge rst) begin
    if (rst)
        rdata <= '0;
    else if (ren_del)
        rdata <= ram_data_i;
    else
        rdata <= '0;
end

//-----------------------------------------------------------------------------
// Outputs to RAM
//-----------------------------------------------------------------------------
assign ram_addr_next    = addr_ff;
assign ram_we_n_next    = (~wen_ff);
assign ram_data_o_next  = wdata_ff;
assign ram_data_oe_next = wen_ff;

always @(*) begin
    // final ff will be in IO cells
    ram_addr    = ram_addr_next;
    ram_data_o  = ram_data_o_next;
    ram_data_oe = ram_data_oe_next;
    ram_we_n    = ram_we_n_next;
end

endmodule