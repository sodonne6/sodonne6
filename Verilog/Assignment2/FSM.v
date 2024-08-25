`timescale 1ns / 1ps
//101110011000
module FSM(
    input seq_in,
    input clk, reset,
    output reg seq_det
    );

    // Define states for each bit of the sequence
    parameter S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011,
              S4 = 4'b0100, S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111,
              S8 = 4'b1000, S9 = 4'b1001, S10 = 4'b1010, S11 = 4'b1011,
              DETECT = 4'b1100;

    reg [3:0] current_state, next_state;
 

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next state logic based on the current state and input
    always @(*) begin
        case (current_state)
            S0: next_state = seq_in ? S1 : S0; //1 //if 1 move to s1 else go s0
            S1: next_state = seq_in ? S1 : S2;  //0   //if 1 stay at s1 else go s2
            S2: next_state = seq_in ? S3 : S0; //1   //if 1 move to s3 else go s0
            S3: next_state = seq_in ? S4 : S0; //1  //if 1 move to s4 else go s0
            S4: next_state = seq_in ? S5 : S0; //1  //if 1 move to s5 else go s0
            S5: next_state = seq_in ? S1 : S6; //0  //if 1 move to s1 else go s6
            S6: next_state = seq_in ? S1 : S7; //0  //if 1 move to s1 else go s7
            S7: next_state = seq_in ? S8 : S0; //1 //if 1 move to s8 else go s0
            S8: next_state = seq_in ? S9 : S0; //1 //if 1 move to s9 else go s0
            S9: next_state = seq_in ? S1 : S10; //0 //if 1 move to s1 else go s10
           S10: next_state = seq_in ? S1 : S11; //0 //if 1 move to s1 else go s11
           S11: next_state = seq_in ? S1 : DETECT; //0 //if 1 move to s1 else go to detect
            DETECT: next_state = seq_in ? S1 : S0; // Allow for overlapping sequences
            default: next_state = S0;
        endcase
    end

    // Output logic
    always @(current_state) begin
        seq_det = (current_state == DETECT); //sequence detection
    end
endmodule

