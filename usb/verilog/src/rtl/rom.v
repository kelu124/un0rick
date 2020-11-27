//-------------------------------------------------------------------
// ROM primitive
//
//-------------------------------------------------------------------

module rom #(
    parameter WORD_N    = 256,            // Number of words
    parameter ADDR_W    = $clog2(WORD_N), // Memory depth
    parameter DATA_W    = 16,             // Data width
    parameter INIT_FILE = ""
)(
    // System
    input wire               clk,   // System clock
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
reg [DATA_W-1:0] mem [WORD_N-1:0];

// Read port
always @(posedge clk) begin
    if (rd)
        rdata <= mem[raddr];
end

endmodule
