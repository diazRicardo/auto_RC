`timescale 1ns / 1ps

module motor_controller(
    input clk,
    input clk_1mhz,
    input reset,
    input [15:0] distance_front,
    output [6:0] direction,
    output idle_timer_active,
    output pwm_signal
    );

    // -----------------------
    // Timer for IDLE delays
    // -----------------------
    wire start_timer;   // output from motor_fsm, input to timer
    wire timer_expired; // output from timer, input to motor_fsm
    
    // Instantiate the timer with 50ms buffer
    timer #(
        .TIMER_COUNTS(16777215)   // 50ms at 125MHz 
    ) direction_timer (
        .clk(clk),
        .reset(reset),
        .start(start_timer),
        .timer_active(idle_timer_active),
        .expired(timer_expired)
    );
    
    // -----------------------
    // Accelerator wiring
    // -----------------------
    wire acc_pwm_signal;
    wire start_acc_pulse, accelerated, acc_active;
    
    // Synchronize accelerated feedback from 1 MHz to 125 MHz domain
    reg [1:0] accelerated_sync;
    always @(posedge clk) begin
        if (reset)
            accelerated_sync <= 2'b00;
        else
            accelerated_sync <= {accelerated_sync[0], accelerated};
    end
    wire accelerated_125mhz = accelerated_sync[1];
    
    // Synchronize pulse into 125 MHz domain first
    reg [1:0] start_acc_sync;
    always @(posedge clk) begin
        if (reset)
            start_acc_sync <= 2'b00;
        else
            start_acc_sync <= {start_acc_sync[0], start_acc_pulse};
    end
    wire start_acc_125mhz = start_acc_sync[1];

    // Latch on 125 MHz domain, use synchronized feedback
    reg start_acc_latched_125;
    always @(posedge clk) begin
        if (reset)
            start_acc_latched_125 <= 1'b0;
        else if (start_acc_125mhz)
            start_acc_latched_125 <= 1'b1;     // latch request
        else if (accelerated_125mhz)
            start_acc_latched_125 <= 1'b0;     // clear once finished (synchronized)
    end
    
    // NOW synchronize the latched signal into 1 MHz domain
    reg [1:0] start_acc_1mhz_sync;
    always @(posedge clk_1mhz) begin
        if (reset)
            start_acc_1mhz_sync <= 2'b00;
        else
            start_acc_1mhz_sync <= {start_acc_1mhz_sync[0], start_acc_latched_125};
    end
    wire start_acc_latched = start_acc_1mhz_sync[1];  // Use this for accelerator
    
    accelerator acc (
        .clk_1mhz(clk_1mhz),
        .reset(reset),
        .start(start_acc_latched),
        .accelerated(accelerated),
        .accelerator_active(acc_active),
        .pwm_signal(acc_pwm_signal)
        );
    
    // -----------------------
    // Decelerator wiring
    // -----------------------
    wire dec_pwm_signal;
    wire start_dec_pulse;     // from FSM (125 MHz pulse)
    wire start_dec, decelerated, dec_active;
    
    // Synchronize 'decelerated' feedback from 1 MHz to 125 MHz domain
    reg [1:0] decelerated_sync;
    always @(posedge clk) begin
        if (reset)
            decelerated_sync <= 2'b00;
        else
            decelerated_sync <= {decelerated_sync[0], decelerated};
    end
    wire decelerated_125mhz = decelerated_sync[1];
    
    // Synchronize pulse into 125 MHz domain
    reg [1:0] start_dec_sync_125;
    always @(posedge clk) begin
        if (reset)
            start_dec_sync_125 <= 2'b00;
        else
            start_dec_sync_125 <= {start_dec_sync_125[0], start_dec_pulse};
    end
    wire start_dec_125mhz = start_dec_sync_125[1];
    
    // Latch on 125 MHz domain
    reg start_dec_latched_125;
    always @(posedge clk) begin
        if (reset)
            start_dec_latched_125 <= 1'b0;
        else if (start_dec_125mhz)
            start_dec_latched_125 <= 1'b1;     // latch request
        else if (decelerated_125mhz)
            start_dec_latched_125 <= 1'b0;     // clear once finished (synchronized)
    end
    
    // Synchronize into 1 MHz domain
    reg [1:0] start_dec_sync;
    always @(posedge clk_1mhz) begin
        if (reset)
            start_dec_sync <= 2'b00;
        else
            start_dec_sync <= {start_dec_sync[0], start_dec_latched_125};
    end
    wire start_dec_latched = start_dec_sync[1];

    decelerator dec (
        .clk_1mhz(clk_1mhz),
        .reset(reset),
        .start(start_dec_latched),   // use latched request
        .decelerated(decelerated),
        .decelerator_active(dec_active),
        .pwm_signal(dec_pwm_signal)
    );
    
    // Mux logic decided which PWM siganl to output (accelerator or decelerator)
    assign pwm_signal = acc_pwm_signal&acc_active | dec_pwm_signal&dec_active;
    
    // -----------------------
    // FSM for motor control
    // -----------------------
    wire obstacle;
    assign obstacle = (distance_front <= 16'd13);
    
    motors_fsm motor_machine (
        .clkin(clk),
        .reset(reset),
        .obstacle(obstacle),
        .timer_expire(timer_expired),
        .accelerated(accelerated_125mhz),      // Use synchronized version
        .decelerated(decelerated_125mhz),      // Use synchronized version
        .start_timer(start_timer),
        .start_acc(start_acc_pulse),
        .start_dec(start_dec_pulse),
        .direction(direction)
    );
    
endmodule
