`timescale 1ns / 1ps

module dual_motors(
    input wire clk_125mhz,
    input wire reset,
    input wire [6:0] direction,
    input wire pwm_signal,
    output reg [4:1] in,
    output reg enA,
    output reg enB
    );
    
    // State definitions (one-hot encoding)
    localparam FORWARD   = 7'b0000001;  // State 0
    localparam IDLE      = 7'b0000010;  // State 1  
    localparam BACKWARD  = 7'b0000100;  // state 2
    localparam LEFT      = 7'b0001000;  // state 3
    localparam RIGHT     = 7'b0010000;  // State 4
    localparam ACC       = 7'b0100000;  // State 5
    localparam DEC       = 7'b1000000;  // State 6
    
    //  Main motor control
    always @(posedge clk_125mhz) begin
        if (reset) begin
            in <= 0;
        end else begin
        
            case (direction)
                ACC: begin
                    enA <= pwm_signal;
                    enB <= pwm_signal;
                    in[1] <= 0;
                    in[2] <= 1;
                    in[3] <= 0;
                    in[4] <= 1;
                end 
                
                DEC: begin
                    enA <= pwm_signal;
                    enB <= pwm_signal;
                    in[1] <= 1;
                    in[2] <= 0;
                    in[3] <= 1;
                    in[4] <= 0;
                end 
                
                FORWARD: begin
//                    in[1] <= 1;
//                    in[2] <= 0;
//                    in[3] <= 1;
//                    in[4] <= 0;
                    enA <= 1;
                    enB <= 1;
                    in[1] <= 0;
                    in[2] <= 1;
                    in[3] <= 0;
                    in[4] <= 1;
                end
                
                BACKWARD: begin
                    enA <= 1;
                    enB <= 1;
                    in[1] <= 1;
                    in[2] <= 0;
                    in[3] <= 1;
                    in[4] <= 0;
                end
                
                IDLE: begin
                    enA <= 0;
                    enB <= 0;
                    in <= 0;
                end
                
                LEFT: begin
                    enA <= 0;
                    enB <= 1;
                    in[1] <= 0;
                    in[2] <= 0;
                    in[3] <= 0;
                    in[4] <= 1;
                end
                
                RIGHT: begin
                    enA <= 1;
                    enB <= 0;
                    in[1] <= 0;
                    in[2] <= 1;
                    in[3] <= 0;
                    in[4] <= 0;
                end
                    
                default: begin
                    enA <= 0;
                    enB <= 0;
                    in <= 0;
                end
            endcase
        end
    end

    
endmodule
