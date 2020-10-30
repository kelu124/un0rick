//-------------------------------------------------------------------
// Bridge from SPI to CSR map interface.
//
// SPI parameters:
//   - slave;
//   - mode 0 only;
//   - most significant bit transmitted first;
//   - byte order from high to low;
//   - SCK frequency must at least 8 lower than system frequency.
//
// There are 2 types of SPI transactions:
//   - incremental burst -- address increments internally after every data (array)
//   - fixed burst -- one adreess, multiple data (FIFO)
// Transaction is done with 8-bit address and 16 bit data words.
// Transaction format:
//   - control word (3 bytes):
//       * bit 23 -- write (1) or read (0)
//       * bit 22 -- burst incremental (1) or fixed (0)
//       * bit 21 .. 8 -- 14 bit length (0 - 1 data word, 1 - 2 data words, etc)
//       * bits 7 .. 0 -- 8 bit address
//   - data word (2 bytes) 1 .. N:
//       * bits 15 .. 0 -- data to be written or readen
//
// CSR write:
//   - no handshake or feedback
//   - simply pulse wen when wdata is valid
//
// CSR read:
//   - with handshake
//   - ren asserted when data need to be readen
//   - rvalid must be asserted when valid data is on the bus
//   - when (rvalid && ren) == 1 - handshake is done, rdata saved and ren deasserted
//   - data must become available no later than max_delay ticks after ren was asserted:
//     max_delay = floor(sys_freq/sck_freq) - 3
//
//-------------------------------------------------------------------
module spi2csr #(
    parameter CSR_ADDR_W     = 8,   // CSR address width
    parameter CSR_DATA_W     = 16,  // CSR data width
    parameter SPI_CTRL_LEN_W = 14   // SPI control word "length" width
)(
    // System
    input  wire                  clk,        // System clock
    input  wire                  rst,        // System reset
    // SPI Slave interface
    output reg                   spi_miso,   // SPI master input / slave output
    input  wire                  spi_mosi,   // SPI master output / slave input
    input  wire                  spi_sck,    // SPI clock
    input  wire                  spi_cs_n,   // SPI chip select (active low)
    // CSR map interface
    output reg  [CSR_ADDR_W-1:0] csr_addr,   // CSR address
    output reg                   csr_wen,    // CSR write enable
    output reg  [CSR_DATA_W-1:0] csr_wdata,  // CSR write data
    output reg                   csr_ren,    // CSR read enable
    input  wire                  csr_rvalid, // CSR read data is valid
    input  wire [CSR_DATA_W-1:0] csr_rdata   // CSR read data
);
//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
// FSM states
localparam IDLE_S        = 0;
localparam RECV_TYPE_S   = 1;
localparam RECV_BURST_S  = 2;
localparam RECV_LEN_S    = 3;
localparam RECV_ADDR_S   = 4;
localparam WAIT_TA_S     = 5;
localparam RECV_DATA_S   = 6;
localparam INCR_ADDR_S   = 7;
localparam READ_DATA_S   = 8;
localparam TRAN_DATA_S   = 9;
localparam WAIT_FINISH_S = 10;

//-----------------------------------------------------------------------------
// Variables
//-----------------------------------------------------------------------------
reg [3:0] fsm_state;
reg [3:0] fsm_next;

reg [1:0] cs_n_ff;
wire cs_n_sync;

reg [1:0] mosi_ff;
wire mosi_sync;

reg [2:0] sck_ff;
reg sck_posedge, sck_negedge;

reg spi_miso_next;
reg [CSR_ADDR_W-1:0] csr_addr_next;
reg [CSR_DATA_W-1:0] csr_wdata_next;
reg csr_wen_next;
reg csr_ren_next;
reg [CSR_DATA_W-1:0] dout_shifter, dout_shifter_next;
reg type_wr, type_wr_next;
reg burst_incr, burst_incr_next;
reg [SPI_CTRL_LEN_W-1:0] len_cnt, len_cnt_next;
reg [$clog2(CSR_DATA_W)-1:0] bit_cnt, bit_cnt_next;
reg force_tran, force_tran_next;

//-----------------------------------------------------------------------------
// MOSI syncronization
//-----------------------------------------------------------------------------
// syncronization chain
always @(posedge clk or posedge rst) begin
    if (rst) begin
        mosi_ff <= '0;
    end else begin
        mosi_ff <= {mosi_ff[0], spi_mosi};
    end
end

assign mosi_sync = mosi_ff[1];

//-----------------------------------------------------------------------------
// CSn syncronization
//-----------------------------------------------------------------------------
// syncronization chain
always @(posedge clk or posedge rst) begin
    if (rst) begin
        cs_n_ff <= '0;
    end else begin
        cs_n_ff <= {cs_n_ff[0], spi_cs_n};
    end
end

assign cs_n_sync = cs_n_ff[1];

//-----------------------------------------------------------------------------
// SCK syncronization and edge extraction
//-----------------------------------------------------------------------------
// syncronization chain
always @(posedge clk or posedge rst) begin
    if (rst) begin
        sck_ff <= '0;
    end else begin
        sck_ff <= {sck_ff[1:0], spi_sck};
    end
end
// edge extraction
always @(*) begin
    sck_posedge = (~sck_ff[2]) & ( sck_ff[1]);
    sck_negedge = ( sck_ff[2]) & (~sck_ff[1]);
end

//-----------------------------------------------------------------------------
// SPI slave FSM
//-----------------------------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst)
        fsm_state <= IDLE_S;
    else
        fsm_state <= fsm_next;
end

