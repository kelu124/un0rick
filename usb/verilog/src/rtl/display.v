//-------------------------------------------------------------------
// Display block to generate all graphics to be shown
//
//-------------------------------------------------------------------
module display #(
    parameter H_ACTIVE        = 800,              // Active video horizontal size (pixels)
    parameter V_ACTIVE        = 600,              // Active video vertical size (pixels)
    parameter COLOR_W         = 1,                // Color bitwidth
    parameter PX_CNT_W        = $clog2(H_ACTIVE), // Bitwidth of horizontal (active pixel) counter
    parameter LINE_CNT_W      = $clog2(V_ACTIVE), // Bitwidth of vertical (active line) counter
    parameter ACQ_BUFF_DATA_W = 24,               // Acquisition buffer data width
    parameter ACQ_BUFF_ADDR_W = 9,                // Acquisition buffer address width
    parameter PULSER_LEN_W    = 8                 // Pulser timing parameters width
)(
    input  wire                       clk,
    input  wire                       rst,
    // Display control
    output reg                        vga_en,          // VGA enable
    output reg  [COLOR_W-1:0]         pixel_r,         // Display pixel red channel
    output reg  [COLOR_W-1:0]         pixel_g,         // Display pixel green channel
    output reg  [COLOR_W-1:0]         pixel_b,         // Display pixel blue channel
    input  wire                       line_active,     // Line is active
    input  wire                       frame_active,    // Frame is active
    input  wire [PX_CNT_W-1:0]        px_cnt,          // Horizontal (active pixel) counter
    input  wire [LINE_CNT_W-1:0]      line_cnt,        // Vertical (active line) counter
    input  wire                       run_mode,        // Display run mode active
    // Acquisition interface
    output reg                        acq_start,       // Start aquisition
    input  wire                       acq_done,        // Aquisition is done
    input  wire                       acq_buff_rvalid, // Aquisition buffer data is valid
    input  wire [ACQ_BUFF_DATA_W-1:0] acq_buff_rdata,  // Acquisition buffer read data
    output reg  [ACQ_BUFF_ADDR_W-1:0] acq_buff_raddr,  // Acuisition buffer read address
    output reg                        acq_buff_rd,     // Acuisition buffer read enable
    // Pulser parameters
    input  wire [PULSER_LEN_W-1:0]    pulser_init_len,  // Pulser initial delay
    input  wire [PULSER_LEN_W-1:0]    pulser_on_len,    // Pulser on width
    input  wire [PULSER_LEN_W-1:0]    pulser_off_len,   // Pulser off width
    input  wire [PULSER_LEN_W-1:0]    pulser_inter_len  // Pulser intermediate delay
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam COLORS   = 4; // total number of supported colors
localparam COLORS_W = $clog2(4);

localparam LINE_BUFF_ADDR_W = $clog2(H_ACTIVE * 2);
localparam LINE_BUFF_DATA_W = COLORS_W;

localparam STAT_AREA_WORD_N = 11 * 256;
localparam STAT_AREA_ADDR_W = $clog2(STAT_AREA_WORD_N);
localparam STAT_AREA_WORD_W = 16;

localparam CH_W     = 4;
localparam CH_ROW_W = 3;

localparam DYN_AREAS_N = 9;

localparam DYN_AREA_ACQ_ORIGIN_PX   = 10;
localparam DYN_AREA_ACQ_ORIGIN_LINE = 15;
localparam DYN_AREA_ACQ_WIDTH       = 512;
localparam DYN_AREA_ACQ_HEIGHT      = 256;
localparam DYN_AREA_ACQ_START_PX    = DYN_AREA_ACQ_ORIGIN_PX;
localparam DYN_AREA_ACQ_END_PX      = DYN_AREA_ACQ_ORIGIN_PX + DYN_AREA_ACQ_WIDTH - 1;
localparam DYN_AREA_ACQ_START_LINE  = DYN_AREA_ACQ_ORIGIN_LINE - 1;
localparam DYN_AREA_ACQ_END_LINE    = DYN_AREA_ACQ_ORIGIN_LINE + DYN_AREA_ACQ_HEIGHT - 2;

localparam DYN_AREA_DACGAIN_ORIGIN_PX   = 10;
localparam DYN_AREA_DACGAIN_ORIGIN_LINE = 310;
localparam DYN_AREA_DACGAIN_WIDTH       = 512;
localparam DYN_AREA_DACGAIN_HEIGHT      = 256;
localparam DYN_AREA_DACGAIN_START_PX    = DYN_AREA_DACGAIN_ORIGIN_PX;
localparam DYN_AREA_DACGAIN_END_PX      = DYN_AREA_DACGAIN_ORIGIN_PX + DYN_AREA_DACGAIN_WIDTH - 1;
localparam DYN_AREA_DACGAIN_START_LINE  = DYN_AREA_DACGAIN_ORIGIN_LINE - 1;
localparam DYN_AREA_DACGAIN_END_LINE    = DYN_AREA_DACGAIN_ORIGIN_LINE + DYN_AREA_DACGAIN_HEIGHT - 2;

localparam DYN_AREA_TOPTURN1_ORIGIN_PX   = 534;
localparam DYN_AREA_TOPTURN1_ORIGIN_LINE = 77;
localparam DYN_AREA_TOPTURN1_WIDTH       = 256;
localparam DYN_AREA_TOPTURN1_HEIGHT      = 64;
localparam DYN_AREA_TOPTURN1_START_PX    = DYN_AREA_TOPTURN1_ORIGIN_PX;
localparam DYN_AREA_TOPTURN1_END_PX      = DYN_AREA_TOPTURN1_ORIGIN_PX + DYN_AREA_TOPTURN1_WIDTH - 1;
localparam DYN_AREA_TOPTURN1_START_LINE  = DYN_AREA_TOPTURN1_ORIGIN_LINE - 1;
localparam DYN_AREA_TOPTURN1_END_LINE    = DYN_AREA_TOPTURN1_ORIGIN_LINE + DYN_AREA_TOPTURN1_HEIGHT - 2;

localparam DYN_AREA_TOPTURN2_ORIGIN_PX   = 534;
localparam DYN_AREA_TOPTURN2_ORIGIN_LINE = 237;
localparam DYN_AREA_TOPTURN2_WIDTH       = 256;
localparam DYN_AREA_TOPTURN2_HEIGHT      = 64;
localparam DYN_AREA_TOPTURN2_START_PX    = DYN_AREA_TOPTURN2_ORIGIN_PX;
localparam DYN_AREA_TOPTURN2_END_PX      = DYN_AREA_TOPTURN2_ORIGIN_PX + DYN_AREA_TOPTURN2_WIDTH - 1;
localparam DYN_AREA_TOPTURN2_START_LINE  = DYN_AREA_TOPTURN2_ORIGIN_LINE - 1;
localparam DYN_AREA_TOPTURN2_END_LINE    = DYN_AREA_TOPTURN2_ORIGIN_LINE + DYN_AREA_TOPTURN2_HEIGHT - 2;

localparam DYN_AREA_TOPTURN3_ORIGIN_PX   = 534;
localparam DYN_AREA_TOPTURN3_ORIGIN_LINE = 397;
localparam DYN_AREA_TOPTURN3_WIDTH       = 256;
localparam DYN_AREA_TOPTURN3_HEIGHT      = 64;
localparam DYN_AREA_TOPTURN3_START_PX    = DYN_AREA_TOPTURN3_ORIGIN_PX;
localparam DYN_AREA_TOPTURN3_END_PX      = DYN_AREA_TOPTURN3_ORIGIN_PX + DYN_AREA_TOPTURN3_WIDTH - 1;
localparam DYN_AREA_TOPTURN3_START_LINE  = DYN_AREA_TOPTURN3_ORIGIN_LINE - 1;
localparam DYN_AREA_TOPTURN3_END_LINE    = DYN_AREA_TOPTURN3_ORIGIN_LINE + DYN_AREA_TOPTURN3_HEIGHT - 2;

localparam DYN_AREA_INITDEL_ORIGIN_PX   = 631;
localparam DYN_AREA_INITDEL_ORIGIN_LINE = 508;
localparam DYN_AREA_INITDEL_WIDTH       = 16;
localparam DYN_AREA_INITDEL_HEIGHT      = 8;
localparam DYN_AREA_INITDEL_START_PX    = DYN_AREA_INITDEL_ORIGIN_PX;
localparam DYN_AREA_INITDEL_END_PX      = DYN_AREA_INITDEL_ORIGIN_PX + DYN_AREA_INITDEL_WIDTH - 1;
localparam DYN_AREA_INITDEL_START_LINE  = DYN_AREA_INITDEL_ORIGIN_LINE - 1;
localparam DYN_AREA_INITDEL_END_LINE    = DYN_AREA_INITDEL_ORIGIN_LINE + DYN_AREA_INITDEL_HEIGHT - 2;

localparam DYN_AREA_PONW_ORIGIN_PX   = 631;
localparam DYN_AREA_PONW_ORIGIN_LINE = 526;
localparam DYN_AREA_PONW_WIDTH       = 16;
localparam DYN_AREA_PONW_HEIGHT      = 8;
localparam DYN_AREA_PONW_START_PX    = DYN_AREA_PONW_ORIGIN_PX;
localparam DYN_AREA_PONW_END_PX      = DYN_AREA_PONW_ORIGIN_PX + DYN_AREA_PONW_WIDTH - 1;
localparam DYN_AREA_PONW_START_LINE  = DYN_AREA_PONW_ORIGIN_LINE - 1;
localparam DYN_AREA_PONW_END_LINE    = DYN_AREA_PONW_ORIGIN_LINE + DYN_AREA_PONW_HEIGHT - 2;

localparam DYN_AREA_INTERW_ORIGIN_PX   = 631;
localparam DYN_AREA_INTERW_ORIGIN_LINE = 544;
localparam DYN_AREA_INTERW_WIDTH       = 16;
localparam DYN_AREA_INTERW_HEIGHT      = 8;
localparam DYN_AREA_INTERW_START_PX    = DYN_AREA_INTERW_ORIGIN_PX;
localparam DYN_AREA_INTERW_END_PX      = DYN_AREA_INTERW_ORIGIN_PX + DYN_AREA_INTERW_WIDTH - 1;
localparam DYN_AREA_INTERW_START_LINE  = DYN_AREA_INTERW_ORIGIN_LINE - 1;
localparam DYN_AREA_INTERW_END_LINE    = DYN_AREA_INTERW_ORIGIN_LINE + DYN_AREA_INTERW_HEIGHT - 2;

localparam DYN_AREA_POFFW_ORIGIN_PX   = 631;
localparam DYN_AREA_POFFW_ORIGIN_LINE = 562;
localparam DYN_AREA_POFFW_WIDTH       = 16;
localparam DYN_AREA_POFFW_HEIGHT      = 8;
localparam DYN_AREA_POFFW_START_PX    = DYN_AREA_POFFW_ORIGIN_PX;
localparam DYN_AREA_POFFW_END_PX      = DYN_AREA_POFFW_ORIGIN_PX + DYN_AREA_POFFW_WIDTH - 1;
localparam DYN_AREA_POFFW_START_LINE  = DYN_AREA_POFFW_ORIGIN_LINE - 1;
localparam DYN_AREA_POFFW_END_LINE    = DYN_AREA_POFFW_ORIGIN_LINE + DYN_AREA_POFFW_HEIGHT - 2;

// Line buffer write FSM states
localparam FRAME_END_S         = 0;
localparam WAIT_ACQ_S          = 1;
localparam SWAP_LINE_BUFF_S    = 2;
localparam WAIT_LINE_ACTIVE_S  = 3;
localparam DYN_FILL_S          = 4;
localparam STAT_FILL_S         = 5;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg [2:0] fsm_state, fsm_next;

reg frame_active_ff;
wire frame_start;
wire frame_end;

reg  line_active_ff0, line_active_ff1;
wire line_valid;

reg vga_en_next;

reg  stat_px_flush, stat_px_flush_next;
reg  stat_px_ready, stat_px_ready_next;
wire stat_px_valid;
wire stat_px_out;

reg  [CH_W-1:0]     ch_sel;
wire [CH_W-1:0]     ch_sel_next;
reg  [CH_ROW_W-1:0] ch_row_sel;
wire [CH_ROW_W-1:0] ch_row_sel_next;
wire                ch_px_rd;
wire                ch_px_valid;
wire                ch_px_out;

reg  line_buff_sel, line_buff_sel_next;

reg  [LINE_BUFF_DATA_W-1:0] line_buff_wdata, line_buff_wdata_next;
reg  [LINE_BUFF_ADDR_W-1:0] line_buff_waddr, line_buff_waddr_next;
reg                         line_buff_wr, line_buff_wr_next;
wire [LINE_BUFF_DATA_W-1:0] line_buff_rdata;
wire [LINE_BUFF_ADDR_W-1:0] line_buff_raddr;
wire                        line_buff_rd;

reg [PX_CNT_W-1:0] px_fill_cnt, px_fill_cnt_next;

wire [COLOR_W-1:0] pixel_r_next;
wire [COLOR_W-1:0] pixel_g_next;
wire [COLOR_W-1:0] pixel_b_next;

reg acq_start_next;
reg  acq_done_ff;
wire acq_done_pulse;
reg dyn_px_cnt_en, dyn_px_cnt_en_next;
reg [ACQ_BUFF_ADDR_W-1:0] dyn_px_cnt, dyn_px_cnt_next;

wire [DYN_AREAS_N-1:0] dyn_area_vector;
wire dyn_area_acq_active;
wire dyn_area_dacgain_active;
wire dyn_area_topturn1_active;
wire dyn_area_topturn2_active;
wire dyn_area_topturn3_active;
wire dyn_area_initdel_active;
wire dyn_area_ponw_active;
wire dyn_area_interw_active;
wire dyn_area_poffw_active;
wire dyn_area_active;
wire stat_area_active;
wire dyn_area_ch_active;

//-----------------------------------------------------------------------------
// Areas decoder
//-----------------------------------------------------------------------------
assign dyn_area_acq_active = (px_fill_cnt >= DYN_AREA_ACQ_START_PX)   && (px_fill_cnt <= DYN_AREA_ACQ_END_PX) &&
                             (line_cnt    >= DYN_AREA_ACQ_START_LINE) && (line_cnt    <= DYN_AREA_ACQ_END_LINE);

assign dyn_area_dacgain_active = (px_fill_cnt >= DYN_AREA_DACGAIN_START_PX)   && (px_fill_cnt <= DYN_AREA_DACGAIN_END_PX) &&
                                 (line_cnt    >= DYN_AREA_DACGAIN_START_LINE) && (line_cnt    <= DYN_AREA_DACGAIN_END_LINE);

assign dyn_area_topturn1_active = (px_fill_cnt >= DYN_AREA_TOPTURN1_START_PX)   && (px_fill_cnt <= DYN_AREA_TOPTURN1_END_PX) &&
                                  (line_cnt    >= DYN_AREA_TOPTURN1_START_LINE) && (line_cnt    <= DYN_AREA_TOPTURN1_END_LINE);

assign dyn_area_topturn2_active = (px_fill_cnt >= DYN_AREA_TOPTURN2_START_PX)   && (px_fill_cnt <= DYN_AREA_TOPTURN2_END_PX) &&
                                  (line_cnt    >= DYN_AREA_TOPTURN2_START_LINE) && (line_cnt    <= DYN_AREA_TOPTURN2_END_LINE);

assign dyn_area_topturn3_active = (px_fill_cnt >= DYN_AREA_TOPTURN3_START_PX)   && (px_fill_cnt <= DYN_AREA_TOPTURN3_END_PX) &&
                                  (line_cnt    >= DYN_AREA_TOPTURN3_START_LINE) && (line_cnt    <= DYN_AREA_TOPTURN3_END_LINE);

assign dyn_area_initdel_active = (px_fill_cnt >= DYN_AREA_INITDEL_START_PX)   && (px_fill_cnt <= DYN_AREA_INITDEL_END_PX) &&
                                 (line_cnt    >= DYN_AREA_INITDEL_START_LINE) && (line_cnt    <= DYN_AREA_INITDEL_END_LINE);

assign dyn_area_ponw_active = (px_fill_cnt >= DYN_AREA_PONW_START_PX)   && (px_fill_cnt <= DYN_AREA_PONW_END_PX) &&
                              (line_cnt    >= DYN_AREA_PONW_START_LINE) && (line_cnt    <= DYN_AREA_PONW_END_LINE);

assign dyn_area_interw_active = (px_fill_cnt >= DYN_AREA_INTERW_START_PX)   && (px_fill_cnt <= DYN_AREA_INTERW_END_PX) &&
                                (line_cnt    >= DYN_AREA_INTERW_START_LINE) && (line_cnt    <= DYN_AREA_INTERW_END_LINE);

assign dyn_area_poffw_active = (px_fill_cnt >= DYN_AREA_POFFW_START_PX)   && (px_fill_cnt <= DYN_AREA_POFFW_END_PX) &&
                               (line_cnt    >= DYN_AREA_POFFW_START_LINE) && (line_cnt    <= DYN_AREA_POFFW_END_LINE);

assign dyn_area_vector = { dyn_area_acq_active,
                           dyn_area_dacgain_active,
                           dyn_area_topturn1_active,
                           dyn_area_topturn2_active,
                           dyn_area_topturn3_active,
                           dyn_area_initdel_active,
                           dyn_area_ponw_active,
                           dyn_area_interw_active,
                           dyn_area_poffw_active };

assign dyn_area_active  = |dyn_area_vector;
assign stat_area_active = ~dyn_area_active;

//-----------------------------------------------------------------------------
// Static pixels decoder (ROM + RLE decoder)
//-----------------------------------------------------------------------------
stat_px stat_px_decoder (
    .clk      (clk),
    .rst      (rst),
    // Pixel control
    .flush    (stat_px_flush), // Flush pixel decoder and clear pixel address
    // FIXME: need to find better solution. This one can lead to some critical paths.
    // The motivation is to clear ready as soon as dynamic area starts.
    .px_ready (stat_px_ready & stat_area_active), // Display ready to get static pixel
    .px_valid (stat_px_valid), // Output pixel is valid
    .px_out   (stat_px_out)    // Output pixel value
);

//-----------------------------------------------------------------------------
// Hexademical characters pixels (ROM)
//-----------------------------------------------------------------------------
hex_ch #(
    .CH_W     (CH_W),
    .CH_ROW_W (CH_ROW_W)
) hex_ch_decoder (
    .clk         (clk),
    .rst         (rst),
    // Pixel control
    .ch_sel      (ch_sel),      // Select character 0 ... F
    .row_sel     (ch_row_sel),  // Select character pixel row
    .ch_px_rd    (ch_px_rd),    // Read character pixel
    .ch_px_valid (ch_px_valid), // Output pixel is valid
    .ch_px_out   (ch_px_out)    // Output pixel value
);

