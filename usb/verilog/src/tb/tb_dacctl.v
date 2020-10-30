//-------------------------------------------------------------------
// Test for dacctl module
//-------------------------------------------------------------------
module tb_dacctl();

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
localparam DATA_W = 10;

reg [DATA_W-1:0] din = '0;
reg              dvalid = '0;

wire dac_cs_n;
wire dac_sck;
wire dac_sdi;
wire dac_ldac_n;

dacctl #(
    .DATA_W (DATA_W)
) dut (
    // System
    .clk        (tb_clk),
    .rst        (tb_rst),
    // DAC input data interface
    .din        (din),
    .dvalid     (dvalid),
    // DAC SPI output
    .spi_cs_n   (dac_cs_n),
    .spi_sck    (dac_sck),
    .spi_sdi    (dac_sdi),
    .spi_ldac_n (dac_ldac_n),
    // Misc
    .busy       (busy)
);

mcp4811 #(
    .DAC_DATA_W (DATA_W)
) mcp4811 (
    .cs_n   (dac_cs_n),
    .sck    (dac_sck),
    .sdi    (dac_sdi),
    .ld_n   (dac_ldac_n)
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

    @(posedge tb_clk);
    din <= 10'h1AE;
    dvalid <= 1'b1;
    @(posedge tb_clk);
    dvalid <= 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);
    wait(!busy);
    repeat (10) @(posedge tb_clk);

    @(posedge tb_clk);
    din <= 10'h305;
    dvalid <= 1'b1;
    @(posedge tb_clk);
    dvalid <= 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);
    wait(!busy);
    repeat (10) @(posedge tb_clk);

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
    $dumpvars(0, tb_dacctl);
end
`endif

endmodule