module greq8(
input wire [7:0] a,b,
output greq
    );
    
    wire e0,e1,e2,e3,g0,g1,g2,g3;
    //2 bit equal to
    eq2 eq_0 (.a(a[1:0]), .b(b[1:0]), .aeqb(e0));
    eq2 eq_1 (.aeqb(e1), .a(a[3:2]), .b(b[3:2]));
    eq2 eq_2 (.aeqb(e2), .a(a[5:4]), .b(b[5:4]));
    eq2 eq_3 (.aeqb(e3), .a(a[7:6]), .b(b[7:6]));
    //2bit greater than
    greq2 gr_0 (.a(a[1:0]), .b(b[1:0]), .agrb(g0));
    greq2 gr_1 (.agrb(g1), .a(a[3:2]), .b(b[3:2]));
    greq2 gr_2 (.agrb(g2), .a(a[5:4]), .b(b[5:4]));
    greq2 gr_3 (.agrb(g3), .a(a[7:6]), .b(b[7:6]));
    
       
    assign greq = g3 | e3 & g2 | e3 & e2 & g1 | e3 & e2 & e1 & g0 | e3 & e2 & e1 & e0;
endmodule
