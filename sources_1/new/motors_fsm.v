`timescale 1ns / 1ps


// MEALY STATE MACHINE 
// Controls the directions of the motors based on timer expire and obstacle inputs
// Directions: FORWARD, BACKWARD, LEFT, RIGHT, IDLE (STOP)

module motors_fsm(
    input clkin,
    input reset,
    input obstacle,             // Four inputs
    input timer_expire,
    input accelerated,
    input decelerated,
    output reg start_timer,     // Two outputs, along with current state (direction)
    output reg start_milli_timer,
    output reg [6:0] direction  
    );
    
    // State definitions (one-hot encoding)
    localparam FORWARD   = 7'b0000001;  // State 0
    localparam IDLE      = 7'b0000010;  // State 1  
    localparam BACKWARD  = 7'b0000100;  // state 2
    localparam LEFT      = 7'b0001000;  // state 3
    localparam RIGHT     = 7'b0010000;  // State 4
    localparam ACC       = 7'b0100000;  // State 5
    localparam DEC       = 7'b1000000;  // State 6
    
    reg [6:0] current_state, next_state;
    
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
            ACC: begin
                if (~obstacle && accelerated)
                    next_state = FORWARD;
                else if (obstacle)
                    next_state = DEC;
                 else
                    next_state = ACC;
            end
            
            FORWARD: begin
                if (obstacle)
                    next_state = DEC;
                else
                    next_state = FORWARD;
            end
            
            IDLE: begin
                if (obstacle && timer_expire)
                    next_state = RIGHT;
                else if (~obstacle && timer_expire)
                    next_state = ACC;
                else
                    next_state = IDLE;
            end
            
            DEC: begin
                if (decelerated)
                    next_state = IDLE;
                else
                    next_state = DEC;
            end
            
            RIGHT: begin
                if (~obstacle)
                    next_state = IDLE;
                else
                    next_state = RIGHT;
            end
            
            default: next_state = FORWARD;
        endcase
    end
    
    // Output logic
    always @(*) begin
        start_timer = ((current_state == RIGHT) && ~obstacle) |
                      (current_state == DEC) && decelerated;
        start_milli_timer = ((current_state == ACC) && obstacle) |
                            ((current_state == FORWARD) && obstacle) |
                            ((current_state == IDLE) && ~obstacle && timer_expire);
        direction = current_state;
    end
        
endmodule
