module scoreboard (
    input wire clk, reset,
    input wire inc_exp, dec_exp, 
    input wire [3:0] count_exp,
    input wire enter, exit,
    input wire [3:0] count
);
    integer error_count = 0;

    initial begin
        $display("Test Started");
    end

    always @(posedge clk) begin
        if (reset) begin
            error_count = 0;
        end else begin
            if (inc_exp && ~enter) begin
                $display("Error: Expected enter signal but not received by FSM");
                error_count = error_count + 1;
            end
            if (dec_exp && ~exit) begin
                $display("Error: Expected exit signal but not received by FSM");
                error_count = error_count + 1;
            end
            if (~inc_exp && enter) begin
                $display("Error: Unexpected Enter signal from FSM");
                error_count = error_count + 1;
            end
            if (~dec_exp && exit) begin 
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
        #500;  // Extend the simulation time
        $display("Test complete with a total %d errors.", error_count);
        $stop;
    end
endmodule
