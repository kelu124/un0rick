//-------------------------------------------------------------------
// Test for hvmuxctl module
//-------------------------------------------------------------------
module tb_hvmuxctl();

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
localparam SWITCH_N = 16;
localparam CLK_DIV = 8;

reg [SWITCH_N-1:0] din = '0;
reg              dvalid = '0;

wire spi_clk;
wire spi_din;
wire spi_le_n;

hvmuxctl #(
    .SWITCH_N  (SWITCH_N), // HVMUX number of switches
    .CLK_DIV (CLK_DIV) // Divider to obtain mux CLK from system clock
) dut (
    // System
    .clk (tb_clk),        // System clock
    .rst (tb_rst),        // System reset
    // HVMUX input data interface
    .din    (din),        // HVMUX data to set output voltage
    .dvalid (dvalid),     // HVMUX data is valid (pulse)
    // HVMUX output SPI interface
    .spi_le_n   (spi_le_n),   // HVMUX latch enable (active low)
    .spi_clk    (spi_clk),    // HVMUX clock
    .spi_din    (spi_din),    // HVMUX data output
    // Misc
    .busy (busy)        // HVMUX controller is busy (SPI exchange is in progress)
);

max14866 #(
    .SWITCH_N (SWITCH_N)
) hvmux (
    .le_n   (spi_le_n),
    .clk    (spi_clk),
    .din    (spi_din),
    .dout   (),
    .switch ()
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
    din <= 16'hFFFF;
    dvalid <= 1'b1;
    @(posedge tb_clk);
    dvalid <= 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);
    wait(!busy);
    repeat (10) @(posedge tb_clk);

    @(posedge tb_clk);
    din <= 16'h5555;
    dvalid <= 1'b1;
    @(posedge tb_clk);
    dvalid <= 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);
    wait(!busy);
    repeat (10) @(posedge tb_clk);

    @(posedge tb_clk);
    din <= 16'hAAAA;
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
    $dumpvars(0, tb_hvmuxctl);
end
`endif

endmodule