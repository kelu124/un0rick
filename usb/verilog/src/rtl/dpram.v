//-------------------------------------------------------------------
// Dual port RAM primitive
//
//-------------------------------------------------------------------

module dpram #(
    parameter ADDR_W    = 2,   // Memory depth
    parameter DATA_W    = 16,  // Data width
    parameter INIT_FILE = ""
)(
    // System
    input wire               clk,   // System clock
    // Write interface
    input  wire [DATA_W-1:0] wdata, // Write data
    input  wire [ADDR_W-1:0] waddr, // Write address
    input  wire              wr,    // Write operation enable
    // Read interface
    output reg  [DATA_W-1:0] rdata, // Read data
    input  wire [ADDR_W-1:0] raddr, // Read address
    input  wire              rd     // Read operation enable
);

// Init memory
initial begin
    if (INIT_FILE)
        $readmemh(INIT_FILE, mem);
end

// Memory array
reg [DATA_W-1:0] mem [2**ADDR_W-1:0];

// Write port
always @(posedge clk) begin
    if (wr)
        mem[waddr] <= wdata;
end

// Read port
always @(posedge clk) begin
    if (rd)
        rdata <= mem[raddr];
end

endmodule
