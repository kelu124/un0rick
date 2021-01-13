//-------------------------------------------------------------------
// Module to perform acquisitions
//
//-------------------------------------------------------------------

module acq #(
    parameter ADC_DATA_W         = 10,                    // ADC data width
    parameter DAC_DATA_W         = 10,                    // DAC data width
    parameter DAC_SCK_DIV        = 8,                     // Divider to obtain DAC SCK from system clock
    parameter DAC_GAIN_N         = 32,                    // Number of DAC gain values
    parameter DAC_GAIN_PTR_W     = $clog2(DAC_GAIN_N),    // Bit width of pointer to select DAC gain value
    parameter PULSER_LEN_W       = 8,                     // Bit width of pulser interval length
    parameter ACQ_LINES_MAX      = 32,                    // Maximum number of lines per acquisition 
    parameter ACQ_LINES_W        = $clog2(ACQ_LINES_MAX), // Bit width of lines counter
    parameter ACQ_WORDS_PER_LINE = 16384,                 // Number of words per line
    parameter RAM_DATA_W         = 16,                    // External RAM data bus width
    parameter RAM_ADDR_W         = 19,                    // External RAM address bus width
    parameter INICE_N            = 3                      // Number of INICE pins, connected to FPGA
)(
    // System
    input  wire                      clk,              // System clock
    input  wire                      rst,              // System reset
    // Pulser
    input  wire                      pulser_clk,       // Clock for pulse generation (2x faster than system clock)
    input  wire                      pulser_rst,       // Reset for pulser logic
    output reg                       pulser_on,        // Pulser on pin
    output reg                       pulser_off,       // Pulser off pin
    input  wire [PULSER_LEN_W-1:0]   pulser_on_len,    // Length of the on pulse (in pulser_clk ticks)
    input  wire [PULSER_LEN_W-1:0]   pulser_off_len,   // Length of the off pulse (in pulser_clk ticks)
    input  wire [PULSER_LEN_W-1:0]   pulser_init_len,  // Length of the initial delay before on pulse (in pulser_clk ticks)
    input  wire [PULSER_LEN_W-1:0]   pulser_inter_len, // Length of the delay between on and off pulses (in pulser_clk ticks)
    input  wire                      pulser_drmode,    // Pulser double rate mode enable
    // DAC
    output reg  [DAC_DATA_W-1:0]     dac_din,          // DAC data to control output voltage
    output reg                       dac_dvalid,       // DAC data is valid
    output reg  [DAC_GAIN_PTR_W-1:0] dac_gain_ptr,     // DAC gain pointer to select gain value
    input  wire [DAC_DATA_W-1:0]     dac_gain,         // DAC gain value
    input  wire [DAC_DATA_W-1:0]     dac_idle,         // DAC value in idle
    // ADC
    input  wire [ADC_DATA_W-1:0]     adc_dout,         // ADC output data
    // Acquisition
    input  wire                      acq_start,        // Acquisition start
    output reg                       acq_busy,         // Acquisition is in progress
    output reg                       acq_done,         // Acquisition is done
    input  wire [ACQ_LINES_W-1:0]    acq_lines,        // Acquisition lines
    output reg  [RAM_ADDR_W-1:0]     acq_waddr,        // Address to save current acquisition sample
    output reg  [RAM_DATA_W-1:0]     acq_wdata,        // Current acquisition sample value
    output reg                       acq_wen,          // Acquisition sample write enable
    // Misc
    input wire  [INICE_N-1:0]        inice             // Inputs from PMOD header, connected to FPGA
);
//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
// FSM states
localparam IDLE_S   = 0;
localparam INIT_S   = 1;
localparam SAMPLE_S = 2;
localparam DUMMY_S  = 3;
localparam DONE_S   = 4;

// Pulser stages
localparam PULSER_STAGE_INIT  = 0;
localparam PULSER_STAGE_ON    = 1;
localparam PULSER_STAGE_INTER = 2;
localparam PULSER_STAGE_OFF   = 3;

