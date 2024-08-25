module greq2(
input wire [1:0] a,b, //2bit inputs
output wire agrb //output if a is greater than b
    );
    
    wire q0,q1,q2;
    //output is 1 if any of these are true
    assign agrb = q0 | q1 | q2;
    
    assign q0 = a[1] & ~b[1];
    assign q1 = a[0] & ~b[1] & ~b[0];
    assign q2 = a[1] & a[0] & ~b[0];
endmodule
