`timescale 1ns / 1ps



// Generic clock divider module
module clock_divider #(
    parameter INPUT_FREQ = 50_000_000,
    parameter OUTPUT_FREQ = 1_000_000
)(
    input wire clk_in,
    input wire reset,
    output reg clk_out
);

    localparam DIVIDE_VALUE = INPUT_FREQ / (2 * OUTPUT_FREQ);
    localparam COUNTER_BITS = $clog2(DIVIDE_VALUE);
    
    reg [COUNTER_BITS-1:0] counter;
    
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == DIVIDE_VALUE - 1) begin
                counter <= 0;
                clk_out <= ~clk_out;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