// Counters
localparam WORD_CNT_W    = $clog2(ACQ_WORDS_PER_LINE);
localparam LINE_CNT_W    = $clog2(ACQ_LINES_MAX);
localparam SEGMENT_N     = DAC_GAIN_N;
localparam SEGMENT_CNT_W = $clog2(DAC_GAIN_N);
localparam SEGMENT_LEN   = ACQ_WORDS_PER_LINE / SEGMENT_N;
localparam SEGMENT_LEN_W = $clog2(SEGMENT_LEN);

localparam ADC_PIPELINE_STAGES = 6;

// The purpose of gain threshold calculation is to finsh gain update right before first word of the next segment
localparam UPD_GAIN_THRESHOLD = SEGMENT_LEN -
                                2 -                              // DAC din/dvalid logic
                                DAC_SCK_DIV * (DAC_DATA_W + 6) - // DAC SPI exchange
                                2 -                              // ADC capture logic
                                ADC_PIPELINE_STAGES;             // Number of ADC pipiline stages
// Pulser should start right before first word of the next segment
localparam PULSER_START_THRESHOLD = SEGMENT_LEN -
                                    2 -                        // ADC capture logic
                                    ADC_PIPELINE_STAGES;       // Number of ADC pipiline stages

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
// FSM
reg [2:0] fsm_state, fsm_next;

// Ports
reg [DAC_DATA_W-1:0]     dac_din_next;
reg                      dac_dvalid_next;
reg [DAC_GAIN_PTR_W-1:0] dac_gain_ptr_next;
reg                      acq_busy_next;
reg                      acq_done_next;
reg [RAM_ADDR_W-1:0]     acq_waddr_next;
reg [RAM_DATA_W-1:0]     acq_wdata_next;
reg                      acq_wen_next;

reg [WORD_CNT_W-1:0] word_cnt, word_cnt_next;
reg [LINE_CNT_W-1:0] line_cnt, line_cnt_next;
reg [LINE_CNT_W-1:0] line_cnt_max, line_cnt_max_next;

reg upd_gain;
reg last_word;
reg last_line;
reg last_segment;
reg line_even, line_even_next;

wire [PULSER_LEN_W-1:0] pulser_init_len_odd;
reg  [PULSER_LEN_W-1:0] pulser_init_len_even;
wire [PULSER_LEN_W-1:0] pulser_init_len_drmode;
wire                    pulser_init_end;
wire                    pulser_inter_end;
wire                    pulser_on_end;
wire                    pulser_off_end;
wire                    pulser_stage_end;
reg  [PULSER_LEN_W-1:0] pulser_init_cnt;
reg  [PULSER_LEN_W-1:0] pulser_on_cnt;
reg  [PULSER_LEN_W-1:0] pulser_inter_cnt;
reg  [PULSER_LEN_W-1:0] pulser_off_cnt;
reg                     pulser_busy;
reg  [1:0]              pulser_stage;
reg                     pulser_start, pulser_start_next;

//-----------------------------------------------------------------------------
// Pulser
//-----------------------------------------------------------------------------
// initial delay for odd/even lines in double rate mode
assign pulser_init_len_odd = pulser_init_len;
always @(posedge clk or posedge rst) begin
    // NOTE: guaranteed that this value will be stable when it will be used, so no CDC errors
    if (rst)
        pulser_init_len_even <= '0;
    else
        pulser_init_len_even <= pulser_init_len + 1;
end
assign pulser_init_len_drmode = (pulser_drmode && line_even) ? pulser_init_len_even : pulser_init_len_odd;

