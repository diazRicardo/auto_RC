`timescale 1ns / 1ps

module dual_motors(
    input wire clk_125mhz,
    input wire reset,
    input wire [4:0] direction,
    output reg [4:1] in
    );
    
    // 5-bit states
    localparam FORWARD   = 5'b00001;  // State 0
    localparam IDLE      = 5'b00010;  // State 1  
    localparam BACKWARD  = 5'b00100;  // state 2
    localparam LEFT      = 5'b01000;  // state 3
    localparam RIGHT     = 5'b10000;  // State 4
    
    //  Main motor control
    always @(posedge clk_125mhz) begin
        if (reset) begin
            in <= 0;
        end else begin
        
            case (direction)
                FORWARD: begin
//                    in[1] <= 1;
//                    in[2] <= 0;
//                    in[3] <= 1;
//                    in[4] <= 0;
                    in[1] <= 0;
                    in[2] <= 1;
                    in[3] <= 0;
                    in[4] <= 1;
                end
                
                BACKWARD: begin
                    in[1] <= 1;
                    in[2] <= 0;
                    in[3] <= 1;
                    in[4] <= 0;
                end
                
                IDLE: begin
                    in <= 0;
                end
                
                LEFT: begin
                    in[1] <= 0;
                    in[2] <= 0;
                    in[3] <= 0;
                    in[4] <= 1;
                end
                
                RIGHT: begin
                    in[1] <= 0;
                    in[2] <= 1;
                    in[3] <= 0;
                    in[4] <= 0;
                end
                    
                default: begin
                    in <= 0;
                end
            endcase
        end
    end

    
endmodule
