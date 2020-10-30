//-------------------------------------------------------------------
// Clock divider primitive
//
//-------------------------------------------------------------------
module clkdiv (
    input  wire clk_in,
    output wire clk_div2,
    output wire clk_div4,
    output wire clk_div8,
    output wire clk_div16
);

reg [3:0] clk_div_cnt = '0; // 4 bit width beacause of LUT4 is used

always @(posedge clk_in) begin
    clk_div_cnt <= clk_div_cnt + 1;
end

assign clk_div2  = clk_div_cnt[0];
assign clk_div4  = clk_div_cnt[1];
assign clk_div8  = clk_div_cnt[2];
assign clk_div16 = clk_div_cnt[3];
    
endmodule