// end of pulser stages
assign pulser_init_end  = (pulser_init_cnt == '0);
assign pulser_on_end    = (pulser_on_cnt == '0);
assign pulser_inter_end = (pulser_inter_cnt == '0);
assign pulser_off_end   = (pulser_off_cnt == '0);

// pulser stages
assign pulser_stage_end = pulser_init_end | pulser_on_end | pulser_inter_end | pulser_off_end;
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst)
        pulser_stage <= '0;
    else if (pulser_stage_end && pulser_busy)
        pulser_stage <= pulser_stage + 1;
end

// pulser busy
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst)
        pulser_busy <= 1'b0;
    else if (pulser_start)
        pulser_busy <= 1'b1;
    else if (pulser_off_end)
        pulser_busy <= 1'b0;
end

// pulser init counter
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst)
        pulser_init_cnt <= '1;
    else if (pulser_start && (!pulser_busy))
        pulser_init_cnt <= pulser_init_len_drmode;
    else if (pulser_busy && (pulser_stage == PULSER_STAGE_INIT))
        pulser_init_cnt <= pulser_init_cnt - 1;
end

// pulser on counter
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst)
        pulser_on_cnt <= '1;
    else if (pulser_init_end)
        pulser_on_cnt <= pulser_on_len;
    else if (pulser_busy && (pulser_stage == PULSER_STAGE_ON))
        pulser_on_cnt <= pulser_on_cnt - 1;
end

// pulser inter counter
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst)
        pulser_inter_cnt <= '1;
    else if (pulser_on_end)
        pulser_inter_cnt <= pulser_inter_len;
    else if (pulser_busy && (pulser_stage == PULSER_STAGE_INTER))
        pulser_inter_cnt <= pulser_inter_cnt - 1;
end

// pulser off counter
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst)
        pulser_off_cnt <= '1;
    else if (pulser_inter_end)
        pulser_off_cnt <= pulser_off_len;
    else if (pulser_busy && (pulser_stage == PULSER_STAGE_OFF))
        pulser_off_cnt <= pulser_off_cnt - 1;
end

// pulser outputs driver
always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst) begin
        pulser_on  <= 1'b0;
        pulser_off <= 1'b1;
    end else if (pulser_busy) begin
        if (pulser_init_end) begin
            pulser_on  <= 1'b1;
            pulser_off <= 1'b1;
        end else if (pulser_on_end) begin
            pulser_on  <= 1'b0;
            pulser_off <= 1'b1;
        end else if (pulser_inter_end) begin
            pulser_on  <= 1'b0;
            pulser_off <= 1'b0;
        end else if (pulser_off_end) begin
            pulser_on  <= 1'b0;
            pulser_off <= 1'b1;
        end
    end
end

/* Old pulser sequence

always @(posedge pulser_clk or posedge pulser_rst) begin
    if (pulser_rst) begin
        pulser_on  <= 1'b0;
        pulser_off <= 1'b0;
    end else if (pulser_busy) begin
        if (pulser_init_end) begin
            pulser_on  <= 1'b1;
            pulser_off <= 1'b0;
        end else if (pulser_on_end) begin
            pulser_on  <= 1'b0;
            pulser_off <= 1'b0;
        end else if (pulser_inter_end) begin
            pulser_on  <= 1'b0;
            pulser_off <= 1'b1;
        end else if (pulser_off_end) begin
            pulser_on  <= 1'b0;
            pulser_off <= 1'b0;
        end
    end
end

*/

//-----------------------------------------------------------------------------
// Acquisition FSM
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst)
        fsm_state <= IDLE_S;
    else
        fsm_state <= fsm_next;
end

