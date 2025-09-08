`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2025 10:44:48 PM
// Design Name: 
// Module Name: sev_seg_display
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


module sev_seg_display(
    input clk,                    // 125 MHz system clock
    input [13:0] value_in,        // 14-bit input value to display
    output [6:0] seg,
    output [3:0] anode
);
    wire slow_clk;
    seg_clock_divider #(.DIVIDE_BY(25000)) clkdiv (
        .clk_in(clk),
        .clk_out(slow_clk)
    );

    // Convert binary to 4 BCD digits
    wire [3:0] d0, d1, d2, d3;
    binary_to_bcd #(14) bcd_conv (
        .binary(value_in),
        .digit0(d0), .digit1(d1), .digit2(d2), .digit3(d3)
    );

    seven_seg_driver display (
        .clk(slow_clk),
        .digit0(d0), .digit1(d1), .digit2(d2), .digit3(d3),
        .seg(seg),
        .anode(anode)
    );
endmodule
