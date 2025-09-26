`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module accelerator(
    input clk_1mhz,
    input reset,         
    input start,
    output reg accelerated,
    output reg accelerator_active,
    output reg pwm_signal
    );
    
    reg [13:0] onehundred_ms;
    reg [6:0] microseconds;
    reg start_prev;        // For edge detection of start input
    
    always @ (posedge clk_1mhz) begin
        if (reset) begin
            onehundred_ms <= 0;
            microseconds <= 0;
            accelerator_active <= 0;
            accelerated <= 0;
            pwm_signal <= 0;
            start_prev <= 0;
        end else begin
            start_prev <= start;
            
            // Start acceleration on rising edge of start signal
            if (start && !start_prev && !accelerator_active) begin
                accelerator_active <= 1;
                accelerated <= 0;
                onehundred_ms <= 0;
                microseconds <= 0;
                pwm_signal <= 1;
            end
            
            // Only run acceleration when module is active
            if (accelerator_active && !accelerated) begin
                
                // 25% power (0-250ms: counts 0 to 2499)
                if (onehundred_ms < 14'd2500) begin        
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;
                    
                    if (microseconds == 7'd24)  // 25% duty cycle
                        pwm_signal <= 0;
                    else if (microseconds == 7'd99) begin  // 100 microsecond period complete
                        pwm_signal <= 1;
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // 50% power (250-500ms: counts 2500 to 4999)
                end else if (onehundred_ms >= 14'd2500 && onehundred_ms < 14'd5000) begin
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;
                    
                    if (microseconds == 7'd49)  // 50% duty cycle
                        pwm_signal <= 0;
                    else if (microseconds == 7'd99) begin
                        pwm_signal <= 1;
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // 75% power (500-750ms: counts 5000 to 7499)
                end else if (onehundred_ms >= 14'd5000 && onehundred_ms < 14'd7500) begin
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;
                    
                    if (microseconds == 7'd74)  // 75% duty cycle
                        pwm_signal <= 0;
                    else if (microseconds == 7'd99) begin
                        pwm_signal <= 1;
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // 100% power (750-1000ms: counts 7500 to 9999)
                end else if (onehundred_ms >= 14'd7500 && onehundred_ms < 14'd10000) begin
                    microseconds <= microseconds + 1;
                    pwm_signal <= 1;  // 100% duty cycle ALWAYS HIGH
                    
                    if (microseconds == 7'd99) begin
                        onehundred_ms <= onehundred_ms + 1;
                        microseconds <= 0;
                    end
                    
                // Acceleration complete
                end else begin
                    pwm_signal <= 1;           // Keep at 100% power
                    accelerated <= 1;          // Signal completion
                    accelerator_active <= 0;   // Stop the accelerator
                end
            end
            
            // If not active, maintain current state or idle
            if (!accelerator_active && !accelerated) begin
                pwm_signal <= 0;  // No output when idle
            end
        end   
    end
    
endmodule
