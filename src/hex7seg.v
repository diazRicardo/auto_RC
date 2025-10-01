`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 04:45:44 PM
// Design Name: 
// Module Name: hex7seg
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



//module hex7seg(
//    input [3:0] n,
//    output [6:0] seg
//    );
    
//    assign seg[0] = (~n[3]&~n[2]&~n[1]&~n[0]) | (~n[3]&~n[2]&n[1]&~n[0]);
                    
//    assign seg[1] = (~n[3]&~n[2]&~n[1]&~n[0]) | (~n[3]&~n[2]&~n[1]&n[0]) | (~n[3]&~n[2]&n[1]&~n[0]);
                   
                    
                    
//    assign seg[2] = (~n[3]&~n[2]&~n[1]&~n[0]) | (~n[3]&~n[2]&~n[1]&n[0]);
                    
//    assign seg[3] =(~n[3]&~n[2]&~n[1]&~n[0]) | (~n[3]&~n[2]&n[1]&~n[0]);
                   
               
                 
//    assign seg[4] = (~n[3]&~n[2]&~n[1]&~n[0]) | (~n[3]&~n[2]&n[1]&~n[0]);
                    
                   
                    
//    assign seg[5] = (~n[3]&~n[2]&~n[1]&~n[0]);
                     
                                   
//    assign seg[6] = (~n[3]&~n[2]&n[1]&~n[0]);
                                
         

//endmodule

//module hex7seg(
//    input [3:0] n,
//    output reg [6:0] seg
//    );

//    // 7-segment display encoding (active low)
//    // seg[6:0] = {g, f, e, d, c, b, a}
//    //     aaa
//    //    f   b
//    //    f   b
//    //     ggg
//    //    e   c
//    //    e   c
//    //     ddd

//    always @(*) begin
//        case(n)
//            4'h0: seg = 7'b1000000; // 0
//            4'h1: seg = 7'b1111001; // 1
//            4'h2: seg = 7'b0100100; // 2
//            4'h3: seg = 7'b0110000; // 3
//            4'h4: seg = 7'b0011001; // 4
//            4'h5: seg = 7'b0010010; // 5
//            4'h6: seg = 7'b0000010; // 6
//            4'h7: seg = 7'b1111000; // 7
//            4'h8: seg = 7'b0000000; // 8
//            4'h9: seg = 7'b0010000; // 9
//            4'hA: seg = 7'b0001000; // A
//            4'hB: seg = 7'b0000011; // b
//            4'hC: seg = 7'b1000110; // C
//            4'hD: seg = 7'b0100001; // d
//            4'hE: seg = 7'b0000110; // E
//            4'hF: seg = 7'b0001110; // F
//            default: seg = 7'b1111111; // All off
//        endcase
//    end

//endmodule

module hex7seg(
    input [3:0] n,
    output reg [6:0] seg
    );

    // 7-segment display encoding (active HIGH for common anode)
    // seg[6:0] = {g, f, e, d, c, b, a}

    always @(*) begin
        case(n)
            4'h0: seg = 7'b0111111; // 0
            4'h1: seg = 7'b0000110; // 1
            4'h2: seg = 7'b1011011; // 2
            4'h3: seg = 7'b1001111; // 3
            4'h4: seg = 7'b1100110; // 4
            4'h5: seg = 7'b1101101; // 5
            4'h6: seg = 7'b1111101; // 6
            4'h7: seg = 7'b0000111; // 7
            4'h8: seg = 7'b1111111; // 8
            4'h9: seg = 7'b1101111; // 9
            4'hA: seg = 7'b1110111; // A
            4'hB: seg = 7'b1111100; // b
            4'hC: seg = 7'b0111001; // C
            4'hD: seg = 7'b1011110; // d
            4'hE: seg = 7'b1111001; // E
            4'hF: seg = 7'b1110001; // F
            default: seg = 7'b0000000; // All off
        endcase
    end
    //

endmodule