// charecters are printed from the left to the right, so high part of the word should be displayed first
assign ch_sel_next = dyn_area_initdel_active ? ((dyn_px_cnt[5:0] >= 5'h6) ? pulser_init_len[3:0]  : pulser_init_len[7:4])  :
                     dyn_area_ponw_active    ? ((dyn_px_cnt[5:0] >= 5'h6) ? pulser_on_len[3:0]    : pulser_on_len[7:4])    :
                     dyn_area_interw_active  ? ((dyn_px_cnt[5:0] >= 5'h6) ? pulser_inter_len[3:0] : pulser_inter_len[7:4]) :
                     dyn_area_poffw_active   ? ((dyn_px_cnt[5:0] >= 5'h6) ? pulser_off_len[3:0]   : pulser_off_len[7:4])   : ch_sel;

assign ch_row_sel_next = dyn_area_initdel_active ? (line_cnt - DYN_AREA_INITDEL_START_LINE) :
                         dyn_area_ponw_active    ? (line_cnt - DYN_AREA_PONW_START_LINE)    :
                         dyn_area_interw_active  ? (line_cnt - DYN_AREA_INTERW_START_LINE)  :
                         dyn_area_poffw_active   ? (line_cnt - DYN_AREA_POFFW_START_LINE)   : ch_row_sel;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ch_sel     <= '0;
        ch_row_sel <= '0;
    end else begin
        ch_sel     <= ch_sel_next;
        ch_row_sel <= ch_row_sel_next;
    end
end

assign dyn_area_ch_active = (dyn_area_initdel_active | dyn_area_ponw_active | dyn_area_interw_active | dyn_area_poffw_active);

assign ch_px_rd = dyn_px_cnt_en & dyn_area_ch_active;

//-----------------------------------------------------------------------------
// Line double buffer
//-----------------------------------------------------------------------------
dpram #(
    .ADDR_W (LINE_BUFF_ADDR_W), // Memory depth
    .DATA_W (LINE_BUFF_DATA_W)  // Data width
) line_buff (
    // Write interface
    .wclk   (clk),             // Write clock
    .wdata  (line_buff_wdata), // Write data
    .waddr  (line_buff_waddr), // Write address
    .wr     (line_buff_wr),    // Write operation enable
    // Read interface
    .rclk   (clk),             // Read clock
    .rdata  (line_buff_rdata), // Read data
    .raddr  (line_buff_raddr), // Read address
    .rd     (line_buff_rd)     // Read operation enable
);

//-----------------------------------------------------------------------------
// Line buffer read side
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        line_active_ff0 <= 1'b0;
        line_active_ff1 <= 1'b0;
    end else begin
        line_active_ff0 <= line_active;
        line_active_ff1 <= line_active_ff0;
    end
end

assign line_valid = line_active_ff1;

assign pixel_b_next = '0;
assign {pixel_g_next, pixel_r_next} = line_valid ? line_buff_rdata : '0;
assign line_buff_raddr = {~line_buff_sel, px_cnt};
assign line_buff_rd    = line_active;

//-----------------------------------------------------------------------------
// Line buffer write side and control
//-----------------------------------------------------------------------------
// frame start and end control
always @(posedge clk or posedge rst) begin
    if (rst)
        frame_active_ff <= 1'b0;
    else
        frame_active_ff <= frame_active;
end

assign frame_start =   frame_active  & (~frame_active_ff);
assign frame_end   = (~frame_active) &   frame_active_ff;

// acquisition done control
always @(posedge clk or posedge rst) begin
    if (rst)
        acq_done_ff <= 1'b0;
    else
        acq_done_ff <= acq_done;
end

assign acq_done_pulse = acq_done & (~acq_done_ff);

always @(posedge clk or posedge rst) begin
    if (rst)
        fsm_state <= FRAME_END_S;
    else
        fsm_state <= fsm_next;
end

always @(*) begin
    fsm_next = fsm_state;

    line_buff_wdata_next  = line_buff_wdata;
    line_buff_waddr_next  = line_buff_waddr;
    line_buff_wr_next     = 1'b0;
    stat_px_flush_next    = 1'b0;
    stat_px_ready_next    = stat_px_ready;
    line_buff_sel_next    = line_buff_sel;
    vga_en_next           = vga_en;
    px_fill_cnt_next      = px_fill_cnt;
    acq_start_next        = acq_start;
    dyn_px_cnt_next       = dyn_px_cnt;
    dyn_px_cnt_en_next    = dyn_px_cnt_en;
 
    case (fsm_state)
        FRAME_END_S : begin
            if (stat_px_valid) begin
                acq_start_next = 1'b1;
                fsm_next = WAIT_ACQ_S;
            end
        end

        WAIT_ACQ_S : begin
            acq_start_next = 1'b0;
            if (acq_done_pulse || (!run_mode)) begin
                fsm_next = STAT_FILL_S; // first pixel in a row is always static
            end
        end

        SWAP_LINE_BUFF_S : begin
            px_fill_cnt_next     = 0;
            line_buff_sel_next   = ~line_buff_sel;
            fsm_next             = WAIT_LINE_ACTIVE_S;
        end

        WAIT_LINE_ACTIVE_S : begin
            vga_en_next = 1'b1;
            if (line_active)
                fsm_next = STAT_FILL_S; // first pixel in a row is always static
            else if (frame_end) begin
                stat_px_flush_next = 1'b1;
                fsm_next           = FRAME_END_S;
            end

        end

        STAT_FILL_S : begin
            if (dyn_area_active) begin
                stat_px_ready_next = 1'b0;
                fsm_next           = DYN_FILL_S;
            end else begin
                if (stat_px_valid && stat_px_ready) begin
                    line_buff_wr_next    = 1'b1;
                    line_buff_wdata_next = {2{stat_px_out}};
                    line_buff_waddr_next = {line_buff_sel, px_fill_cnt};
                    px_fill_cnt_next     = px_fill_cnt + 1;

                    if (px_fill_cnt >= (H_ACTIVE - 1)) begin // last pixel in a row is always static
                        stat_px_ready_next = 1'b0;
                        fsm_next           = SWAP_LINE_BUFF_S;
                    end
                end else begin
                    stat_px_ready_next = 1'b1;
                end
            end
        end

        DYN_FILL_S : begin
            if (stat_area_active) begin
                fsm_next           = STAT_FILL_S;
                dyn_px_cnt_next    = 0;
                dyn_px_cnt_en_next = 1'b0;
            end else begin
                dyn_px_cnt_en_next = 1'b1;
                if (dyn_px_cnt_en) begin
                    dyn_px_cnt_next = (dyn_area_topturn1_active |
                                       dyn_area_topturn2_active |
                                       dyn_area_topturn3_active) ? dyn_px_cnt + 2 : dyn_px_cnt + 1;
                end
                if (acq_buff_rvalid | ch_px_valid) begin
                    line_buff_wr_next    = 1'b1;
                    line_buff_waddr_next = {line_buff_sel, px_fill_cnt};
                    px_fill_cnt_next     = px_fill_cnt + 1;
                    // FIXME: possible synthisis issues below
                    if (dyn_area_acq_active)
                        line_buff_wdata_next = ((DYN_AREA_ACQ_END_LINE - line_cnt) <= acq_buff_rdata[7:0]) ? 2'b11 : 2'b00;
                    else if (dyn_area_dacgain_active)
                        line_buff_wdata_next = ((DYN_AREA_DACGAIN_END_LINE - line_cnt) <= acq_buff_rdata[15:8]) ? 2'b11 : 2'b00;
                    else if (dyn_area_topturn1_active)
                        line_buff_wdata_next = (acq_buff_rdata[16] || (line_cnt == DYN_AREA_TOPTURN1_END_LINE)) ? 2'b11 : 2'b00;
                    else if (dyn_area_topturn2_active)
                        line_buff_wdata_next = (acq_buff_rdata[17] || (line_cnt == DYN_AREA_TOPTURN2_END_LINE)) ? 2'b11 : 2'b00;
                    else if (dyn_area_topturn3_active)
                        line_buff_wdata_next = (acq_buff_rdata[18] || (line_cnt == DYN_AREA_TOPTURN3_END_LINE)) ? 2'b11 : 2'b00;
                    else if (dyn_area_ch_active)
                        line_buff_wdata_next = ch_px_out ? 2'b11 : 2'b00;
                    else
                        line_buff_wdata_next = 2'b01;
                end
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        line_buff_wdata  <= '0;
        line_buff_waddr  <= '0;
        line_buff_wr     <= '0;
        stat_px_flush    <= '0;
        stat_px_ready    <= '0;
        line_buff_sel    <= '0;
        vga_en           <= '0;
        px_fill_cnt      <= '0;
        acq_start        <= '0;
        dyn_px_cnt       <= '0;
        dyn_px_cnt_en    <= '0;
    end else begin
        line_buff_wdata  <= line_buff_wdata_next;
        line_buff_waddr  <= line_buff_waddr_next;
        line_buff_wr     <= line_buff_wr_next;
        stat_px_flush    <= stat_px_flush_next;
        stat_px_ready    <= stat_px_ready_next;
        line_buff_sel    <= line_buff_sel_next;
        vga_en           <= vga_en_next;
        px_fill_cnt      <= px_fill_cnt_next;
        acq_start        <= acq_start_next;
        dyn_px_cnt       <= dyn_px_cnt_next;
        dyn_px_cnt_en    <= dyn_px_cnt_en_next;
    end
end

//-----------------------------------------------------------------------------
// Outputs
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        acq_buff_raddr <= '0;
        acq_buff_rd    <= 1'b0;
    end else begin
        acq_buff_raddr <= dyn_px_cnt_next;
        acq_buff_rd    <= dyn_px_cnt_en_next;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pixel_r <= '0;
        pixel_g <= '0;
        pixel_b <= '0;
    end else begin
        pixel_r <= pixel_r_next;
        pixel_g <= pixel_g_next;
        pixel_b <= pixel_b_next;
    end
end

endmodule
