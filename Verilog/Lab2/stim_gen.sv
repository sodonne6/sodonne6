module stim_gen;

    // Wires to connect to FSM and scoreboard
    reg clk, reset; 
    reg a, b;
    wire enter, exit; 
    reg inc_exp, dec_exp;

    // Instantiate FSM
    fsm uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .enter(enter),
        .exit(exit)
    );

    // Instantiate scoreboard
    scoreboard sb (
        .clk(clk),
        .reset(reset),
        .inc_exp(inc_exp),
        .dec_exp(dec_exp),
        .enter(enter),
        .exit(exit)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Stimulus generation
    initial begin
        reset = 1;
        a=0;
        b=0;
        inc_exp = 0;
        dec_exp = 0;
        #10 reset = 0;

        // Sequence 1: Car enters +1 (both enter and inc_exp high)
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 0; b = 1; #10;
        a = 0; b = 0; inc_exp = 1; #10;
        inc_exp = 0;

        // Sequence 2: Car exits -1 (both exit and dec_exp high)
        a = 0; b = 1; #10;
        a = 1; b = 1; #10;
        a = 1; b = 0; #10;
        a = 0; b = 0;dec_exp = 1;#10;
        dec_exp = 0;
        
        //Sequence 3: Car enters +1 (both enter and inc_exp high)
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 0; b = 1; #10;
        a = 0; b = 0; inc_exp = 1; #10;
        inc_exp = 0;
        
        // Sequence 4: 
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        a = 1; b = 0; #10;
        a = 0; b = 0; inc_exp = 0; #10;
        inc_exp = 0;
        
        

        // End the simulation
        //$finish;
    end
endmodule
