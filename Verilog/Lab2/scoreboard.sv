//This module will compare expected values with actual values and if they dont match - output a relevent error message
module scoreboard (
    input wire clk, reset, //clock and reset signal
    input wire inc_exp, dec_exp,  //expected increment and decrement
    input wire [3:0] count_exp, //expected count
    input wire enter, exit, //enter and exit signal from fsm
    input wire [3:0] count //count from counter module
);
    integer error_count = 0; //start at 0 each time
    
    //display that test has begun before iteration through each case
    initial begin
        $display("Test Started"); 
    end
    //for each case check each of these conditions
    always @(posedge clk) begin
        if (reset) begin //reset return error count to 0
            error_count = 0;
        end else begin 
            if (inc_exp && ~enter) begin //check if enter signal is high when expected
                $display("Error: Expected enter signal but not received by FSM");
                error_count = error_count + 1;
            end
            if (~inc_exp && enter) begin //check to make sure enter doesn't trigger unexpectedly
                $display("Error: Unexpected Enter signal from FSM");
                error_count = error_count + 1;
            end
            if (dec_exp && ~exit) begin //check if exit signal is high when expected
                $display("Error: Expected exit signal but not received by FSM");
                error_count = error_count + 1;
            end
            if (~dec_exp && exit) begin  //check to make sure enter doesn't trigger enexpectedly
                $display("Error: Unexpected Exit signal from FSM");
                error_count = error_count + 1;
            end
            if (count != count_exp) begin //ensure counter follows expected count
                $display("Error: Expected Count and Actual Count mismatch. Expected: %d, Actual: %d", count_exp, count);
                error_count = error_count + 1;
            end
        end
    end

    initial begin
        #200;  // Extend the simulation time
        $display("Test complete with a total %d errors.", error_count);
        $stop;
    end
endmodule
