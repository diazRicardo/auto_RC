`timescale 1ns / 1ps


module millisecond_timer(
    input wire clk_1khz,        // 1kHz clock 
    input wire reset,
    input wire start,           // Start timing
    input wire stop,            // Stop timing
    output reg [11:0] time_ms,  // Time in milliseconds, can count up to ~2000 ms 
    output reg timing_active    // High when timing is active
);

    always @ (posedge clk_1khz or posedge reset) begin
        if (reset) begin
            time_ms <= 0;
            timing_active <= 0;
        end else begin
            if (start && !timing_active) begin
                time_ms <= 0;
                timing_active <= 1;
            end else if (stop) begin
                timing_active <= 0;
            end else if (timing_active) begin
                time_ms <= time_ms + 1;
            end
        end
    end
    
endmodule
