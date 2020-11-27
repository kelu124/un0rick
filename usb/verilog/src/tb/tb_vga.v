//-------------------------------------------------------------------
// Test for vga module
//-------------------------------------------------------------------
module tb_vga();

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
localparam H_ACTIVE = 800;
localparam V_ACTIVE = 600;
localparam H_ACTIVE_W = $clog2(H_ACTIVE);
localparam V_ACTIVE_W = $clog2(V_ACTIVE);
localparam COLOR_W  = 8; 

wire               vga_hsync;
wire               vga_vsync;
wire [COLOR_W-1:0] vga_r;
wire [COLOR_W-1:0] vga_g;
wire [COLOR_W-1:0] vga_b;
reg  [COLOR_W-1:0] pixel_r = '1;
reg  [COLOR_W-1:0] pixel_g = '1;
reg  [COLOR_W-1:0] pixel_b = '0;
wire               line_active;
wire               frame_active;
wire [H_ACTIVE_W-1:0] h_active;
wire [V_ACTIVE_W-1:0] v_active;

vga #(
    .H_ACTIVE      (H_ACTIVE), // Active video horizontal size (pixels)
    .V_ACTIVE      (V_ACTIVE), // Active video vertical size (pixels)
    .H_FRONT_PORCH (40),  // Horizontal front porch (pixels)
    .H_SYNC_PULSE  (128), // Horizontal sync pulse (pixels)
    .H_BACK_PORCH  (88),  // Horizontal back porch (pixels)
    .V_FRONT_PORCH (1),   // Vertical front porch (pixels)
    .V_SYNC_PULSE  (4),   // Vertical sync pulse (pixels)
    .V_BACK_PORCH  (23),  // Vertical back porch (pixels)
    .COLOR_W       (COLOR_W),   // Color bitwidth
    .PIXEL_LATENCY (2)    // Latency before new pixel arrives
) dut (
    // System
    .clk          (tb_clk),       // System clock (pixel clock)
    .rst          (tb_rst),       // System reset
    // VGA interface
    .vga_hsync    (vga_hsync),    // VGA horizontal sync
    .vga_vsync    (vga_vsync),    // VGA vertical sync
    .vga_r        (vga_r),        // VGA red channel
    .vga_g        (vga_g),        // VGA green channel
    .vga_b        (vga_b),        // VGA blue channel
    // Display control
    .pixel_r      (pixel_r),      // Display pixel red channel
    .pixel_g      (pixel_g),      // Display pixel green channel
    .pixel_b      (pixel_b),      // Display pixel blue channel
    .line_active  (line_active),  // Line is active
    .frame_active (frame_active), // Frame is active
    .h_active     (h_active),     // Horizontal (active pixel) counter
    .v_active     (v_active)      // Vertical (active line) counter
);

vga_recv #(
    .WIDTH     (H_ACTIVE),
    .HEIGHT    (V_ACTIVE),
    .DUMP_PATH ("frame")
) vga_recv (
    .pixel_clk   (tb_clk),
    .pixel_r     (vga_r),
    .pixel_g     (vga_g),
    .pixel_b     (vga_b),
    .line_active (line_active),
    .frame_end   (~frame_active)
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

    @(negedge frame_active);

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
    $dumpvars(0, tb_vga);
end
`endif

endmodule