always @(*) begin
    fsm_next          = fsm_state;
    dac_din_next      = dac_din;
    dac_dvalid_next   = 1'b0;
    dac_gain_ptr_next = dac_gain_ptr;
    acq_busy_next     = acq_busy;
    acq_done_next     = acq_done;
    acq_waddr_next    = acq_waddr;
    acq_wdata_next    = acq_wdata;
    acq_wen_next      = 1'b0;
    word_cnt_next     = word_cnt;
    line_cnt_next     = line_cnt;
    line_cnt_max_next = line_cnt_max;
    pulser_start_next = 1'b0;
    line_even_next    = line_even;

    upd_gain     = (word_cnt[0 +: SEGMENT_LEN_W] == UPD_GAIN_THRESHOLD) ? 1'b1 : 1'b0;
    last_word    = (word_cnt == (ACQ_WORDS_PER_LINE - 1)) ? 1'b1 : 1'b0;
    last_line    = (line_cnt == line_cnt_max) ? 1'b1 : 1'b0;
    last_segment = (word_cnt[WORD_CNT_W-1 -: SEGMENT_CNT_W] == (SEGMENT_N-1)) ? 1'b1 : 1'b0;

    case (fsm_state)
        IDLE_S: begin
            if (acq_start) begin
                acq_done_next     = 1'b0;
                acq_busy_next     = 1'b1;
                line_cnt_max_next = acq_lines[0 +: LINE_CNT_W]; // real number of lines is shorter than csr width
                word_cnt_next     = ACQ_WORDS_PER_LINE - SEGMENT_LEN;
                fsm_next          = INIT_S;
            end
        end

        INIT_S: begin
            // count words to fulfill one segment
            // this additional segment needed to setup gain 0
            word_cnt_next = word_cnt + 1;
            if (last_word) begin
                word_cnt_next = '0;
                fsm_next      = SAMPLE_S;
            end
            // update dac gain when needed
            if (upd_gain) begin
                dac_din_next      = dac_gain;
                dac_dvalid_next   = 1'b1;
                dac_gain_ptr_next = dac_gain_ptr + 1;
            end
            // start pulser
            pulser_start_next = (word_cnt[0 +: SEGMENT_LEN_W] == PULSER_START_THRESHOLD) ? 1'b1 : 1'b0;
        end

        SAMPLE_S: begin
            // increment word and line counter
            if (last_word) begin
                word_cnt_next     = '0;
                dac_din_next      = dac_idle;
                dac_dvalid_next   = 1'b1;
                line_even_next    = ~line_even;
                fsm_next          = DUMMY_S;
            end else begin
                word_cnt_next = word_cnt + 1;
            end

            // save adc data
            acq_waddr_next = {line_cnt, word_cnt};
            acq_wdata_next = {1'b0, inice, line_cnt[1:0], adc_dout};
            acq_wen_next   = 1'b1;

            // update dac gain when needed
            if (upd_gain && (!last_segment)) begin
                dac_din_next      = dac_gain;
                dac_dvalid_next   = 1'b1;
                dac_gain_ptr_next = dac_gain_ptr + 1;
            end
        end

        DUMMY_S: begin
            // dummy line where nothing happens
            if (last_word) begin
                word_cnt_next = '0;
                if (last_line) begin
                    line_cnt_next = '0;
                    fsm_next      = DONE_S;
                end else begin
                    line_cnt_next = line_cnt + 1;
                    fsm_next      = SAMPLE_S;
                end
            end else begin
                word_cnt_next = word_cnt + 1;
            end

            // update dac gain when needed
            if (last_segment && upd_gain && (!last_line)) begin
                dac_din_next      = dac_gain;
                dac_dvalid_next   = 1'b1;
                dac_gain_ptr_next = dac_gain_ptr + 1;
            end

            // start pulser
            pulser_start_next = ((!last_line) && last_segment && (word_cnt[0 +: SEGMENT_LEN_W] == PULSER_START_THRESHOLD)) ? 1'b1 : 1'b0;
        end

        DONE_S: begin
             acq_busy_next = 1'b0;
             acq_done_next = 1'b1;
             fsm_next      = IDLE_S;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        dac_din      <= '0;
        dac_dvalid   <= 1'b0;
        dac_gain_ptr <= '0;
        acq_busy     <= 1'b0;
        acq_done     <= 1'b0;
        acq_waddr    <= '0;
        acq_wdata    <= '0;
        acq_wen      <= 1'b0;
        word_cnt     <= '0;
        line_cnt     <= '0;
        line_cnt_max <= '0;
        pulser_start <= 1'b0;
        line_even    <= 1'b0;
    end else begin
        dac_din      <= dac_din_next;
        dac_dvalid   <= dac_dvalid_next;
        dac_gain_ptr <= dac_gain_ptr_next;
        acq_busy     <= acq_busy_next;
        acq_done     <= acq_done_next;
        acq_waddr    <= acq_waddr_next;
        acq_wdata    <= acq_wdata_next;
        acq_wen      <= acq_wen_next;
        word_cnt     <= word_cnt_next;
        line_cnt     <= line_cnt_next;
        line_cnt_max <= line_cnt_max_next;
        pulser_start <= pulser_start_next;
        line_even    <= line_even_next;
    end
end

endmodule
