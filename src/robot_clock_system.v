`timescale 1ns / 1ps


// Main clock system for HC-SR04 robot project
// For Zybo Z7 board with 125MHz input clock

module robot_clock_system(
    input wire clk_125mhz,      // 125MHz system clock (Zybo Z7)
    input wire reset,           // Active high reset
    output wire clk_1khz,       // 1kHz clock for general timing
    output wire clk_20hz,       // 20Hz clock for sensor sampling
    output wire clk_1mhz        // 1MHz clock for microsecond timing
);

    parameter CLOCK_FREQ = 125_000_000;  // 125MHz input clock
    
    // Clock divider instances
    clock_divider #(.INPUT_FREQ(CLOCK_FREQ), .OUTPUT_FREQ(1_000_000)) 
        div_1mhz (.clk_in(clk_125mhz), .reset(reset), .clk_out(clk_1mhz));
    
    clock_divider #(.INPUT_FREQ(CLOCK_FREQ), .OUTPUT_FREQ(1_000)) 
        div_1khz (.clk_in(clk_125mhz), .reset(reset), .clk_out(clk_1khz));
    
    clock_divider #(.INPUT_FREQ(CLOCK_FREQ), .OUTPUT_FREQ(20)) 
        div_20hz (.clk_in(clk_125mhz), .reset(reset), .clk_out(clk_20hz));

endmodule
