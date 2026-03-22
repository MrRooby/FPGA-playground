module strip_tx#(
    parameter NUM_LEDS = 5
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [NUM_LEDS*24-1:0] mem_flat,
    output wire tx
);

    reg [2:0] strip_state;
    reg [NUM_LEDS-1:0] led_index;
    reg [23:0] led_data;
    reg gap_reg;
    reg led_start;
    reg busy_seen;

    wire led_busy;

    led_tx led1 (
        .clk(clk),
        .rst(rst),
        .start(led_start),
        .data(led_data),
        .gap(gap_reg),
        .tx(tx),
        .busy(led_busy)
    );

    localparam INIT = 3'd0;
    localparam IDLE = 3'd1;
    localparam LOAD = 3'd2;
    localparam BEGIN_SEND = 3'd3;
    localparam SEND_BYTE = 3'd4;
    localparam SENDING_BYTE = 3'd5;
    localparam NEXT_BYTE = 3'd6;
    localparam GAP = 3'd7;


    always @(posedge clk) begin
        if (rst) begin
            strip_state <= INIT;
            led_index <= 0;
            led_data <= 0;
            led_start <= 0;
            gap_reg <= 0;
            busy_seen <= 0;
        end else begin
            // start ledów ma trwać tylko 1 cylk zegara
            led_start <= 0;
            gap_reg <= 0;
            case (strip_state)
                INIT: begin 
                    if (start) begin
                        led_index <= 0;
                        strip_state <= LOAD;                    
                    end else begin
                        strip_state <= INIT;
                    end
                end

                IDLE: begin 
                    if (!led_busy) begin
                        strip_state <= SEND_BYTE;                    
                    end else begin
                        strip_state <= IDLE;
                    end
                end

                LOAD: begin 
                    led_data <= mem_flat[led_index*24 +: 24];
                    strip_state <= BEGIN_SEND;
                end

                BEGIN_SEND: begin 
                    led_start <= 1;
                    busy_seen <= 0;
                    strip_state <= SENDING_BYTE;
                end

                SENDING_BYTE: begin
                    if (!busy_seen) begin
                        // Wait for led_tx to actually assert busy
                        if (led_busy) busy_seen <= 1'b1;
                        strip_state <= SENDING_BYTE;
                    end else begin
                        // busy was seen high, now wait until transfer ends
                        if (!led_busy) begin
                            busy_seen <= 1'b0;
                            strip_state <= NEXT_BYTE;
                        end else begin
                            strip_state <= SENDING_BYTE;
                        end
                    end
                end

                NEXT_BYTE: begin 
                    if(led_index == NUM_LEDS-1) begin
                        strip_state <= GAP;
                    end else begin
                        led_index <= led_index + 1;
                        strip_state <= LOAD;
                    end
                end

                GAP: begin 
                    if(!led_busy) begin
                        gap_reg <= 1;
                        strip_state <= INIT;
                    end
                end

                default: strip_state <= INIT;
            endcase        
        end
    end
endmodule
