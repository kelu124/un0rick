//-----------------------------------------------------------------------------
// SPI master behavioral model
//-----------------------------------------------------------------------------

module spi_mst_beh #(
    parameter FREQ_MHZ = 4,
    parameter LEN_W    = 14,
    parameter DATA_W   = 16,
    parameter ADDR_W   = 8
)(
    input  wire miso,   // SPI master input / slave output
    output reg  mosi,   // SPI master output / slave input
    output reg  sck,    // SPI clock
    output reg  cs_n    // SPI chip select (active low)
);
//-------------------------------------------------------------------
// Parameters
//-------------------------------------------------------------------
localparam CTRL_W       = 2 + LEN_W + ADDR_W;
localparam TURNAROUND_W = 1;

//-------------------------------------------------------------------
// Variables
//-------------------------------------------------------------------
reg clk = 0;

reg [DATA_W-1:0] data_mem [0:2**LEN_W-1];
reg [ADDR_W-1:0] addr_mem [0:2**LEN_W-1];

//-------------------------------------------------------------------
// Clock
//-------------------------------------------------------------------
always begin
    #(500.0/FREQ_MHZ); // to get half of the period in ns: ((1/F) * 1000) / 2
    clk <= ~clk;
end

//-------------------------------------------------------------------
// IO init
//-------------------------------------------------------------------
initial begin
    mosi = 0;
    sck  = 0;
    cs_n = 1;
end

//-------------------------------------------------------------------
// Write tasks
//-------------------------------------------------------------------
task write_rand (
    input reg             incr,
    input reg [LEN_W-1:0] len
);
begin : write_rand
    reg [ADDR_W-1:0] addr;
    reg [DATA_W-1:0] data;
    integer          data_n;

    data_n = len + 1;
    addr = $random();

    $display("\nspi_write%0s: addr=0x%02x len=%0d", incr ? "_incr" : "_fixed", addr, len);
    @(posedge clk) cs_n <= 0;
    @(posedge clk);
    fork
        begin : mosi_proc
            integer i;
            integer n;
            // transaction parameters
            @(negedge clk) mosi <= 1; // 1 for write
            @(negedge clk) mosi <= incr;
            for (i = 0; i < LEN_W; i = i + 1) begin
                @(negedge clk) mosi <= len[LEN_W - 1 - i];
            end
            // address
            for (i = 0; i < ADDR_W; i = i + 1) begin
                @(negedge clk) mosi <= addr[ADDR_W - 1 - i];
            end
            // data
            for (n = 0; n < data_n; n = n + 1) begin
                data = $random();
                $display("\tdata[%0d]=0x%04x", n, data);
                for (i = 0; i < DATA_W; i = i + 1) begin
                    @(negedge clk) mosi <= data[DATA_W - 1 - i];
                end
                addr_mem[n] = addr;
                data_mem[n] = data;
                addr = incr ? addr + 1 : addr;
            end
        end
        begin : sck_proc
            // control word
            repeat (CTRL_W) begin
                @(posedge clk) sck <= 1;
                @(negedge clk) sck <= 0;
            end
            // data
            repeat (DATA_W * data_n) begin
                @(posedge clk) sck <= 1;
                @(negedge clk) sck <= 0;
            end
        end
    join
    @(posedge clk);
    @(posedge clk) cs_n <= 1;
end
endtask

//-------------------------------------------------------------------
// Read tasks
//-------------------------------------------------------------------
task read_rand (
    input reg             incr,
    input reg [LEN_W-1:0] len
);
begin : read_rand
    reg [ADDR_W-1:0] addr;
    reg [DATA_W-1:0] data;
    integer          data_n;

    data_n = len + 1;
    addr = $random();
    $display("\nspi_read%0s: addr=0x%02x len=%0d", incr ? "_incr" : "_fixed", addr, len);
    @(posedge clk) cs_n <= 0;
    @(posedge clk);
    fork
        begin : mosi_proc
            integer i;
            // transaction parameters
            @(negedge clk) mosi <= 0; // 0 for read
            @(negedge clk) mosi <= incr;
            for (i = 0; i < LEN_W; i = i + 1) begin
                @(negedge clk) mosi <= len[LEN_W - 1 - i];
            end
            // address
            for (i = 0; i < ADDR_W; i = i + 1) begin
                @(negedge clk) mosi <= addr[ADDR_W - 1 - i];
            end
            // dummy and data
            @(negedge clk) mosi <= 0;
        end
        begin : miso_proc
            integer i;
            integer n;
            repeat (CTRL_W + TURNAROUND_W) @(posedge clk);
            for (n = 0; n < data_n; n = n + 1) begin
                for (i = 0; i < DATA_W; i = i + 1) begin
                    @(posedge clk) data[DATA_W - 1 - i] = miso;
                end
                $display("\tdata[%0d]=0x%04x", n, data);
                addr_mem[n] = addr;
                data_mem[n] = data;
                addr = incr ? addr + 1 : addr;
            end
        end
        begin : sck_proc
            // control word
            repeat (CTRL_W) begin
                @(posedge clk) sck <= 1;
                @(negedge clk) sck <= 0;
            end
            // turnaround delay
            repeat (TURNAROUND_W) @(posedge clk);
            // data
            repeat (DATA_W * data_n) begin
                @(posedge clk) sck <= 1;
                @(negedge clk) sck <= 0;
            end
        end
    join
    @(posedge clk);
    @(posedge clk) cs_n <= 1;
end
endtask

endmodule