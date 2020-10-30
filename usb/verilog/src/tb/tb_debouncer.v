//-------------------------------------------------------------------
// Test for debouncer module
//-------------------------------------------------------------------
module tb_debouncer();

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
localparam DELAY = 2000000; // 30ms

reg  din = 1'b0;
wire dout;  

debouncer #(
    .DELAY (DELAY) // delay in clk ticks
) dut (
    .clk    (tb_clk), 		
    .rst    (tb_rst), 
    .din    (din),
    .dout   (dout)  
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

    #1000 din = ~din;
    #15000 din = ~din;
    #3000 din = ~din;
    #50000000 din = ~din;
    #50000000 din = ~din;
    #5000000;

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
    $dumpvars(0, tb_debouncer);
end
`endif

endmodule