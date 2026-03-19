module top
(
    output wire rgb_led,
    input wire clk,
    input wire btn1
);

    reg [23:0] led_data;
    reg start;
    reg btn_prev;
    wire busy;

    always @(posedge clk) begin
        led_data <= 24'h0000aa;
        start <= 1'b1;
    end

    ws_tx strip1 (
        .clk(clk),
        .start(start),
        .data(led_data),
        .tx(rgb_led),
        .busy(busy)
    );

endmodule