always @(*) begin
    fsm_next          = fsm_state;
    type_wr_next      = type_wr;
    burst_incr_next   = burst_incr;
    len_cnt_next      = len_cnt;
    dout_shifter_next = dout_shifter;
    bit_cnt_next      = bit_cnt;
    force_tran_next   = force_tran;
    spi_miso_next     = spi_miso;
    csr_addr_next     = csr_addr;
    csr_wdata_next    = csr_wdata;
    csr_wen_next      = csr_wen;
    csr_ren_next      = csr_ren;
    case (fsm_state)
        IDLE_S : begin
            // wait when transaction starts with cs_n assertion
            spi_miso_next = 1'b0;
            if (!cs_n_sync)
                fsm_next = RECV_TYPE_S;
        end

        RECV_TYPE_S : begin
            // receive transaction type: write (1) or read (0)
            if (sck_posedge) begin
                type_wr_next = mosi_sync;
                fsm_next     = RECV_BURST_S;
            end
        end

        RECV_BURST_S : begin
            // receive burst type: incremental (1) or fixed (0)
            if (sck_posedge) begin
                burst_incr_next = mosi_sync;
                bit_cnt_next    = SPI_CTRL_LEN_W - 1;
                fsm_next        = RECV_LEN_S;
            end
        end

        RECV_LEN_S : begin
            // receive transaction length
            if (sck_posedge) begin
                len_cnt_next = {len_cnt[SPI_CTRL_LEN_W-2:0], mosi_sync};
                if (bit_cnt == '0) begin
                    bit_cnt_next = CSR_ADDR_W - 1;
                    fsm_next     = RECV_ADDR_S;
                end else begin
                    bit_cnt_next = bit_cnt - 1;
                end
            end
        end

        RECV_ADDR_S : begin
            // receive address
            if (sck_posedge) begin
                csr_addr_next = {csr_addr[CSR_ADDR_W-2:0], mosi_sync};
                if (bit_cnt == '0) begin
                    bit_cnt_next = CSR_DATA_W - 1;
                    fsm_next     = type_wr ? RECV_DATA_S : WAIT_TA_S;
                end else begin
                    bit_cnt_next = bit_cnt - 1;
                end
            end
        end

        WAIT_TA_S : begin
            // wait turnaround to start
            if (sck_negedge) begin
                force_tran_next = 1'b1;
                csr_ren_next    = 1'b1;
                fsm_next        = READ_DATA_S;
            end
        end

        READ_DATA_S : begin
            // wait read data become valid
            if (csr_rvalid) begin
                csr_ren_next      = 1'b0;
                dout_shifter_next = csr_rdata;
                fsm_next          = TRAN_DATA_S;
            end
        end

        RECV_DATA_S : begin
            // receive data bit by bit at every sck posedge
            if (sck_posedge) begin
                csr_wdata_next = {csr_wdata[CSR_DATA_W-2:0], mosi_sync};
                if (bit_cnt == '0) begin
                    csr_wen_next  = 1'b1;
                    if (len_cnt == '0) begin
                        fsm_next = WAIT_FINISH_S;
                    end else begin
                        len_cnt_next = len_cnt - 1;
                        fsm_next     = INCR_ADDR_S;
                    end
                end else begin
                    bit_cnt_next = bit_cnt - 1;
                end
            end else if (cs_n_sync) begin
                fsm_next = IDLE_S;
            end
        end

        INCR_ADDR_S : begin
            // prepare for the new word
            bit_cnt_next  = CSR_DATA_W - 1;
            // increment address only if needed
            csr_addr_next = burst_incr ? csr_addr + 1 : csr_addr;
            if (type_wr) begin
                // we increment address only after write, so we need to deassert wen
                csr_wen_next = 1'b0;
                fsm_next     = RECV_DATA_S;
            end else begin
                // we increment address only before read, so we need to assert ren
                csr_ren_next = 1'b1;
                fsm_next     = READ_DATA_S;
            end
        end

        TRAN_DATA_S : begin
            force_tran_next = 1'b0;
            // transmit data bit by bit at every sck negedge
            if (sck_negedge || force_tran) begin
                spi_miso_next = dout_shifter[CSR_DATA_W-1];
                dout_shifter_next = {dout_shifter[CSR_DATA_W-2:0], 1'b0};
                if (bit_cnt == '0) begin
                    if (len_cnt == '0) begin
                        fsm_next = WAIT_FINISH_S;
                    end else begin
                        len_cnt_next = len_cnt - 1;
                        fsm_next     = INCR_ADDR_S;
                    end
                end else begin
                    bit_cnt_next = bit_cnt - 1;
                end
            end else if (cs_n_sync) begin
                fsm_next = IDLE_S;
            end
        end

        WAIT_FINISH_S : begin
            // we can get here right after last write, so just deassert wen every time
            csr_wen_next = 1'b0;
            // just wait when cs_n will be deassered
            if (cs_n_sync)
                fsm_next = IDLE_S;
        end
    endcase
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        type_wr      <= 1'b0;
        burst_incr   <= 1'b0;
        len_cnt      <= '0;
        dout_shifter <= '0;
        bit_cnt      <= '0;
        force_tran   <= 1'b0;
        spi_miso     <= 1'b0;
        csr_addr     <= '0;
        csr_wdata    <= '0;
        csr_wen      <= 1'b0;
        csr_ren      <= 1'b0;
    end else begin
        type_wr      <= type_wr_next;
        burst_incr   <= burst_incr_next;
        len_cnt      <= len_cnt_next;
        dout_shifter <= dout_shifter_next;
        bit_cnt      <= bit_cnt_next;
        force_tran   <= force_tran_next;
        spi_miso     <= spi_miso_next;
        csr_addr     <= csr_addr_next;
        csr_wdata    <= csr_wdata_next;
        csr_wen      <= csr_wen_next;
        csr_ren      <= csr_ren_next;
    end
end

endmodule