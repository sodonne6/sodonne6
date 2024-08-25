`timescale 1ns / 1ps

module ALU_tb;

    // Inputs
    reg [5:0] a;
    reg [5:0] b;
    reg [2:0] fxn;
    wire [5:0] x;

    // Instantiate the Unit Under Test (UUT)
    ALU uut (
        .a(a),
        .b(b),
        .fxn(fxn),
        .x(x)
        
    );

    initial begin
        // Initialize Inputs
    fxn = 3'b110;

       // Add stimulus here
        // Test Case 1: Positive
        a = 6'b000101; 
        b = 6'b000000; 
        #10;

        // Test Case 2: Negative
        a = 6'b100100; 
        b = 6'b000000; 
        #10;

        // Test Case 3: Positive
        a = 6'b011100; 
        b = 6'b000000; 
        #10;

        // Test Case 4: 
        a = 6'b010000; 
        b = 6'b000000; 
        #10;

        // Test Case 5: 
        a = 6'b010101; 
        b = 6'b000000; 
        #10;

        // Test Case 6: 
        a = 6'b001111; 
        b = 6'b000000; 
        #10;
        // Test Case 7: 
        a = 6'b000100; 
        b = 6'b000000; 
        #10;

        // Test Case 8: 
        a = 6'b010110; 
        b = 6'b000000; 
        #10;
        
        $stop;
        
  end
     
endmodule
