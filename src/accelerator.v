`timescale 1ns / 1ps

module accelerator(
    input  wire clk_1mhz,
    input  wire reset,         
    input  wire start,             // latched high until accel done
    output reg  accelerated,
    output reg  accelerator_active,
    output reg  pwm_signal
    );
    
    reg [13:0] onehundred_ms;
    reg [6:0]  microseconds;
    
    initial begin
        onehundred_ms = 0;
        microseconds = 0;
        accelerator_active = 0;
        accelerated = 0;
        pwm_signal = 0;
    end
    
    always @(posedge clk_1mhz) begin
        if (reset) begin
            onehundred_ms       <= 0;
            microseconds        <= 0;
            accelerator_active  <= 0;
            accelerated         <= 0;
            pwm_signal          <= 0;
        end else begin
            // Start when start=1 and module is idle
            if (start && !accelerator_active && !accelerated) begin
                accelerator_active <= 1;
                accelerated        <= 0;
                onehundred_ms      <= 0;
                microseconds       <= 0;
                pwm_signal         <= 1;
            end

            // Run acceleration sequence
            if (accelerator_active && !accelerated) begin
                
                // 25% duty (0-250 ms)
                if (onehundred_ms < 14'd2500) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= (microseconds < 7'd25);
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // 50% duty (250-500 ms)
                end else if (onehundred_ms < 14'd5000) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= (microseconds < 7'd50);
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // 75% duty (500-750 ms)
                end else if (onehundred_ms < 14'd7500) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= (microseconds < 7'd75);
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // 100% duty (750-1000 ms)
                end else if (onehundred_ms < 14'd10000) begin
                    microseconds <= microseconds + 1;
                    pwm_signal   <= 1;  // always high
                    if (microseconds == 7'd99) begin
                        microseconds  <= 0;
                        onehundred_ms <= onehundred_ms + 1;
                    end
                
                // Done
                end else begin
                    pwm_signal         <= 0;
                    accelerated        <= 1;
                    accelerator_active <= 0;
                end
            end

            // Idle state: ensure PWM is off when not running
            if (!accelerator_active && !start)
                pwm_signal <= 0;
        end
    end
endmodule
