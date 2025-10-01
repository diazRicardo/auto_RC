`timescale 1ns / 1ps

// HC-SR04 Interface Module 
module hc_sr04_interface(
    input wire clk_125mhz,      // System clock (Zybo Z7)
    input wire clk_1mhz,        // 1MHz for microsecond timing
    input wire clk_20hz,        // 20Hz for sampling rate
    input wire reset,
    input wire echo,            // Echo pin from HC-SR04
    output reg trig,            // Trigger pin to HC-SR04
    output reg [15:0] distance_cm,  // Distance in cm
    output reg measurement_ready    // Pulse when new measurement ready
);

    // States for HC-SR04 interface
    localparam IDLE = 2'b00;
    localparam TRIGGER = 2'b01;
    localparam WAIT_ECHO = 2'b10;
    localparam MEASURE = 2'b11;
    
    reg [1:0] state;
    reg [11:0] trigger_counter;     // Count trigger pulse duration
    reg [23:0] echo_timeout_counter;        // Count echo time (larger for proper timeout)
    
    // Edge detection - moved to same clock domain as state machine
    reg echo_prev;
    always @(posedge clk_125mhz) begin
        if (reset) begin
            echo_prev <= 0;
        end else begin
            echo_prev <= echo;
        end
    end
    
    wire echo_rising = echo && !echo_prev;
    wire echo_falling = !echo && echo_prev;
    
    // Sample trigger from 20Hz clock
    reg clk_20hz_prev;
    always @(posedge clk_125mhz) begin
        if (reset) begin
            clk_20hz_prev <= 0;
        end else begin
            clk_20hz_prev <= clk_20hz;
        end
    end
    wire sample_trigger = clk_20hz && !clk_20hz_prev;
    
    // Main state machine
    always @(posedge clk_125mhz) begin
        if (reset) begin
            state <= IDLE;
            trig <= 0;
            trigger_counter <= 0;
            distance_cm <= 0;
            measurement_ready <= 0;
            echo_timeout_counter <= 0;
        end else begin
            measurement_ready <= 0;  // Default to 0, pulse high when ready
            
            case (state)
                IDLE: begin
                    trig <= 0;
                    trigger_counter <= 0;
                    echo_timeout_counter <= 0;
                    if (sample_trigger) begin
                        state <= TRIGGER;
                    end
                end
                
                TRIGGER: begin
                    // 10 micro second trigger pulse at 125MHz = 1250 cycles
                    if (trigger_counter >= 1249) begin  // 10?s at 125MHz
                        trig <= 0;
                        state <= WAIT_ECHO;
                        trigger_counter <= 0;
                    end else begin
                        trig <= 1;
                        trigger_counter <= trigger_counter + 1;
                    end
                end
                // Here, we wait for an echo signal from the HC-SR04
                // Watchdog: if we wait 30ms with no echo signal, then enter a timeout and return to IDLE state
                WAIT_ECHO: begin
                    trig <= 0;
                    if (echo_rising) begin
                        state <= MEASURE;
                        echo_timeout_counter <= 0;
                    end
                    // Timeout: 30ms at 125MHz = 3,750,000 cycles
                    else if (echo_timeout_counter >= 3750000) begin
                        distance_cm <= 16'hFFFF;  // Error value
                        measurement_ready <= 1;
                        state <= IDLE;
                    end else begin
                        echo_timeout_counter <= echo_timeout_counter + 1;
                    end
                end
                
                MEASURE: begin
                    trig <= 0;
                    echo_timeout_counter <= echo_timeout_counter + 1;
                    
                    if (echo_falling) begin
                        // Simplified distance calculation
                        // At 125MHz: 1 cycle = 8ns
                        // Sound travels ~343 m/s = 0.0343 cm/microseconds
                        // Distance = (time * 0.0343) / 2 = time * 0.01715
                        // time_microseconds = echo_timeout_counter * 8ns = echo_timeout_counter / 125
                        // distance = (echo_timeout_counter / 125) * 0.01715 ? echo_timeout_counter / 7290
                        // Use bit shift for simpler division: echo_timeout_counter >> 13 ? echo_timeout_counter / 8192
                        distance_cm <= echo_timeout_counter >> 13;  // Approximate division
                        measurement_ready <= 1;
                        state <= IDLE;
                    end 
                    // Timeout after 30ms
                    else if (echo_timeout_counter >= 3750000) begin
                        distance_cm <= 16'hFFFF;  // Error value
                        measurement_ready <= 1;
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                    trig <= 0;
                end
            endcase
        end
    end

endmodule