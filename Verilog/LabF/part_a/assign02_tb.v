/*`timescale 1ns / 1ps

module top_module_tb;

reg clk;
reg reset;
wire [23:0] lfsr_reg;
wire seq_detected;


top_module uut (
    .clk(clk),
    .reset(reset),
    .lfsr_reg(lfsr_reg),
    .seq_detected(seq_detected)
);

initial begin
    
    clk = 0;
    reset = 1;

 
    #100;
    reset = 0;
    
   
    #100000; // Adjust as needed to see sequence detection
    
    $finish; // Terminate simulation
end

// Clock generation
always #5 clk = ~clk; 


initial begin
    $monitor("Time=%t clk=%0d reset=%0d LFSR Register=%b Sequence Detected=%0d",
              $time, clk, reset, lfsr_reg, seq_detected);
end

endmodule
