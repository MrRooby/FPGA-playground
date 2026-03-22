module top (
    output wire rgb_led,
    input  wire clk,
    input  wire btn1
);
    localparam NUM_LEDS = 5;

    reg start;
    reg [23:0] data;
    // reg btn1_d = 1'b0;

    // reg [23:0] led_mem [0:NUM_LEDS-1];
    // wire [NUM_LEDS*24-1:0] led_mem_flat;

    // assign led_mem_flat = {led_mem[4], led_mem[3], led_mem[2], led_mem[1], led_mem[0]};

    always @(posedge clk) begin
        start <= 1'b1;
        data <= 24'hFF0000;
    end

    // strip_tx #(.NUM_LEDS(NUM_LEDS)) strip1 (
    //     .clk(clk),
    //     .rst(1'b0),          // or btn1 if you really want button-as-reset
    //     .start(start),
    //     .mem_flat(led_mem_flat),
    //     .tx(rgb_led)
    // );

    led_tx led1 (
        .clk(clk),
        .start(start),
        .gap(1'b0),
        .data(data),
        .tx(rgb_led),
        .busy(busy)
    );

endmodule