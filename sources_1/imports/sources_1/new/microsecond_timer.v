`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2025 10:26:36 PM
// Design Name: 
// Module Name: microsecond_timer
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



// Microsecond timer for precise timing (useful for HC-SR04)
module microsecond_timer(
    input wire clk_1mhz,        // 1MHz clock (1?s period)
    input wire reset,
    input wire start,           // Start timing
    input wire stop,            // Stop timing
    output reg [15:0] time_us,  // Time in microseconds
    output reg timing_active    // High when timing is active
);

    always @(posedge clk_1mhz or posedge reset) begin
        if (reset) begin
            time_us <= 0;
            timing_active <= 0;
        end else begin
            if (start && !timing_active) begin
                time_us <= 0;
                timing_active <= 1;
            end else if (stop) begin
                timing_active <= 0;
            end else if (timing_active) begin
                time_us <= time_us + 1;
            end
        end
    end
endmodule
