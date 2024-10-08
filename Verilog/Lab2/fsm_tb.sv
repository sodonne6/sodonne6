module fsm_tb;

    //wires to connect FSM, counter, stimulus generator, and scoreboard monitor
    wire clk, reset;
    wire a, b;
    wire enter, exit;
    wire inc_exp, dec_exp;
    wire [3:0] count_exp;
    wire [3:0] count;

    //stimulus generator
    stim_gen stim_gen (
        .clk(clk), //clock signal
        .reset(reset), //reset 
        .a(a), //sensor a
        .b(b), //sensor b
        .inc_exp(inc_exp), //expected increment signal
        .dec_exp(dec_exp), //expected decrement signal
        .count_exp(count_exp) //expected count value
    );
    
    // Instantiate FSM
    fsm uut (
        .clk(clk), //clock signal
        .reset(reset), //reset signal
        .a(a), //sensor a 
        .b(b), //sensor b
        .enter(enter), //enter flag signal
        .exit(exit)  //exit flag signal
    );

    // Instantiate counter
    counter counter (
        .clk(clk), //clock signal
        .reset(reset), //reset
        .inc(enter), //counter increment connected to enter signal
        .dec(exit), //counter decrement connected to exit signal
        .count(count) //count value - amount of cars in carpark at a given time
    );

    // Instantiate scoreboard
    scoreboard scoreboard (
        .clk(clk), //clock signal
        .reset(reset), //reset
        .inc_exp(inc_exp), //connect inc_exp together in order to compare to enter
        .dec_exp(dec_exp), //connect dec_exp together in order to compare to exit
        .count_exp(count_exp), //connect count_exp together in order to compare to count
        .count(count), //count value from counter module
        .enter(enter), //enter value from FSM
        .exit(exit)  //exit value from FSM
    );

endmodule
