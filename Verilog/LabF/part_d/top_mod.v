`timescale 1ns / 1ps

module top(
    input wire CCLK,          // 100MHz clock
    input wire reset,        // reset
    input wire switch_R2,    // switch to toggle between first and second half of bit configuration
    output wire led_max_tick,// LED for max_tick
    output wire [13:0] led  // 14 LEDs dedicated to LFSR bits
    
);
    //wire clk;             
    wire [21:0] lfsr_reg;   // LFSR current value
    wire clk;
    wire max_tick_reg;         // Register to hold the max_tick 
    reg [13:0] led_output;    // to hold LED output

    // Instantiate the clock divider
    clk1hz clock_1hz(
        .clk_input(CCLK), 
        .clk_output(clk) //one input from top mod and  one output which is passed on to lfsr 
    );

    // Instantiate the LFSR
    lfsr lfsr(
        .clk(clk),
        .reset(reset),
        .lfsr_reg(lfsr_reg),
        .max_tick_reg(max_tick_reg) 
    );

    // Use the R2 switch to toggle bit displays
    always @* begin
        if (switch_R2) 
        begin
            // if R2 is on, display bit 15 to 22
            led_output = lfsr_reg[21:14];
        end else 
        begin
            // if R2 is off, display the first 14 bits of lfsr_reg
            led_output = lfsr_reg[13:0];
        end
    end

    // Assign the max_tick_reg to dedicated LED
    assign led_max_tick = max_tick_reg;

    // Assign the LED output to the remaining LEDs
    assign led = led_output[13:0];

endmodule
