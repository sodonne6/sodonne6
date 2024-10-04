module stim_gen (
    output reg clk, 
    output reg reset, 
    output reg a, 
    output reg b, 
    output reg inc_exp, 
    output reg dec_exp, 
    output reg [3:0] count_exp
);
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Stimulus generation
    initial begin
        reset = 1;
        a = 0;
        b = 0;
        inc_exp = 0;
        dec_exp = 0;
        count_exp = 4'b0;
        #10 reset = 0;
        

        // Sequence 1: Car enters +1 (both enter and inc_exp high)
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 0; b = 1; #10;
        a = 0; b = 0; inc_exp = 1; #6;
        inc_exp = 0;
        count_exp = count_exp + 1;

        // Sequence 2: Car exits -1 (both exit and dec_exp high)
        a = 0; b = 1; #10;
        a = 1; b = 1; #10;
        a = 1; b = 0; #10;
        a = 0; b = 0; dec_exp = 1; #10;
        dec_exp = 0;
        count_exp = count_exp -1;
        
        // Sequence 3: Car exits +1 (both enter and inc_exp high)
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 0; b = 1; #10;
        a = 0; b = 0; inc_exp = 1; #10;
        inc_exp = 0;
        count_exp = count_exp + 1;
        
        // Sequence 4: Car begins to enter but reverses out (10->11->10->00)
        //inc and dec expected to be zero
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 1; b = 0; #10;
        a = 0; b = 0; inc_exp = 0; #6;
        inc_exp = 0;

        // Sequence 5: Car enters +1 (both enter and inc_exp high)
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 0; b = 1; #10;
        a = 0; b = 0; inc_exp = 1; #6;
        inc_exp = 0;
        count_exp = count_exp + 1;
        
        // Sequence 6: Car exits -1 (both exit and dec_exp high)
        a = 0; b = 1; #10;
        a = 1; b = 1; #10;
        a = 1; b = 0; #10;
        a = 0; b = 0; dec_exp = 1; #10;
        dec_exp = 0;
        count_exp = count_exp -1;
        
        // Sequence 7: Car begins to exit but reverses back in (01->11->01->00)
        //inc and dec expected to be zero
        a = 0; b = 1; #10;
        a = 1; b = 1; #10;
        a = 0; b = 1; #10;
        a = 0; b = 0; inc_exp = 0; #6;
        inc_exp = 0;
        
    end
endmodule
