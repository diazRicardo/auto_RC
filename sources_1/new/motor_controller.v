`timescale 1ns / 1ps


module motor_controller(
    input clk,
    input reset,
    input [15:0] distance_front,
    output [4:0] direction,
    output pwm_signal
    );
        
//    localparam FORWARD = 5'b00001;
//    localparam BACKWARD = 5'b00010;
//    localparam LEFT = 5'b00100;
//    localparam RIGHT = 5'b01000;
//    localparam STOP = 5'b10000;
    
    // Timer signals
    wire start_timer;   // output from motor_fsm, input to timer
    wire timer_expired; // output from timer, input to motor_fsm
    
    // Instantiate the timer with 50ms buffer
    timer #(
        .TIMER_COUNTS(16777215)   // 50ms at 125MHz
    ) direction_timer (
        .clk(clk),
        .reset(reset),
        .start(start_timer),
        .expired(timer_expired)
    );
 
    // Input for FSM
    wire obstacle;
    assign obstacle = (distance_front <= 16'd13);
    
    motors_fsm motor_machine (
        .clkin(clk),
        .reset(reset),
        .obstacle(obstacle),
        .timer_expire(timer_expired),
        .start_timer(start_timer),
        .direction(direction)
    );
    
endmodule
