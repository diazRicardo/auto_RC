`timescale 1ns / 1ps

module top_testbench;

    // Testbench signals
    reg clkin;
    reg [3:0] btn;
    reg jc6;
    wire jc4, jc5, jc7;
    wire [6:0] je;
    wire [7:0] jd;
    wire [3:0] led;

    // Instantiate DUT
    top uut (
        .clkin(clkin),
        .btn(btn),
        .jc6(jc6),
        .jc4(jc4),
        .jc5(jc5),
        .jc7(jc7),
        .je(je),
        .jd(jd),
        .led(led)
    );

    // Generate 125 MHz clock (8 ns period)
    always #4 clkin = ~clkin;

    initial begin
        // Init
        clkin = 0;
        jc6   = 0;

        // === Hold reset active for 5 us ===
        btn   = 4'b0001;  // Assert reset
        #5000;            // 5 us -> 5 cycles of 1 MHz clock
        btn   = 4'b0000;  // Deassert reset

        // Wait a little for system to settle
        #10000;

        // === Case 1: Farther than 13 cm (20 cm) ===
        $display("=== Setting distance = 20 cm (>13cm) ===");
        uut.front_sensor.set_distance(16'd20);
        #20000; // let system react

         // === Case 2: At 10 cm (?13cm) ===
//        $display("=== Setting distance = 10 cm (<=13cm) ===");
//        uut.front_sensor.set_distance(16'd10);
//        #20000;

        // Finish
        $stop;
    end

endmodule

