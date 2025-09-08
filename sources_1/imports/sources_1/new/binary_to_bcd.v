`timescale 1ns / 1ps

module binary_to_bcd #(parameter BITS = 14) (
    input [BITS-1:0] binary,
    output reg [3:0] digit0, digit1, digit2, digit3
);
    integer i;
    reg [27:0] shift_reg;

    always @(*) begin
        shift_reg = 28'd0;
        shift_reg[BITS-1:0] = binary;

        for (i = 0; i < BITS; i = i + 1) begin
            if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
            if (shift_reg[23:20] >= 5) shift_reg[23:20] = shift_reg[23:20] + 3;
            if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 3;
            shift_reg = shift_reg << 1;
        end

        digit3 = shift_reg[27:24];
        digit2 = shift_reg[23:20];
        digit1 = shift_reg[19:16];
        digit0 = shift_reg[15:12];
    end
endmodule
