module fsm_tb;

    // Wires to connect FSM, stimulus, and monitor
    wire clk, reset;
    wire a, b;
    wire enter, exit;
    wire inc_exp, dec_exp;
    wire [3:0] count_exp;
    wire [3:0] count;

    // Instantiate stimulus generator
    stim_gen stim_gen (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .inc_exp(inc_exp),
        .dec_exp(dec_exp),
        .count_exp(count_exp)
    );
    
    // Instantiate FSM
    fsm uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .enter(enter),
        .exit(exit)
    );

    // Instantiate counter
    counter counter (
        .clk(clk),
        .reset(reset),
        .inc(enter),
        .dec(exit),
        .count(count)
    );

    // Instantiate scoreboard
    scoreboard scoreboard (
        .clk(clk),
        .reset(reset),
        .inc_exp(inc_exp),
        .dec_exp(dec_exp),
        .count_exp(count_exp),
        .count(count),
        .enter(enter),
        .exit(exit)
    );

endmodule
