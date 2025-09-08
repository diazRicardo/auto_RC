`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2025 11:38:53 PM
// Design Name: 
// Module Name: seg_clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module seg_clock_divider #(parameter DIVIDE_BY = 25000) (
    input clk_in,
    output reg clk_out = 0
);
    integer count = 0;
    
    always @(posedge clk_in) begin
        if (count >= (DIVIDE_BY/2 - 1)) begin
            clk_out <= ~clk_out;
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end
endmodule
