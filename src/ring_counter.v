`timescale 1ns / 1ps

module ring_counter (
    input Advance,
    input clkin,
    output [3:0] sel
    );
    
    // wires for FDRE inputs and outputs
    wire [3:0] q;
    
    // first FF with logic to ensure proper ring operation
    wire first_d;
    assign first_d = q[3] | (~(|q)); // either take q[3] OR if all bits are 0, set to 1
    
    // FDRE instances for each bit
    // Fix: Use first_d for the first flip-flop!
    FDRE #(.INIT(1'b1)) FDRE_0 (
        .C(clkin),
        .CE(Advance),
        .D(first_d),     // ? FIXED! Use first_d instead of q[3]
        .Q(q[0]),
        .R(1'b0)   
    );
    
    FDRE #(.INIT(1'b0)) FDRE_1 (
        .C(clkin),
        .CE(Advance),
        .D(q[0]),
        .Q(q[1]),
        .R(1'b0)    
    );
    
    FDRE #(.INIT(1'b0)) FDRE_2 (
        .C(clkin),
        .CE(Advance),
        .D(q[1]),
        .Q(q[2]),
        .R(1'b0)  
    );
    
    FDRE #(.INIT(1'b0)) FDRE_3 (
        .C(clkin),
        .CE(Advance),
        .D(q[2]),
        .Q(q[3]),
        .R(1'b0)    
    );
    
    assign sel = q;
    
endmodule