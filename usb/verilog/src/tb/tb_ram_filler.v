//-------------------------------------------------------------------
// Test for ram_filler module
//-------------------------------------------------------------------
module tb_ram_filler();

//-------------------------------------------------------------------
// Clock and reset
//-------------------------------------------------------------------
reg tb_clk = 0;
always begin
    #7.8125; // 64 MHz
    tb_clk <= ~tb_clk;
end

reg tb_rst = 1;
initial begin
    repeat(3) @(posedge tb_clk);
    @(negedge tb_clk);
    tb_rst <= 0;
end

//-------------------------------------------------------------------
// DUT
//-------------------------------------------------------------------
localparam ADDR_W = 3;
localparam DATA_W = 16;

reg  fill_inc = 1'b0;
reg  fill_dec = 1'b0;
wire fill_active;
wire fill_done;

wire  [ADDR_W-1:0] addr;
wire  [DATA_W-1:0] wdata;
wire               wen;

ram_filler #(
    .DATA_W  (DATA_W),
    .ADDR_W  (ADDR_W)
) ram_filler (
    // System
    .clk         (tb_clk),
    .rst         (tb_rst),
    // Test control
    .fill_inc    (fill_inc),
    .fill_dec    (fill_dec),
    .fill_active (fill_active),
    .fill_done   (fill_done),
    // RAM controller
    .addr        (addr),
    .wdata       (wdata),
    .wen         (wen)
);

//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------

// Main test
initial begin : tb_main
    integer err_cnt;
    err_cnt = 0;

    wait(tb_rst);
    repeat (3) @(posedge tb_clk);

    // fill incremental pattern
    @(posedge tb_clk);
    fill_inc = 1'b1;
    @(posedge tb_clk);
    fill_inc = 1'b0;
    @(posedge tb_clk);
    wait(fill_done);
    @(posedge tb_clk);

    // fill decremental pattern
    @(posedge tb_clk);
    fill_dec = 1'b1;
    @(posedge tb_clk);
    fill_dec = 1'b0;
    @(posedge tb_clk);
    wait(fill_done);
    @(posedge tb_clk);

    repeat (3) @(posedge tb_clk);
    if (err_cnt)
        $error("Test failed with %0d errors!", err_cnt);
    else
        $display("Test passed!");

    `ifdef __ICARUS__
        $finish;
    `else
        $stop;
    `endif
end

`ifdef __ICARUS__
initial begin
    $dumpfile("work.vcd");
    $dumpvars(0, tb_ram_filler);
end
`endif

endmodule