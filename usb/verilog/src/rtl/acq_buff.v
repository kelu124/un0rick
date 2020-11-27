//-------------------------------------------------------------------
// Acquisitions buffer
//
// Extracted envelope, dacgain and topturn values will be stored here
// for every 1st line.
//
// Note: have to use tech primitive due to yosys inferring issues.
//
//-------------------------------------------------------------------

module acq_buff #(
    parameter ADDR_W    = 9,
    parameter DATA_W    = 24
)(
    // Write interface
    input  wire              wclk,  // Write clock
    input  wire [DATA_W-1:0] wdata, // Write data
    input  wire [ADDR_W-1:0] waddr, // Write address
    input  wire              wr,    // Write operation enable
    // Read interface
    input  wire              rclk,  // Read clock
    output wire [DATA_W-1:0] rdata, // Read data
    input  wire [ADDR_W-1:0] raddr, // Read address
    input  wire              rd     // Read operation enable
);

`ifdef SIM
    dpram #(
        .ADDR_W    (ADDR_W),
        .DATA_W    (DATA_W),
        .INIT_FILE ("../../src/rtl/acq_buff_init.mem")
    ) dpram (
        // Write interface
        .wclk  (wclk),  // Write clock
        .wdata (wdata), // Write data
        .waddr (waddr), // Write address
        .wr    (wr),    // Write operation enable
        // Read interface
        .rclk  (rclk),  // Read clock
        .rdata (rdata), // Read data
        .raddr (raddr), // Read address
        .rd    (rd)     // Read operation enable
    );
`else
genvar gen_i;
for (gen_i = 0; gen_i < DATA_W/8; gen_i=gen_i+1) begin : gen_dpram
    wire [DATA_W-1:0] unused;
    SB_RAM40_4K #(
        .INIT_0     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_1     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_2     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_3     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_4     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_5     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_6     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_7     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_8     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_9     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_A     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_B     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_C     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_D     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_E     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_F     (256'h0000000000000000000000000000000000000000000000000000000000000000),
        .WRITE_MODE (1), //512x8
        .READ_MODE  (1)  //512x8
    ) dpram (
        // read
        .RCLK  (rclk),
        .RCLKE (rd),
        .RDATA (
            {unused[gen_i*8 + 7], rdata[gen_i*8 + 7],
             unused[gen_i*8 + 6], rdata[gen_i*8 + 6],
             unused[gen_i*8 + 5], rdata[gen_i*8 + 5],
             unused[gen_i*8 + 4], rdata[gen_i*8 + 4],
             unused[gen_i*8 + 3], rdata[gen_i*8 + 3],
             unused[gen_i*8 + 2], rdata[gen_i*8 + 2],
             unused[gen_i*8 + 1], rdata[gen_i*8 + 1],
             unused[gen_i*8 + 0], rdata[gen_i*8 + 0]}
        ),
        .RADDR ({2'b00, raddr}),
        .RE    (1'b1),
        // write
        .WCLK  (wclk),
        .WCLKE (wr),
        .WDATA (
            {1'b0, wdata[gen_i*8 + 7],
             1'b0, wdata[gen_i*8 + 6],
             1'b0, wdata[gen_i*8 + 5],
             1'b0, wdata[gen_i*8 + 4],
             1'b0, wdata[gen_i*8 + 3],
             1'b0, wdata[gen_i*8 + 2],
             1'b0, wdata[gen_i*8 + 1],
             1'b0, wdata[gen_i*8 + 0]}
        ),
        .MASK  (16'h0),
        .WADDR ({2'b00, waddr}),
        .WE    (1'b1)
    );
end
`endif

endmodule
