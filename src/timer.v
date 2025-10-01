`timescale 1ns / 1ps

module timer (
    input wire clk,
    input wire reset,
    input wire start,           // Pulse high to start timer
    output reg timer_active,
    output reg expired          // Goes high when timer expires
);

    // Timer parameters for 125MHz clock
    // For 100ms: 125,000,000 * 0.1 = 12,500,000 counts
    parameter TIMER_COUNTS = 12500000;  // 100ms at 125MHz
    
    // Counter needs to count up to 12,500,000
    // Use 24 bits (can count up to 16,777,215)
    reg [23:0] counter;
    reg timer_running;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            timer_running <= 0;
            expired <= 0;
        end else if (start && !timer_running) begin
            // Start timer
            counter <= 0;
            timer_running <= 1;
            expired <= 0;
        end else if (timer_running) begin
            if (counter == TIMER_COUNTS - 1) begin
                // Timer expired
                counter <= 0;
                timer_running <= 0;
                expired <= 1;
            end else begin
                counter <= counter + 1;
                expired <= 0;
            end
        end else begin
            expired <= 0;
        end
    end

endmodule