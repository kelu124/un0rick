//-------------------------------------------------------------------
// Test for hex_ch module
//-------------------------------------------------------------------
module tb_hex_ch();

//-------------------------------------------------------------------
// Clock and reset
//-------------------------------------------------------------------
reg tb_clk = 0;
always begin
    #12.5; // 40 MHz
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
localparam CH_W = 4;
localparam CH_ROW_W = 3;

reg [CH_W-1:0]     ch_sel = 0;
reg [CH_ROW_W-1:0] row_sel = 0;
reg                ch_px_rd = 0;
wire               ch_px_valid;
wire               ch_px_out;
    
hex_ch #(
    .CH_W     (CH_W),
    .CH_ROW_W (CH_ROW_W)
) dut (
    .clk         (tb_clk),
    .rst         (tb_rst),
    // Pixel control
    .ch_sel      (ch_sel),      // Select character 0 ... F
    .row_sel     (row_sel),     // Select character pixel row
    .ch_px_rd    (ch_px_rd),    // Read character pixel
    .ch_px_valid (ch_px_valid), // Output pixel is valid
    .ch_px_out   (ch_px_out)    // Output pixel value
);

//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------
// Main test
initial begin : tb_main
    integer i;
    integer err_cnt;
    err_cnt = 0;

    wait(!tb_rst);
    repeat (3) @(posedge tb_clk);

    @(posedge tb_clk);
    ch_sel   <= 4'hA;
    row_sel  <= 0;
    ch_px_rd <= 1'b1;

    repeat (7) @(posedge tb_clk);
    ch_sel   <= 4'h7;

    repeat (9) @(posedge tb_clk);
    ch_px_rd <= 1'b0;

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
    $dumpvars(0, tb_hex_ch);
end
`endif

endmodule