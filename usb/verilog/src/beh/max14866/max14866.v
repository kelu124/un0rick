module max14866 #(
    parameter SWITCH_N = 16
)(
    input                   le_n,
    input                   clk,
    input                   din,
    output reg              dout,
    output reg [SWITCH_N-1:0] switch
);

reg [SWITCH_N-1:0] shifter = 0;

initial begin : hvmux
    integer i;
    dout = 0;
    switch = 0;
    fork
        forever begin: shift
            @(posedge clk);
            shifter <= {shifter[SWITCH_N-2:0], din};
            dout    <= shifter[SWITCH_N-1];
        end
        forever begin: enable
            @(negedge le_n);
            switch <= shifter;
        end
    join
end

endmodule
