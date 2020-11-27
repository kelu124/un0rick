//-------------------------------------------------------------------
// Test for stat_px module
//-------------------------------------------------------------------
module tb_stat_px();

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
reg  flush = 0;
reg  px_ready = 0;
wire px_valid;
wire px_out;

stat_px dut (
    .clk      (tb_clk),
    .rst      (tb_rst),
    // Pixel control
    .flush    (flush),    // Flush pixel decoder and clear pixel address
    .px_ready (px_ready), // Display ready to get static pixel
    .px_valid (px_valid), // Output pixel is valid
    .px_out   (px_out)    // Output pixel value
);

//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------
localparam STAT_PX_SIZE = 168192;
reg golden_px [STAT_PX_SIZE-1:0];
reg revised_px [STAT_PX_SIZE-1:0];

initial begin
    $readmemh("../../util/vga_layout/mem/static_pixels_raw.mem", golden_px);
end

integer hs_cnt;
// Main test
initial begin : tb_main
    integer i;
    integer err_cnt;
    integer exit_loop;
    exit_loop = 0;
    err_cnt = 0;
    hs_cnt = 0;

    wait(!tb_rst);
    repeat (3) @(posedge tb_clk);

    wait(px_valid);
    @(posedge tb_clk);

    px_ready <= 1'b1;
    while (!exit_loop) begin
        @(posedge tb_clk);

        if (px_ready && px_valid) begin
            revised_px[hs_cnt] = px_out;
            hs_cnt = hs_cnt + 1;
        end

        if (px_valid && (hs_cnt == STAT_PX_SIZE)) begin
            px_ready <= 1'b0;
            exit_loop <= 1;
        end else if (($random() % 42) == 0)
            px_ready <= 1'b0;
        else if (($random() % 3) == 0)
            px_ready <= 1'b1;
    end
    exit_loop = 0;

    @(posedge tb_clk);
    flush <= 1'b1;
    @(posedge tb_clk);
    flush <= 1'b0;

    repeat (10) @(posedge tb_clk);

    for (i = 0; i < STAT_PX_SIZE; i = i + 1) begin
        if (golden_px[i] !== revised_px[i]) begin
            err_cnt = err_cnt + 1;
            $display("%0d: Expected %0d, but got %0d!", i, golden_px[i], revised_px[i]);
        end
    end

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
    $dumpvars(0, tb_stat_px);
end
`endif

endmodule