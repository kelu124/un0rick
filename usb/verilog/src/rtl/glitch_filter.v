//-------------------------------------------------------------------
// Remove all glitchces less than reference clock period
// Based on US8558579B2 patent.
//
//-------------------------------------------------------------------

module glitch_filter (
    input  wire clk,
    input  wire din,
    output wire dout
);

reg       din_ff0 = 1'b0;
reg       din_ff1 = 1'b0;
reg [1:0] dout_ff = 2'b00;
wire      din_n;

assign din_n = ~din;

always @(posedge clk or negedge din_n) begin
    if (!din_n) 
        din_ff0 <= 1'b0;
    else
        din_ff0 <= 1'b1;
end

always @(posedge clk or negedge din) begin
    if (!din)
        din_ff1 <= 1'b0;
    else
        din_ff1 <= 1'b1;
end

always @(posedge clk) begin
    dout_ff <= {dout_ff[0], (dout_ff[0] & din_ff0) | din_ff1};
end

assign dout = dout_ff[1];

endmodule
