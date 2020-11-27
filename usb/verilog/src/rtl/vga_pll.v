//-------------------------------------------------------------------
// Wrapper around PLL IP.
// Generates from 12 MHz input clock:
//  * vga_clk - 36 MHz - 36.00 MHz actually
//
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module vga_pll (
    input  ref_clk,
    output vga_clk,
    output lock
);

`ifdef SIM
    reg vga_clk_drv = 1'b0;
    always #(500.0/36.0) vga_clk_drv <= ~vga_clk_drv;
    assign vga_clk = vga_clk_drv;

    reg pll_lock = 1'b0;
    initial #(100) pll_lock <= 1'b1;
    assign lock = pll_lock;
`else
SB_PLL40_CORE #(
    .DIVR          (4'b0000),
    .DIVF          (7'b0101111),
    .DIVQ          (3'b100),
    .FILTER_RANGE  (3'b100),
    .FEEDBACK_PATH ("SIMPLE")
) pll_ip (
    .LOCK         (lock),
    .RESETB       (1'b1),
    .BYPASS       (1'b0),
    .REFERENCECLK (ref_clk),
    .PLLOUTGLOBAL (vga_clk)
);
`endif

endmodule
