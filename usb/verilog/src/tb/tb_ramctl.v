//-------------------------------------------------------------------
// Test for ramctl module
//-------------------------------------------------------------------
module tb_ramctl();

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
localparam RAM_ADDR_W = 19;
localparam RAM_DATA_W = 16;

wire [RAM_ADDR_W-1:0] ram_addr;
wire [RAM_DATA_W-1:0] ram_data;
wire [RAM_DATA_W-1:0] ram_data_i;
wire [RAM_DATA_W-1:0] ram_data_o;
wire                  ram_data_oe;
wire                  ram_we_n;

reg  [RAM_ADDR_W-1:0] ramctl_addr = '0;
reg  [RAM_DATA_W-1:0] ramctl_wdata = '0;
reg                   ramctl_wen = 1'b0;
wire [RAM_DATA_W-1:0] ramctl_rdata;
wire                  ramctl_rvalid;
reg                   ramctl_ren = 1'b0;

ramctl #(
    .DATA_W (RAM_DATA_W),
    .ADDR_W (RAM_ADDR_W)
) dut (
    // System
    .clk         (tb_clk),
    .rst         (tb_rst),
    // External async ram interface
    .ram_addr    (ram_addr),
    .ram_data_i  (ram_data_i),
    .ram_data_o  (ram_data_o),
    .ram_data_oe (ram_data_oe),
    .ram_we_n    (ram_we_n),
    // Internal fpga interface
    .addr        (ramctl_addr),
    .wdata       (ramctl_wdata),
    .wen         (ramctl_wen),
    .rdata       (ramctl_rdata),
    .rvalid      (ramctl_rvalid),
    .ren         (ramctl_ren)
);

assign ram_data   = ram_data_oe ? ram_data_o : 'z;
assign ram_data_i = ram_data;

is61wv51216 ram (
    .Address (ram_addr),
    .dataIO  (ram_data),
    .OE_bar  (1'b0),
    .CE_bar  (1'b0),
    .WE_bar  (ram_we_n),
    .LB_bar  (1'b0),
    .UB_bar  (1'b0)
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

    // write
    @(posedge tb_clk);
    ramctl_wen   <= 1'b1;
    ramctl_addr  <= 4;
    ramctl_wdata <= 16'hDEAD;
    @(posedge tb_clk);
    ramctl_addr  <= 5;
    ramctl_wdata <= 16'hBEEF;
    @(posedge tb_clk);
    ramctl_addr   <= 6;
    ramctl_wdata <= 16'hBABE;
    @(posedge tb_clk);
    ramctl_wen   <= 1'b0;

    // read
    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    ramctl_ren  <= 1'b1;
    ramctl_addr <= 4;
    wait(ramctl_rvalid);
    @(posedge tb_clk);
    ramctl_ren  <= 1'b0;

    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    ramctl_ren  <= 1'b1;
    ramctl_addr <= 5;
    wait(ramctl_rvalid);
    @(posedge tb_clk);
    ramctl_ren  <= 1'b0;

    @(posedge tb_clk);
    @(posedge tb_clk);
    @(posedge tb_clk);
    ramctl_ren  <= 1'b1;
    ramctl_addr <= 6;
    wait(ramctl_rvalid);
    @(posedge tb_clk);
    ramctl_ren  <= 1'b0;

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
    $dumpvars(0, tb_ramctl);
end
`endif

endmodule