`timescale 1ns / 1ps

module clk1hz(
    input wire clk_input,  // 100MHz input clock
    output reg clk_output  // 1Hz output clock
);
    reg [25:0] counter = 0;
    
    always @(posedge clk_input) 
    begin
        if (counter >= 500000) 
        begin
            counter <= 0;
            clk_output <= ~clk_output;
        end
        else 
        begin
            counter <= counter + 1;
        end
    end
endmodule

