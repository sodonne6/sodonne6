module AdderSubtractor6Bit(
    input [5:0] x,  // 6-bit 2s complement number
    input [5:0] y,  // 6-bit 2s complement number 
    input sel,      // 0 for add 1 for subtract
    output overflow, 
    output cout,    // Carry out
    output [5:0] sum 
);

   //wires for y and carry
    wire [5:0] yin;
    wire [5:0] carry;

    //get 2's complement of y depending on sel value // negative if sel =1 
    assign y_in = sel ? ~y : y;

   //first carry value is the value of sel 
    assign carry[0] = sel;

    
    fullAdder fA0(x[0], y_in[0], carry[0], sum[0], carry[1]);
    fullAdder fA1(x[1], y_in[1], carry[1], sum[1], carry[2]);
    fullAdder fA2(x[2], y_in[2], carry[2], sum[2], carry[3]);
    fullAdder fA3(x[3], y_in[3], carry[3], sum[3], carry[4]);
    fullAdder fA4(x[4], y_in[4], carry[4], sum[4], carry[5]);
    fullAdder fA5(x[5], y_in[5], carry[5], sum[5], cout);

    // detect overflow using xor of carry out's msb and carryout 
    assign overflow = carry[5] ^ cout;

endmodule
