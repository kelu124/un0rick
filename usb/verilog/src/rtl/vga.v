//-------------------------------------------------------------------
// VGA interface driver.
// Default timings are for 800x600@56Hz with 36 MHz pixel clock.
//
//-------------------------------------------------------------------
module vga #(
    parameter  H_ACTIVE      = 800, // Active video horizontal size (pixels)
    parameter  V_ACTIVE      = 600, // Active video vertical size (pixels)
    parameter  H_FRONT_PORCH = 24,  // Horizontal front porch (pixels)
    parameter  H_SYNC_PULSE  = 72, // Horizontal sync pulse (pixels)
    parameter  H_BACK_PORCH  = 128,  // Horizontal back porch (pixels)
    parameter  V_FRONT_PORCH = 1,   // Vertical front porch (pixels)
    parameter  V_SYNC_PULSE  = 2,   // Vertical sync pulse (pixels)
    parameter  V_BACK_PORCH  = 22,  // Vertical back porch (pixels)
    parameter  COLOR_W       = 1,   // Color bitwidth
    parameter  PIXEL_LATENCY = 2,   // Latency before new pixel arrives
    parameter  PX_CNT_W      = $clog2(H_ACTIVE), // Bitwidth of horizontal (active pixel) counter
    parameter  LINE_CNT_W    = $clog2(V_ACTIVE)  // Bitwidth of vertical (active line) counter
)(
    // System
    input  wire                  clk,          // System clock (pixel clock)
    input  wire                  rst,          // System reset
    // VGA interface
    output wire                  vga_hsync,    // VGA horizontal sync
    output wire                  vga_vsync,    // VGA vertical sync
    output wire [COLOR_W-1:0]    vga_r,        // VGA red channel
    output wire [COLOR_W-1:0]    vga_g,        // VGA green channel
    output wire [COLOR_W-1:0]    vga_b,        // VGA blue channel
    // Display control
    input  wire                  en,           // Display enable
    input  wire [COLOR_W-1:0]    pixel_r,      // Display pixel red channel
    input  wire [COLOR_W-1:0]    pixel_g,      // Display pixel green channel
    input  wire [COLOR_W-1:0]    pixel_b,      // Display pixel blue channel
    output reg                   line_active,  // Line is active
    output reg                   frame_active, // Frame is active
    output reg [PX_CNT_W-1:0]    px_cnt,       // Horizontal (active pixel) counter
    output reg [LINE_CNT_W-1:0]  line_cnt      // Vertical (active line) counter
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam H_CNT_MAX = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
localparam V_CNT_MAX = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
localparam H_CNT_W   = $clog2(H_CNT_MAX);
localparam V_CNT_W   = $clog2(V_CNT_MAX);

localparam SYNC_PIPE_W = 1 + PIXEL_LATENCY; // 1 tick to register px_cnt output

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg hsync;
reg vsync;

reg  [H_CNT_W-1:0] hcnt;
reg  [V_CNT_W-1:0] vcnt;
wire               hcnt_ovf;
wire               vcnt_ovf;

reg [SYNC_PIPE_W-1:0] hsync_pipe;
reg [SYNC_PIPE_W-1:0] vsync_pipe;

//-----------------------------------------------------------------------------
// Pixel counters
//-----------------------------------------------------------------------------
assign hcnt_ovf = (hcnt == (H_CNT_MAX - 1));
assign vcnt_ovf = (vcnt == (V_CNT_MAX - 1));

always @(posedge clk or posedge rst) begin
    if (rst) begin
        hcnt <= 0;
        vcnt <= 0;
    end else if (en) begin
        if (hcnt_ovf) begin
            hcnt <= 0;
            vcnt <= vcnt_ovf ? 0 : vcnt + 1;
        end else begin
            hcnt <= hcnt + 1;
        end
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        px_cnt   <= '0;
        line_cnt <= '0;
    end else begin
        px_cnt   <= hcnt[PX_CNT_W-1:0];
        line_cnt <= vcnt[LINE_CNT_W-1:0];
    end
end

//-----------------------------------------------------------------------------
// Sync pulses
//-----------------------------------------------------------------------------
// generate pulses
always @(posedge clk or posedge rst) begin
    if (rst) begin
        hsync <= 1'b0;
        vsync <= 1'b0;
    end else if (en) begin
        hsync <= ( (hcnt > (H_ACTIVE + H_FRONT_PORCH)) &&
                   (hcnt <= (H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE)) );
        vsync <= ( (vcnt > (V_ACTIVE + V_FRONT_PORCH)) &&
                   (vcnt <= (V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE)) );
    end else begin
        hsync <= 1'b0;
        vsync <= 1'b0;
    end
end
// pipeline to synchronize with pixels arriving
always @(posedge clk or posedge rst) begin
    if (rst) begin
        hsync_pipe <= '0;
        vsync_pipe <= '0;
    end else begin
        hsync_pipe <= {hsync_pipe[SYNC_PIPE_W-2:0], hsync};
        vsync_pipe <= {vsync_pipe[SYNC_PIPE_W-2:0], vsync};
    end
end

// VGA outputs
assign vga_hsync = hsync_pipe[SYNC_PIPE_W-1];
assign vga_vsync = vsync_pipe[SYNC_PIPE_W-1];

//-----------------------------------------------------------------------------
// Display control
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
      line_active  <= 1'b0;
      frame_active <= 1'b0;
    end else if (en) begin
      line_active  <= (hcnt < H_ACTIVE) && (vcnt < V_ACTIVE);
      frame_active <= (vcnt < V_ACTIVE);
    end else begin
        line_active  <= 1'b0;
        frame_active <= 1'b0;
    end
end

// VGA outputs
assign vga_r = pixel_r;
assign vga_g = pixel_g;
assign vga_b = pixel_b;

endmodule
