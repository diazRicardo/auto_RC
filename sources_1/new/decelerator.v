`timescale 1ns / 1ps

module decelerator(
    input clk_1mhz,
    input reset,         
    input start,
    output reg decelerated,
    output reg decelerator_active,
    output reg pwm_signal
    );
    
    reg [13:0] onehundred_ms;
    reg [6:0] microseconds;
    reg start_prev;        // For edge detection of start input
    
    always @ (posedge clk_1mhz) begin
        if (reset) begin
            onehundred_ms <= 0;
            microseconds <= 0;
            decelerator_active <= 0;
            decelerated <= 0;
            pwm_signal <= 0;
            start_prev <= 0;
        end else begin
            start_prev <= start;
            
            // Start deceleration on rising edge of start signal
            if (start && !start_prev && !decelerator_active) begin
                decelerator_active <= 1;
                decelerated <= 0;
                onehundred_ms <= 0;
                microseconds <= 0;
                pwm_signal <= 1;
            end
            
            // Only run acceleration when module is active
            if (decelerator_active && !decelerated) begin
                
                // 75% power (0-333ms: counts 0 to 3333)
                if (onehundred_ms < 14'd3333) begin        
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;
                    
                    if (microseconds == 7'd74)  // 75% duty cycle
                        pwm_signal <= 0;
                    else if (microseconds == 7'd99) begin  // 100 microsecond period complete
                        pwm_signal <= 1;
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // 50% power (333-660ms: counts 3333 to 6666)
                end else if (onehundred_ms >= 14'd3333 && onehundred_ms < 14'd6666) begin
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;
                    
                    if (microseconds == 7'd49)  // 50% duty cycle
                        pwm_signal <= 0;
                    else if (microseconds == 7'd99) begin
                        pwm_signal <= 1;
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // 25% power (660-999ms: counts 6666 to 9999)
                end else if (onehundred_ms >= 14'd6666 && onehundred_ms < 14'd9999) begin
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;
                    
                    if (microseconds == 7'd24)  // 25% duty cycle
                        pwm_signal <= 0;
                    else if (microseconds == 7'd99) begin
                        pwm_signal <= 1;
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // Deceleration complete
                end else begin
                    pwm_signal <= 0;           // Keep at 0% power
                    decelerated <= 1;          // Signal completion
                    decelerator_active <= 0;   // Stop the decelerator
                end
            end
            
            // If not active, maintain current state or idle
            if (!decelerator_active && !decelerated) begin
                pwm_signal <= 0;  // No output when idle
            end
        end   
    end
    
endmodule
