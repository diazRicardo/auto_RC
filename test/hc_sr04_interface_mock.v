`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2025 12:42:27 AM
// Design Name: 
// Module Name: hc_sr04_interface_mock
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


// hc_sr04_interface_mock.v
module hc_sr04_interface (
    input  clk_125mhz,
    input  clk_1mhz,
    input  clk_20hz,
    input  reset,
    input  echo,
    output trig,
    output reg [15:0] distance_cm,
    output reg measurement_ready
);

    assign trig = 1'b0;

    initial begin
        distance_cm = 16'd100;
        measurement_ready = 1'b0;
    end

    task set_distance(input [15:0] cm);
        begin
            distance_cm = cm;
            measurement_ready = 1'b1;
            #10;
            measurement_ready = 1'b0;
        end
    endtask

endmodule
