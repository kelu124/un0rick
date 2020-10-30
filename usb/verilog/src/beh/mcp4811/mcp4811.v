module mcp4811 #(
    parameter DAC_DATA_W = 10
)(
    input wire cs_n,
    input wire sck,
    input wire sdi,
    input wire ld_n
);

reg [DAC_DATA_W-1:0] data_in;
reg [DAC_DATA_W-1:0] data_out;

initial begin : dac_spi
    integer i;
    forever begin
        @(negedge cs_n);
        @(posedge sck);
         if (sdi !== 1'b0)
             $display("%t Error in bit 15 - expected 0 for write!", $time);
         @(posedge sck); // don't care bit
         @(posedge sck);
         if (sdi !== 1'b1)
             $display("%t Error in bit 13 - expected 1 (gain x1)!", $time);
         @(posedge sck);
         if (sdi !== 1'b1)
             $display("%t Error in bit 12 - expected 1 (active mode)!", $time);
         for (i = 0; i < DAC_DATA_W; i = i + 1) begin
             @(posedge sck);
             data_in[DAC_DATA_W - 1 - i] = sdi;
         end
         @(posedge sck); // don't care bit
         @(posedge sck); // don't care bit
        @(posedge cs_n);
        if (ld_n)
            @(negedge ld_n);
        data_out = data_in;
        $display("%t DAC output is 0x%03x", $time, data_out);
    end
end

endmodule
