module vga_recv #(
    parameter WIDTH     = 640,
    parameter HEIGHT    = 480,
    parameter DUMP_PATH = "frame"
)(
    input wire       pixel_clk,
    input wire [7:0] pixel_r,
    input wire [7:0] pixel_g,
    input wire [7:0] pixel_b,
    input wire       line_active,
    input wire       frame_end
);

integer frame_cnt = 0;
integer pixel_cnt = 0;
integer line_cnt  = 0;

reg [8*64-1:0] frame_dump_path;
integer frame_dump = 0;

initial forever begin
    `ifdef MODEL_TECH
    // Modelsim
    frame_dump_path = {>>{$sformatf("%0s%0d", DUMP_PATH, frame_cnt)}};
    `else
    frame_dump_path = $sformatf("%0s%0d", DUMP_PATH, frame_cnt);
    `endif
    // pixels cycles
    for (line_cnt = 0; line_cnt < HEIGHT; line_cnt = line_cnt + 1) begin
        @(posedge line_active)
        if (frame_dump == 0) // open file to write
            frame_dump = $fopen(frame_dump_path,"w");
        for (pixel_cnt = 0; pixel_cnt < WIDTH; pixel_cnt = pixel_cnt + 1) begin
            @(negedge pixel_clk);
            $fwrite(frame_dump, "%02x%02x%02x\n", pixel_r, pixel_g, pixel_b);
        end
    end
    // close file
    @(posedge frame_end);
    $fclose(frame_dump);
    frame_dump = 0;
    frame_cnt  = frame_cnt + 1;
    @(negedge frame_end);
end

endmodule