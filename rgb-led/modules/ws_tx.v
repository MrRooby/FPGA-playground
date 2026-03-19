// Clock for tang nano 9k == 27MHz == 37ns na cykl

module ws_tx#(
    parameter CLK_FREQ = 27_000_000,   // Hz

    // Timing in clock cycles
    parameter T_HIGH_1 = 22,  // e.g. 0.80us
    parameter T_LOW_1  = 12,  // e.g. 0.45us

    parameter T_HIGH_0 = 11,  // e.g. 0.4us
    parameter T_LOW_0  = 23,  // e.g. 0.85us

    parameter T_GAP    = 1700   // gap between frames above 50us which comes up to around 1400 
)(                              // but there were some mistakes below 1700
    input wire clk,
    input wire start,
    input wire gap,
    input wire [23:0] data,
    output reg tx,
    output reg busy
);
    reg [15:0] counter;
    reg [4:0] bit_index;
    reg [23:0] shift_reg;

    reg [2:0] state;

    localparam IDLE      = 0;
    localparam LOAD      = 1;
    localparam SEND_HIGH = 2;
    localparam SEND_LOW  = 3;
    localparam NEXT_BIT  = 4;
    localparam GAP       = 5;

    reg current_bit;

    always @(posedge gap) begin
        state <= GAP;
        busy <= 1;
    end

    always @(posedge clk) begin
            case (state)

                IDLE: begin
                    tx <= 0;
                    busy <= 0;
                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    shift_reg <= data;
                    bit_index <= 23;
                    busy <= 1;
                    state <= SEND_HIGH;
                    counter <= 0;
                end

                SEND_HIGH: begin
                    tx <= 1;
                    current_bit <= shift_reg[bit_index];

                    if (current_bit) begin
                        if (counter >= T_HIGH_1) begin
                            counter <= 0;
                            state <= SEND_LOW;
                        end else counter <= counter + 1;
                    end else begin
                        if (counter >= T_HIGH_0) begin
                            counter <= 0;
                            state <= SEND_LOW;
                        end else counter <= counter + 1;
                    end
                end

                SEND_LOW: begin
                    tx <= 0;

                    if (current_bit) begin
                        if (counter >= T_LOW_1) begin
                            counter <= 0;
                            state <= NEXT_BIT;
                        end else counter <= counter + 1;
                    end else begin
                        if (counter >= T_LOW_0) begin
                            counter <= 0;
                            state <= NEXT_BIT;
                        end else counter <= counter + 1;
                    end
                end

                NEXT_BIT: begin
                    if (bit_index == 0) begin
                        state <= IDLE;
                    end else begin
                        bit_index <= bit_index - 1;
                        state <= SEND_HIGH;
                    end
                end

                GAP: begin
                    tx <= 0;
                    if(counter >= T_GAP) begin
                       counter <= 0; 
                       state <= IDLE;
                    end else
                       counter <= counter + 1; 
                end

                default: state <= IDLE;

            endcase
    end

endmodule

module fifo #(
    parameter NUM_LEDS = 5
)(
    input wire clk,
    input wire start,
    output reg busy,
    output reg tx
);

    reg [23:0] mem [0:NUM_LEDS-1];
    reg [2:0] state;
    reg [NUM_LEDS-1:0] led_index;
    reg [23:0] led_data;
    reg gap;

    ws_tx strip1 (
        .clk(clk),
        .start(start),
        .data(led_data),
        .tx(tx),
        .busy(busy),
        .gap(gap)
    );


    localparam INIT = 0;
    localparam IDLE = 1;
    localparam SEND_BYTE = 2;
    localparam NEXT_BYTE = 3;
    localparam GAP = 4;

    always @(posedge clk) begin
        case (state)
            INIT: begin 
                if (start) begin
                    led_index <= 0;
                    state <= SEND_BYTE;                    
                end
            end

            IDLE: begin 
                if (!busy) begin
                    state <= SEND_BYTE;                    
                end
            end

            SEND_BYTE: begin 
                if(!busy) begin
                    led_data <= mem[led_index];
                    state <= NEXT_BYTE;
                end else state <= IDLE;
            end

            NEXT_BYTE: begin 
                if(led_index >= NUM_LEDS-1) begin
                    state <= GAP;
                    led_index <= 0;
                end else begin
                    led_index <= led_index + 1;
                    state <= SEND_BYTE;
                end
            end

            GAP: begin 
                if(!busy) begin
                    gap <= 1;
                    state <= INIT;
                end
            end
            default: state <= IDLE;
        endcase
        
    end
endmodule
