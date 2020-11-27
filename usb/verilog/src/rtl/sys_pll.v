//-------------------------------------------------------------------
// Wrapper around PLL IP.
// Generates from 12 MHz input pad:
//  * pulser_clk - 128 MHz - 127.5 MHz actually
//  * sys_clk - 64 MHz - 63.75 MHz actually
//
//-------------------------------------------------------------------

`timescale 1ns / 1ps

module sys_pll (
    inout  ref_clk,
    output pulser_clk,
    output sys_clk,
    output lock
);

`ifdef SIM
    reg pulser_clk_drv = 1'b0;
    always #(500.0/127.5) pulser_clk_drv <= ~pulser_clk_drv;
    assign pulser_clk = pulser_clk_drv;

    reg sys_clk_drv = 1'b0;
    always #(500.0/63.75) sys_clk_drv <= ~sys_clk_drv;
    assign sys_clk = sys_clk_drv;

    reg pll_lock = 1'b0;
    initial #(100) pll_lock <= 1'b1;
    assign lock = pll_lock;
`else
SB_PLL40_2F_CORE #(
    .DIVR (4'b0000),
    .DIVF (7'b1010100),
    .DIVQ (3'b011),
    .FILTER_RANGE (3'b001),
    .FEEDBACK_PATH ("SIMPLE"),
    .PLLOUT_SELECT_PORTA ("GENCLK"),
    .PLLOUT_SELECT_PORTB ("GENCLK_HALF")
) pll_ip (
    .LOCK          (lock),
    .RESETB        (1'b1),
    .REFERENCECLK  (ref_clk),
    .PLLOUTGLOBALA (pulser_clk),
    .PLLOUTGLOBALB (sys_clk)
);
`endif

endmodule
