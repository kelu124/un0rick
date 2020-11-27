//-------------------------------------------------------------------
// Static pixel decoder for display.
//
// All pixels are stored in RLE-compressed format.
//
// Format:
//   - 15 bit - word type: raw bits (0) or length-encoded (1)
//   if 15 bit = 0 (raw bits): 14 ... 0 bits is original data bits
//   else if length-encoded (1):
//   - 14 bit - repeated bit
//   - 13 ... 0 bits - number of repeats (0 - 1 repeat, 1 - 2 repeats, etc)
//
//-------------------------------------------------------------------

module stat_px (
    input  wire clk,
    input  wire rst,
    // Pixel control
    input  wire flush,    // Flush pixel decoder and clear pixel address
    input  wire px_ready, // Display ready to get static pixel
    output reg  px_valid, // Output pixel is valid
    output reg  px_out    // Output pixel value
);

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
localparam RLE_TYPE_POS     = 15;
localparam RLE_REPEATED_POS = 14;
localparam RLE_REPEATS_W    = 14;
localparam RLE_RAW_BITS_MAX = 15;

localparam ROM_WORD_N = 11 * 256;
localparam ROM_ADDR_W = $clog2(ROM_WORD_N);
localparam ROM_DATA_W = 16;

localparam READ_WORD_S = 0;
localparam FLUSH_S     = 1;
localparam LEN_ENC_S   = 2;
localparam RAW_ENC_S   = 3;
localparam LAST_PX_S   = 4;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg [2:0] fsm_state, fsm_next;

wire [ROM_DATA_W-1:0] rom_rdata;
reg  [ROM_ADDR_W-1:0] rom_raddr, rom_raddr_next;

reg [ROM_DATA_W-1:0] rle_word, rle_word_next;
reg [$clog2(RLE_RAW_BITS_MAX)-1:0] rle_bits_cnt, rle_bits_cnt_next;

reg px_valid_next;
reg px_out_next;

//-----------------------------------------------------------------------------
// Static pixels ROM
//-----------------------------------------------------------------------------
rom #(
    .WORD_N    (ROM_WORD_N),
    .DATA_W    (ROM_DATA_W),
    .INIT_FILE ("../../src/rtl/static_pixels.mem")
) rom (
    // System
    .clk   (clk),   // System clock
    // Read interface
    .rdata (rom_rdata), // Read data
    .raddr (rom_raddr), // Read address
    .rd    (1'b1)    // Read operation
);

//-----------------------------------------------------------------------------
// Decoder FSM
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst)
        fsm_state <= READ_WORD_S;
    else
        fsm_state <= fsm_next;
end

always @(*) begin
    fsm_next = fsm_state;

    rom_raddr_next    = rom_raddr;
    rle_word_next     = rle_word;
    px_valid_next     = px_valid;
    px_out_next       = px_out;
    rle_bits_cnt_next = rle_bits_cnt;

    case (fsm_state)
        READ_WORD_S : begin
            // read word from rom
            rle_word_next = rom_rdata;
            rom_raddr_next = rom_raddr + 1;
            // decode word type
            if (rom_rdata[RLE_TYPE_POS])
                fsm_next = LEN_ENC_S;
            else begin
                rle_bits_cnt_next = RLE_RAW_BITS_MAX - 1;
                fsm_next          = RAW_ENC_S;
            end
        end

        FLUSH_S : begin
            if (!flush)
                fsm_next = READ_WORD_S;
        end

        LEN_ENC_S: begin
            if (flush) begin
                rom_raddr_next = 0;
                px_valid_next  = 1'b0;
                fsm_next       = FLUSH_S;
            end else if (!px_valid || (px_valid && px_ready)) begin
                if (rle_word[0+:RLE_REPEATS_W] > 0) begin
                    px_valid_next = 1'b1;
                    px_out_next   = rle_word[RLE_REPEATED_POS];
                    if (px_valid)
                        rle_word_next[0+:RLE_REPEATS_W] = rle_word[0+:RLE_REPEATS_W] - 1;
                end else begin
                    px_valid_next = 1'b0;
                    fsm_next      = READ_WORD_S;
                end
            end
        end

        RAW_ENC_S: begin
            if (flush) begin
                rom_raddr_next = 0;
                px_valid_next  = 1'b0;
                fsm_next       = FLUSH_S;
            end else if (!px_valid || (px_valid && px_ready)) begin
                if (rle_bits_cnt > 0) begin
                    px_valid_next = 1'b1;
                    px_out_next   = rle_word[0];
                    rle_word_next = rle_word >> 1;
                    if (px_valid)
                        rle_bits_cnt_next = rle_bits_cnt - 1;
                end else begin
                    px_valid_next = 1'b0;
                    fsm_next      = READ_WORD_S;
                end
            end
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        rom_raddr    <= '0;
        rle_word     <= '0;
        px_valid     <= 1'b0;
        px_out       <= 1'b0;
        rle_bits_cnt <= '0;
    end else begin
        rom_raddr    <= rom_raddr_next;
        rle_word     <= rle_word_next;
        px_valid     <= px_valid_next;
        px_out       <= px_out_next;
        rle_bits_cnt <= rle_bits_cnt_next;
    end
end

endmodule
