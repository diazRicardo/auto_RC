`timescale 1ns / 1ps

module seven_seg_driver (
    input clk,                          // Clock: ~2.5 kHz from divider
    input [3:0] digit0, digit1, digit2, digit3, // BCD digits
    output reg [6:0] seg,               // Segments A–G (active high)
    output reg [3:0] anode              // Digit select (active low)
);
    reg [1:0] digit_sel = 0;
    reg [3:0] current_digit;

    // Digit multiplexer
    always @(posedge clk) begin
        digit_sel <= digit_sel + 1;

        case (digit_sel)
            2'd0: begin
                anode <= 4'b1110;
                current_digit <= digit0;
            end
            2'd1: begin
                anode <= 4'b1101;
                current_digit <= digit1;
            end
            2'd2: begin
                anode <= 4'b1011;
                current_digit <= digit2;
            end
            2'd3: begin
                anode <= 4'b0111;
                current_digit <= digit3;
            end
        endcase
    end

    // BCD to 7-segment decoder
    always @(*) begin
        case (current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // blank
        endcase
    end
endmodule

