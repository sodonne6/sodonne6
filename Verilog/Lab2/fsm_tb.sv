/*module fsm_tb;

    // Wires to connect FSM, stimulus, and monitor
    wire clk, reset;
    wire a, b;
    wire enter, exit;

    // Instantiate stimulus generator
    stim_gen STIM (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .enter(enter),
        .exit(exit)
    );

    // Instantiate DUT (FSM)
    fsm DUT (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .enter(enter),
        .exit(exit)
    );


    // Instantiate monitor
    scoreboard MON (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .enter(enter),
        .exit(exit)
    );

endmodule
