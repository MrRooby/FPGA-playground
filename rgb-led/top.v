module top
(
    output wire rgb_led,
    input wire clk,
    input wire btn1
);

    reg [23:0] led_data;
    reg start;
    reg btn_prev;
    reg [23:0] led_mem [0:4];
    wire [5*24-1:0] led_mem_flat;
    assign led_mem_flat = {led_mem[4], led_mem[3], led_mem[2], led_mem[1], led_mem[0]};

    always @(posedge clk) begin
        led_mem[0] <= 24'h0000aa;
        led_mem[1] <= 24'h0000aa;
        led_mem[2] <= 24'h0000aa;
        led_mem[3] <= 24'h0000aa;
        led_mem[4] <= 24'h00aa00;
        start <= 1'b1;
    end

    strip_tx #(.NUM_LEDS(5)) strip1(
        .clk(clk),
        .start(start),
        .tx(rgb_led),
        .mem_flat(led_mem_flat)
    );

endmodule
