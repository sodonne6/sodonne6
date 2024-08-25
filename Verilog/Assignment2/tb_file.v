/*`timescale 1ns / 1ps

module top_module_tb;

// Testbench generated signals
reg clk;
reg reset;
wire [15:0] lfsr_led; // Adjusted size to 16 bits
wire seq_detected;
wire [20:0] detect_counter; 

// Instantiate the top module with corrected ports
top_module uut (
    .clk(clk),
    .reset(reset),
    .lfsr_led(lfsr_led),
    .seq_detected(seq_detected), 
    .detect_counter(detect_counter) 
);



 // Clock generation
  initial begin
    clk = 1;
    forever #10 clk = ~clk; 
  end

// Test scenarios
initial begin
    
    clk = 0;
    reset = 1; 

    /
    #100;
    reset = 0; 
    
    // Modified monitor to include clk
    $monitor("Time: %t, CLK: %b, Reset: %b, LFSR LED: %b, Sequence Detected: %b, Detect Counter: %d", $time, clk, reset, lfsr_led, seq_detected, detect_counter);
    
    // Run simulation for a certain time to observe behavior
    #335544500; 

    // End simulation
    $finish;
end

endmodule