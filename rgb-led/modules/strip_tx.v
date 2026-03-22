module strip_tx#(
    parameter NUM_LEDS = 5
)(
    input wire clk,
    input wire start,
    input wire [NUM_LEDS*24-1:0] mem_flat,
    output wire tx,
    output reg strip_busy
);

    reg [2:0] strip_state;
    reg [NUM_LEDS-1:0] led_index;
    reg [23:0] led_data;
    reg led_start;
    
    reg [15:0] gap_counter;
    localparam GAP_T = 1700;

    wire led_busy;
    wire led_tx_out;

    led_tx led1 (
        .clk(clk),
        .start(led_start),
        .data(led_data),
        .tx(led_tx_out),
        .busy(led_busy)
    );

    localparam INIT = 3'd0;
    localparam LOAD = 3'd1;
    localparam SENDING_BYTE = 3'd2;
    localparam NEXT_BYTE = 3'd3;
    localparam GAP = 3'd4;

    assign tx = (strip_state == GAP) ? 1'b0 : led_tx_out;

    always @(posedge clk) begin
        led_start <= 0;
        case (strip_state)
            INIT: begin 
                if (start) begin
                    led_index <= 0;
                    gap_counter <= 0;
                    strip_busy <= 1;
                    strip_state <= LOAD;                    
                end else begin
                    strip_state <= INIT;
                    strip_busy <= 0;
                end
            end

            LOAD: begin 
                led_data <= mem_flat[led_index*24 +: 24];
                led_start <= 1;
                if(led_busy) strip_state <= SENDING_BYTE;
                else strip_state <= LOAD;
            end

            SENDING_BYTE: begin
                if (!led_busy) begin
                    strip_state <= NEXT_BYTE;
                end else begin
                    strip_state <= SENDING_BYTE;
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
                if(gap_counter >= GAP_T) begin
                    gap_counter <= 1'b0;
                    strip_state <= INIT;
                end else begin
                    gap_counter <= gap_counter + 1;
                end
            end

            default: strip_state <= INIT;
        endcase        
    end
endmodule
