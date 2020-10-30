//-------------------------------------------------------------------
// Wrapper around PLL IP.
// Based on the output of util/pll/gen_pll script.
//
//-------------------------------------------------------------------

module pll(
    input  clk_in,
    output clk_out,
    output lock
);

SB_PLL40_CORE #(
//SB_PLL40_PAD #(
    .FEEDBACK_PATH("SIMPLE"),
    // 12 MHz -> 128 MHz (127.5 MHz actually)
    .DIVR(4'b0000),    // DIVR =  0
    .DIVF(7'b1010100), // DIVF = 84
    .DIVQ(3'b011),     // DIVQ =  3
    // 12 MHz -> 64 MHz (63.75 MHz actually)
    //.DIVR(4'b0000),    // DIVR =  0
    //.DIVF(7'b1010100), // DIVF = 84
    //.DIVQ(3'b100),     // DIVQ =  4
    // 12 MHz -> 48 MHz (48 MHz actually)
    //.DIVR(4'b0000),    // DIVR =  0
    //.DIVF(7'b0111111), // DIVF = 63
    //.DIVQ(3'b100),     // DIVQ =  4
    // 12 MHz -> 32 MHz (31.875 actually)
    //.DIVR(4'b0000),    // DIVR =  0
    //.DIVF(7'b1010100), // DIVF = 84
    //.DIVQ(3'b101),     // DIVQ =  5
    .FILTER_RANGE(3'b001) // FILTER_RANGE = 1
) pll_ip (
    .LOCK         (lock),
    .RESETB       (1'b1),
    .BYPASS       (1'b0),
    //.PACKAGEPIN   (clk_in),
    .REFERENCECLK (clk_in),
    .PLLOUTCORE (clk_out)
    //.PLLOUTGLOBAL (clk_out)
);

endmodule
