`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// MEALY STATE MACHINE 
// Controls the directions of the motors based on timer expire and obstacle inputs
// Directions: FORWARD, BACKWARD, LEFT, RIGHT, IDLE (STOP)

module motors_fsm(
    input clkin,
    input reset,
    input obstacle,
    input timer_expire,
    output reg start_timer,
    output reg [4:0] direction  // direction == current state
    );
    
    // State definitions (one-hot encoding)
    localparam FORWARD   = 5'b00001;  // State 0
    localparam IDLE      = 5'b00010;  // State 1  
    localparam BACKWARD  = 5'b00100;  // state 2
    localparam LEFT      = 5'b01000;  // state 3
    localparam RIGHT     = 5'b10000;  // State 4
    
    reg [4:0] current_state, next_state;
    
    // State register
    always @(posedge clkin) begin
        if (reset)
            current_state <= FORWARD;  // Start in FORWARD state, this is our default state
        else
            current_state <= next_state;
    end
    
    // Next state logic
    always @(*) begin
        case (current_state)
            FORWARD: begin
                if (obstacle)
                    next_state = IDLE;
                else
                    next_state = FORWARD;
            end
            
            IDLE: begin
                if (obstacle && timer_expire)
                    next_state = RIGHT;
                else if (~obstacle)
                    next_state = FORWARD;
                else
                    next_state = IDLE;
            end
            
            RIGHT: begin
                if (~obstacle)
                    next_state = FORWARD;
                else
                    next_state = RIGHT;
            end
            
            default: next_state = FORWARD;
        endcase
    end
    
    // Output logic
    always @(*) begin
        start_timer = (current_state == FORWARD) && obstacle;
        direction = current_state;
    end
        
endmodule
