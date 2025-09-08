`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2025 12:25:23 PM
// Design Name: 
// Module Name: mux
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

module mux(

    input [3:0] A_i,
    input [3:0] B_i,
    input Sel_i,
    output [3:0] Y_o
    );
    
    // when Sel_i is HIGH, B is passed through
    assign Y_o = (A_i & {4{~Sel_i}}) | (B_i & {4{Sel_i}});
endmodule
