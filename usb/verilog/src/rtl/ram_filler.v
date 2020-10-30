//-------------------------------------------------------------------
// Simple module to fill external RAM with specified pattern
//
//-------------------------------------------------------------------
module ram_filler #(
    parameter DATA_W = 16, // RAM data width
    parameter ADDR_W = 19  // RAM address width
)(
    // System
    input  wire              clk,         // System clock
    input  wire              rst,         // System reset
    // Filling control
    input  wire              fill_inc,    // Start filling with incremental data pattern
    input  wire              fill_dec,    // Start filling with decremental data pattern
    output wire              fill_active, // Filling is active
    output reg               fill_done,   // Filling is done
    // RAM controller
    output reg  [ADDR_W-1:0] addr,        // Address for RAM controller
    output reg  [DATA_W-1:0] wdata,       // Write data for RAM controller
    output reg               wen          // Write enable for RAM controller
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
wire busy;
reg  busy_inc;
reg  busy_dec;
wire last_addr;

//-----------------------------------------------------------------------------
// Test control
//-----------------------------------------------------------------------------
assign busy      = busy_inc | busy_dec;
assign last_addr = (addr == {ADDR_W{1'b1}}) ? 1'b1 : 1'b0;
assign fill_active = busy;

// Start incremental filling
always @(posedge clk or posedge rst) begin
    if (rst)
        busy_inc <= 1'b0;
    else if (fill_inc & (~busy))
        busy_inc <= 1'b1;
    else if (last_addr)
        busy_inc <= 1'b0;
end
// Start decremental filling
always @(posedge clk or posedge rst) begin
    if (rst)
        busy_dec <= 1'b0;
    else if (fill_dec & (~busy))
        busy_dec <= 1'b1;
    else if (last_addr)
        busy_dec <= 1'b0;
end
// Filling is done
always @(posedge clk or posedge rst) begin
    if (rst)
        fill_done <= 1'b0;
    else if (last_addr)
        fill_done <= 1'b1;
    else if (fill_inc || fill_dec)
        fill_done <= 1'b0;
end

//-----------------------------------------------------------------------------
// Address and control
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        addr <= '0;
        wen  <= 1'b0;
    end else if (last_addr) begin
        addr <= '0;
        wen  <= 1'b0;
    end else if (busy) begin
        addr <= wen ? addr + 1 : addr;
        wen  <= 1'b1;
    end
end

//-----------------------------------------------------------------------------
// Data generation for tests
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst)
        wdata <= '0;
    else if (last_addr)
        wdata <= '0;
    else if (busy_inc && wen)
        wdata <= wdata + 1;
    else if (busy_dec)
        wdata <= wdata - 1;
end

endmodule