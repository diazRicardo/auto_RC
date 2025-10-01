`timescale 1ns / 1ps

module top(
    input clkin, 
    input [3:0] btn,
    input jc6,
    output jc4, 
    output jc5,
    output jc7,
    output [6:0] je,
    output [7:0] jd,
    output [3:0] led
    );
    
    wire reset;
    assign reset = btn[0];
    
    // Clock signals
    wire clk_1mhz, clk_1khz, clk_20hz;
    
    // Buffer the top-level clock input
    wire clkin_buf;
    IBUF clkin_ibuf_inst (.I(clkin), .O(clkin_buf));

    
    // Clock system
    robot_clock_system clk_sys(
        .clk_125mhz(clkin_buf),
        .reset(reset),
        .clk_1mhz(clk_1mhz),
        .clk_1khz(clk_1khz),
        .clk_20hz(clk_20hz)
    );
    
    wire [15:0] distance_front;
    wire [15:0] distance_left;
    wire [15:0] distance_right;
    
    hc_sr04_interface front_sensor(
        .clk_125mhz(clkin_buf),
        .clk_1mhz(clk_1mhz), 
        .clk_20hz(clk_20hz),
        .reset(reset), 
        .echo(jc6),        // Connect echo input directly
        .trig(jc7),        // Connect trig output directly
        .distance_cm(distance_front), 
        .measurement_ready(mr)  
    );
    
//    hc_sr04_interface left_sensor(
//        .clk_125mhz(clkin_buf),
//        .clk_1mhz(clk_1mhz), 
//        .clk_20hz(clk_20hz),
//        .reset(reset), 
//        .echo(jc6),        // Connect echo input directly
//        .trig(jc7),        // Connect trig output directly
//        .distance_cm(distance_left), 
//        .measurement_ready(mr_left)  
//    );
    
//    hc_sr04_interface right_sensor(
//        .clk_125mhz(clkin_buf),
//        .clk_1mhz(clk_1mhz), 
//        .clk_20hz(clk_20hz),
//        .reset(reset), 
//        .echo(jc6),        // Connect echo input directly
//        .trig(jc7),        // Connect trig output directly
//        .distance_cm(distance_right), 
//        .measurement_ready(mr_right)  
//    );
    
    // Outputs: clk and digsel 
    //       ...used to display distance measured by a sensor on a seven-seg display
    wire clk, digsel;    
    labCnt_clks slowit (
        .clkin(clkin_buf),
        .greset(reset), 
        .clk(clk), 
        .digsel(digsel)
    );             

    // Filter out invalid readings from HC-SR04 sensor
    reg [15:0] last_valid_distance;

    always @(posedge clk) begin
        if (reset) begin
            last_valid_distance <= 16'd25;  // Start with a reasonable default
        end else if ((distance_front < 16'd400) && (distance_front > 16'd1)) begin
            last_valid_distance <= distance_front;
        end
    end
        
    // Use filtered distance for display
    wire [15:0] dec_to_hex;
    assign dec_to_hex = last_valid_distance;

    wire [3:0] ring_output;   // Route ring counter output to the selector
    wire [3:0] to_decimal;        // Route selector output to hex7seg
      
    // Ring counter instance
    ring_counter rc (.Advance(digsel), .clkin(clk), .sel(ring_output));   
    
    // Selector instance    
    selector sel (.N_i(dec_to_hex), .sel_i(ring_output), .H_o(to_decimal));
    
    // Seven seg instance 
    // Segment signals to JE Pmod ports
    hex7seg sev_seg (.n(to_decimal), .seg(je)); 
    
    // Anode signals sent to JD Pmod ports
    assign jd[3] = ~ring_output[0];
    assign jd[2] = ~ring_output[1];
    assign jd[1] = ~ring_output[2];
    assign jd[0] = ~ring_output[3];
    
    // Motor controller instance drives motors via motor FSM
    wire [6:0] direction;
    wire pwm;
    
    motor_controller controller (
        .clk(clkin_buf),
        .clk_1mhz(clk_1mhz),
        .reset(reset),
        .distance_front(last_valid_distance),
        .direction(direction),
        .idle_timer_active(led[0]),
        .pwm_signal(pwm)
    );
        
    // Dual_motors directly connected to motor_controller instance
    wire [4:1] in;
    
    dual_motors front (
        .clk_125mhz(clkin_buf),
        .reset(reset),
        .direction(direction),          // Connect direction to motor_controller output
        .pwm_signal(pwm),
        .in(in),
        .enA(jc4),
        .enB(jc5)
    );
    
    assign jd[7] = in[1];
    assign jd[6] = in[2];
    assign jd[5] = in[3];
    assign jd[4] = in[4];

    // Debug lines to see whats happening
    assign led[3] = direction == 7'b0000001;    // FORWARD
    assign led[2] = direction == 7'b0000010;   // IDLE
    assign led[1] = direction == 7'b0010000;    // RIGHT
    assign led[0] = direction == 7'b0100000;  // ACC
   
  
endmodule

