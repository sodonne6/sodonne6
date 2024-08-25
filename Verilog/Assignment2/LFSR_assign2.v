`timescale 1ns / 1ps
module lfsr (
    input wire clk, // clock
    input wire reset, // reset
    output wire [23:0] lfsr_reg,  
    output wire seq_in,
    output reg [23:0] one_counter = 0, // count how many ones generated
    output reg [23:0] zero_counter = 0, // count how many zeroes counted
    output reg max_tick_reg = 0
);
    localparam seed_val = 24'b010001011111110101100111; // seed value

    reg [23:0] register = seed_val; // current bit configuration
    reg [23:0] next_register; // next bit config
    reg tap_feedback; // store generated bit

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            register <= seed_val;
            max_tick_reg <= 1'b0; 
            zero_counter <= 0; 
            one_counter <= 0; 
        end else begin
            register <= next_register;
            
          
            if (register[0] == 1'b1)
                one_counter <= one_counter + 1;
            else
                zero_counter <= zero_counter + 1;
            
            // Check for wrapping around the sequence
            if (register == seed_val) begin
                // This condition assumes the LFSR returns to its seed value, indicating a full cycle
                max_tick_reg <= 1'b1;
                // Potentially reset counters here if needed
            end else begin
                max_tick_reg <= 1'b0;
            end
        end
    end

    always @* begin
        // Compute the feedback bit
        //tapped bits according to xilinx datasheet
        tap_feedback = register[23] ^ register[22] ^ register[21] ^ register[16];
        
        
        next_register = {register[22:0], tap_feedback};
    end 

    //output lfsr value and sequence input 
    assign lfsr_reg = register;
    assign seq_in = lfsr_reg[0];
endmodule

