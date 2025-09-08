`timescale 1ns / 1ps

module dual_motors(
    input wire clk_125mhz,
    input wire reset,
    input wire [4:0] direction,
    output reg [4:1] in
    );
    
    // 5-bit states
    localparam FORWARD = 5'b00001;
    localparam BACKWARD = 5'b00010;
    localparam LEFT = 5'b00100;
    localparam RIGHT = 5'b01000;
    localparam STOP = 5'b10000;
    
    //  Main motor control
    always @(posedge clk_125mhz) begin
        if (reset) begin
            in <= 0;
        end else begin
        
            case (direction)
                FORWARD: begin
                    in[1] <= 1;
                    in[2] <= 0;
                    in[3] <= 1;
                    in[4] <= 0;
                end
                
                BACKWARD: begin
                    in[1] <= 0;
                    in[2] <= 1;
                    in[3] <= 0;
                    in[4] <= 1;
                end
                
                STOP: begin
                    in <= 0;
                end
                
                LEFT: begin
                    in[1] <= 0;
                    in[2] <= 0;
                    in[3] <= 1;
                    in[4] <= 0;
                end
                
                RIGHT: begin
                    in[1] <= 1;
                    in[2] <= 0;
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
