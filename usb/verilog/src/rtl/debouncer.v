//-------------------------------------------------------------------
// Debounce filter.
// If din is stable durigng DELAY ticks, dout will be updated.
//
//-------------------------------------------------------------------
module debouncer #(
    parameter DELAY = 1000000 // delay in clk ticks
)(
    input  wire clk, 		
    input  wire rst, 
    input  wire din,
    output reg  dout  
);

localparam CNT_W = $clog2(DELAY);

reg [CNT_W-1:0] db_cnt;
reg din_new;
        
always @(posedge clk or posedge rst) begin
    if (rst) begin
        din_new <= 1'b0;
        dout    <= 1'b0;
        db_cnt  <= 0;
    end else if (din != din_new) begin
        din_new <= din;
        db_cnt  <= 0;
    end else if (db_cnt == (DELAY - 1)) begin
        dout    <= din_new;
    end else if (db_cnt < DELAY) begin
        db_cnt  <= db_cnt + 1;
    end
end

endmodule 
