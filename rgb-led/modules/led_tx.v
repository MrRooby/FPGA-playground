// Clock for tang nano 9k == 27MHz == 37ns na cykl

module led_tx#(
    parameter CLK_FREQ = 27_000_000,   // Hz

    // Timing in clock cycles
    parameter T_HIGH_1 = 22,  // e.g. 0.80us
    parameter T_LOW_1  = 12,  // e.g. 0.45us

    parameter T_HIGH_0 = 11,  // e.g. 0.4us
    parameter T_LOW_0  = 23  // e.g. 0.85us

)(                              // but there were some mistakes below 1700
    input wire clk,
    input wire start,
    input wire [23:0] data,
    output reg tx,
    output reg busy
);
    reg [15:0] counter;
    reg [4:0] bit_index;
    reg [23:0] shift_reg;
    reg [2:0] led_state;

    localparam IDLE      = 0;
    localparam LOAD      = 1;
    localparam SEND_HIGH = 2;
    localparam SEND_LOW  = 3;
    localparam NEXT_BIT  = 4;

    always @(posedge clk) begin
        case (led_state)
            IDLE: begin
                tx <= 1'b0;
                busy <= 1'b0;
                counter <= 16'b0;

                if (start) begin
                    led_state <= LOAD;
                end else led_state <= IDLE;
            end
            
            LOAD: begin
                shift_reg <= data;
                bit_index <= 23;
                busy <= 1;
                led_state <= SEND_HIGH;
                counter <= 0;
            end

            SEND_HIGH: begin
                tx <= 1;

                if (shift_reg[bit_index]) begin
                    if (counter >= T_HIGH_1) begin
                        counter <= 0;
                        led_state <= SEND_LOW;
                    end else counter <= counter + 1;
                end else begin
                    if (counter >= T_HIGH_0) begin
                        counter <= 0;
                        led_state <= SEND_LOW;
                    end else counter <= counter + 1;
                end
            end

            SEND_LOW: begin
                tx <= 0;
                if (shift_reg[bit_index]) begin
                    if (counter >= T_LOW_1) begin
                        counter <= 0;
                        led_state <= NEXT_BIT;
                    end else counter <= counter + 1;
                end else begin
                    if (counter >= T_LOW_0) begin
                        counter <= 0;
                        led_state <= NEXT_BIT;
                    end else counter <= counter + 1;
                end
            end

            NEXT_BIT: begin
                if (bit_index == 0) begin
                    led_state <= IDLE;
                end else begin
                    bit_index <= bit_index - 1;
                    led_state <= SEND_HIGH;
                end
            end

            default: led_state <= IDLE;
        endcase
    end
endmodule
