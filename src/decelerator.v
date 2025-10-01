`timescale 1ns / 1ps

module decelerator(
    input  wire clk_1mhz,
    input  wire reset,         
    input  wire start,             // latched high until decel done
    output reg  decelerated,
    output reg  decelerator_active,
    output reg  pwm_signal
    );
    
    reg [13:0] onehundred_ms;
    reg [6:0]  microseconds;
    
    initial begin
        onehundred_ms = 0;
        microseconds = 0;
        decelerator_active = 0;
        decelerated = 0;
        pwm_signal = 0;
    end
    
    always @(posedge clk_1mhz) begin
        if (reset) begin
            onehundred_ms       <= 0;
            microseconds        <= 0;
            decelerator_active  <= 0;
            decelerated         <= 0;
            pwm_signal          <= 0;
        end else begin
            // Start when start=1 and module is idle
            if (start && !decelerator_active && !decelerated) begin
                decelerator_active <= 1;
                decelerated        <= 0;
                onehundred_ms      <= 0;
                microseconds       <= 0;
                pwm_signal         <= 1;
            end

            // Run deceleration sequence
            if (decelerator_active && !decelerated) begin
                
                // 75% duty (0-333 ms)
                if (onehundred_ms < 14'd3333) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= (microseconds < 7'd75);
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // 50% duty (333-666 ms)
                end else if (onehundred_ms < 14'd6666) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= (microseconds < 7'd50);
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // 25% duty (666-999 ms)
                end else if (onehundred_ms < 14'd9999) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= (microseconds < 7'd25);
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // Done - turn off PWM cleanly
                end else begin
                    pwm_signal         <= 0;  // Turn off PWM when done
                    decelerated        <= 1;
                    decelerator_active <= 0;
                end
            end

            // Idle state: ensure PWM is off when not running
            if (!decelerator_active && !start)
                pwm_signal <= 0;
        end
    end
endmodule
