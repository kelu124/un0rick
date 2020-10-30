//-------------------------------------------------------------------
// Test for spi2csr module
//-------------------------------------------------------------------
module tb_spi2csr();

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
localparam CSR_ADDR_W     = 8;
localparam CSR_DATA_W     = 16;
localparam SPI_CTRL_LEN_W = 14;
localparam SPI_FREQ_MHZ   = 8;

wire spi_miso;
wire spi_mosi;
wire spi_sck;
wire spi_cs_n;

wire [CSR_ADDR_W-1:0] csr_addr;
wire                  csr_wen;
wire [CSR_DATA_W-1:0] csr_wdata;
wire                  csr_ren;
reg                   csr_rvalid = 0;
reg  [CSR_DATA_W-1:0] csr_rdata  = '0;

spi2csr #(
    .CSR_ADDR_W     (CSR_ADDR_W),
    .CSR_DATA_W     (CSR_DATA_W),
    .SPI_CTRL_LEN_W (SPI_CTRL_LEN_W)
) dut (
    // System
    .clk        (tb_clk),     // System clock
    .rst        (tb_rst),     // System reset
    // SPI Slave interface
    .spi_miso   (spi_miso),   // SPI master input / slave output
    .spi_mosi   (spi_mosi),   // SPI master output / slave input
    .spi_sck    (spi_sck),    // SPI clock
    .spi_cs_n   (spi_cs_n),   // SPI chip select (active low)
    // CSR map interface
    .csr_addr   (csr_addr),   // CSR address
    .csr_wen    (csr_wen),    // CSR write enable
    .csr_wdata  (csr_wdata),  // CSR write data
    .csr_ren    (csr_ren),    // CSR read enable
    .csr_rvalid (csr_rvalid), // CSR read data is valid
    .csr_rdata  (csr_rdata)   // CSR read data
);

//-------------------------------------------------------------------
// CSR bus
//-------------------------------------------------------------------
reg [CSR_DATA_W-1:0] csr_data_mem [0:2**SPI_CTRL_LEN_W-1];
reg [CSR_ADDR_W-1:0] csr_addr_mem [0:2**SPI_CTRL_LEN_W-1];

integer mem_ptr;
initial begin
    forever begin
        // reset pointer on the start ov every transaction
        @(negedge spi_cs_n) mem_ptr = 0;
    end
end

initial begin : csr_read
    reg [CSR_DATA_W-1:0] data;
    forever begin
        @(posedge tb_clk);
        if (csr_ren) begin
            @(posedge tb_clk);
            data = $random();
            $display("csr_read: addr=0x%02x data=0x%04x", csr_addr, data);
            csr_data_mem[mem_ptr] = data;
            csr_addr_mem[mem_ptr] = csr_addr;
            mem_ptr = mem_ptr + 1;
            csr_rvalid <= 1'b1;
            csr_rdata  <= data;
            @(posedge tb_clk);
            csr_rvalid <= 1'b0;
            csr_rdata  <= '0;
        end
    end
end

initial begin : csr_write
    forever begin
        @(posedge tb_clk);
        if (csr_wen) begin
            $display("csr_write: addr=0x%02x data=0x%04x", csr_addr, csr_wdata);
            csr_data_mem[mem_ptr] = csr_wdata;
            csr_addr_mem[mem_ptr] = csr_addr;
            mem_ptr = mem_ptr + 1;
        end
    end
end

//-------------------------------------------------------------------
// SPI master
//-------------------------------------------------------------------
spi_mst_beh #(
    .FREQ_MHZ (SPI_FREQ_MHZ),
    .LEN_W    (SPI_CTRL_LEN_W),
    .DATA_W   (CSR_DATA_W),
    .ADDR_W   (CSR_ADDR_W)
) spi_mst (
    .miso (spi_miso), // SPI master input / slave output
    .mosi (spi_mosi), // SPI master output / slave input
    .sck  (spi_sck),  // SPI clock
    .cs_n (spi_cs_n)  // SPI chip select (active low)
);

//-------------------------------------------------------------------
// Testbench body
//-------------------------------------------------------------------
function integer verify(input integer len);
begin : func_verify
    integer err_cnt;
    integer i;
    err_cnt = 0;
    for (i = 0; i <= len; i = i + 1) begin
        if (csr_data_mem[i] !== spi_mst.data_mem[i]) begin
            err_cnt = err_cnt + 1;
            $error("Verify error! Test data is 0x%04x, but golden data is 0x%04x", csr_data_mem[i], spi_mst.data_mem[i]);
        end
        if (csr_addr_mem[i] !== spi_mst.addr_mem[i]) begin
            err_cnt = err_cnt + 1;
            $error("Verify error! Test address is 0x%02x, but golden address is 0x%02x", csr_addr_mem[i], spi_mst.addr_mem[i]);
        end
    end
    verify = err_cnt;
end
endfunction

// Main test
reg [CSR_DATA_W-1:0] rdata;
initial begin : tb_main
    integer err_cnt;
    err_cnt = 0;

    wait(tb_rst);
    repeat (3) @(posedge tb_clk);

    // write
    spi_mst.write_rand(0, 0); // fixed, 1 word
    err_cnt = err_cnt + verify(0);
    spi_mst.write_rand(0, 2); // fixed, 3 words
    err_cnt = err_cnt + verify(2);
    spi_mst.write_rand(1, 2); // incr, 3 words
    err_cnt = err_cnt + verify(2);
    spi_mst.write_rand(1, 31); // incr, 32 words
    err_cnt = err_cnt + verify(31);
    spi_mst.write_rand(0, 16383); // fixed, 16384 words
    err_cnt = err_cnt + verify(16383);
    // read
    spi_mst.read_rand(0, 0); // fixed, 1 word
    err_cnt = err_cnt + verify(0);
    spi_mst.read_rand(0, 2); // fixed, 3 words
    err_cnt = err_cnt + verify(2);
    spi_mst.read_rand(1, 2); // incr, 3 words
    err_cnt = err_cnt + verify(2);
    spi_mst.read_rand(0, 31); // incr, 32 words
    err_cnt = err_cnt + verify(31);
    spi_mst.read_rand(0, 16383); // fixed, 16384 words
    err_cnt = err_cnt + verify(16383);

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
    $dumpvars(0, tb_spi2csr);
end
`endif

endmodule