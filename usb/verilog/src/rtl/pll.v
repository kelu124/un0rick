//-------------------------------------------------------------------
// Wrapper around PLL IP.
// Based on the output of util/pll/gen_pll script.
// All output frequencies are calculated for 12 MHz input.
//
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module pll #(
    parameter FREQ_MHZ = 128 // one of 32, 40, 48, 64, 128
)(
    input  clk_in,
    output clk_out,
    output lock
);

localparam ACTUAL_FREQ_MHZ = (FREQ_MHZ == 32)  ?  31.875 :
                             (FREQ_MHZ == 40)  ?  39.750 :
                             (FREQ_MHZ == 48)  ?  48.000 :
                             (FREQ_MHZ == 64)  ?  63.750 :
                             (FREQ_MHZ == 128) ? 127.500 : -1.0;

localparam DIVR = 0;

localparam DIVF = (FREQ_MHZ == 32)  ? 84 :
                  (FREQ_MHZ == 40)  ? 52 :
                  (FREQ_MHZ == 48)  ? 63 :
                  (FREQ_MHZ == 64)  ? 84 :
                  (FREQ_MHZ == 128) ? 84 : -1;

localparam DIVQ = (FREQ_MHZ == 32)  ? 5 :
                  (FREQ_MHZ == 40)  ? 4 :
                  (FREQ_MHZ == 48)  ? 4 :
                  (FREQ_MHZ == 64)  ? 4 :
                  (FREQ_MHZ == 128) ? 3 : -1;

`ifdef SIM
    reg pll_clk = 1'b0;
    always #(500.0/ACTUAL_FREQ_MHZ) pll_clk <= ~pll_clk;
    assign clk_out = pll_clk;

    reg pll_lock = 1'b0;
    initial #(100) pll_lock <= 1'b1;
    assign lock = pll_lock;
`else
    SB_PLL40_CORE #(
    //SB_PLL40_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(DIVR),
        .DIVF(DIVF),
        .DIVQ(DIVQ),
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
`endif

endmodule
