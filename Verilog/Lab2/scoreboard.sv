module scoreboard (
    input wire clk, reset,
    input wire inc_exp, dec_exp,
    input wire enter, exit
);
    integer error_count = 0;

    initial begin
        $display("Scoreboard Test Started");
    end

    always @(posedge clk) begin
        if (reset) begin
            error_count = 0;
        end else begin
            if (inc_exp && ~enter) begin //if enter isn't triggered when expected to 
                $display("Error: Expected enter signal, but not received");
                error_count = error_count + 1;
            end
            if (dec_exp && ~exit) begin //if exit isnt triggered when expected
                $display("Error: Expected exit signal, but not received");
                error_count = error_count + 1;
            end
            if (~inc_exp && enter) begin //if enter is triggered when it is not expected
                $display("Error: Unexpected enter signal");
                error_count = error_count + 1;
            end
            if (~dec_exp && exit) begin //when exit is triggered when it is not expected
                $display("Error: Unexpected exit signal");
                error_count = error_count + 1;
            end
        end
    end

    initial begin
        #100;
        $display("Test finished with %d errors.", error_count);
        $stop;
    end

endmodule
