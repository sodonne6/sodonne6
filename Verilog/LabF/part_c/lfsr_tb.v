`timescale 1ns / 1ps

module lfsr_tb;
    reg clk, reset;
    wire max_tick_reg;
    wire lfsr_reg;
    wire [21:0] zero_counter;
    wire [21:0] one_counter;
    
    lfsr uut(
        .clk(clk),
        .reset(reset),
        .lfsr_reg(lfsr_reg),
        .max_tick_reg(max_tick_reg),
        .zero_counter(zero_counter),
        .one_counter(one_counter)
    );
    // oscillate clock 20 ns period
  // Clock generation
  initial begin
    clk = 1;
    forever #10 clk = ~clk; // 20ns clock period
  end
    
    // reset for first 2 clock cycles
    initial
    begin
        reset = 1'b1;
        #200; 
        reset = 1'b0;
    end
endmodule