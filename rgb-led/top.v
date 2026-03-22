module top
(
    output wire rgb_led,
    input wire clk,
    input wire btn1
);
    localparam SHIFT_T = 1000;
    reg start;
    reg busy;
    reg init = 1;
    reg [15:0] clk_counter;
    reg [23:0] led_mem [0:4];
    wire [5*24-1:0] led_mem_flat;
    assign led_mem_flat = {led_mem[4], led_mem[3], led_mem[2], led_mem[1], led_mem[0]};

    always @(posedge clk) begin
        if(init) begin
            led_mem[0] <= 24'h00_22_00;
            led_mem[1] <= 24'h00_55_00;
            led_mem[2] <= 24'h00_88_00;
            led_mem[3] <= 24'h00_BB_00;
            led_mem[4] <= 24'h00_EE_00;
            init <= 0;
            clk_counter <= 0;
        end


        if(!busy) begin
            start <= 1'b1;

            clk_counter <= clk_counter + 1;
            if(clk_counter >= SHIFT_T) begin
                clk_counter <= 0;
                led_mem[0] <= led_mem[1];
                led_mem[1] <= led_mem[2];
                led_mem[2] <= led_mem[3];
                led_mem[3] <= led_mem[4];
                led_mem[4] <= led_mem[0];
            end
        end else begin
            start <= 1'b0;
        end
    end

    strip_tx #(.NUM_LEDS(5)) strip1(
        .clk(clk),
        .start(start),
        .tx(rgb_led),
        .mem_flat(led_mem_flat),
        .strip_busy(busy)
    );

endmodule