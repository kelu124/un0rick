//-------------------------------------------------------------------
// Simple 2 flip-flop sync cell
//
//-------------------------------------------------------------------

module sync_2ff #(
    parameter FF_INIT = 1'b0
)(
    input  wire clk,  // Destination domain clock
    input  wire rst,  // Destination domain active low reset
    input  wire din,  // Source domain data
    output wire dout  // Destination domain data
);

reg ff0, ff1;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ff0 <= FF_INIT;
        ff1 <= FF_INIT;
    end else begin
        ff0 <= din;
        ff1 <= ff0;
    end
end

assign dout = ff1;

endmodule
