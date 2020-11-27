module adc10065 #(
    parameter DATA_W = 10
)(
    input  wire             clk,
    output wire [DATA_W-1:0] data
);

integer tick_cnt = 0;
localparam PIPE_LEN = 6;

reg [PIPE_LEN*DATA_W-1:0] data_pipe = '0;
reg [DATA_W-1:0] data_orig = '0;

always @(posedge clk) begin
    data_orig <= $random();
    tick_cnt  <= tick_cnt + 1;
end

always @(posedge clk) begin
    data_pipe[0 +: DATA_W] <= data_orig;
    data_pipe[DATA_W +: (PIPE_LEN-1)*DATA_W] <= data_pipe[0 +: (PIPE_LEN-1)*DATA_W];
end

assign #5 data = data_pipe[PIPE_LEN*DATA_W-1 -: DATA_W];

endmodule