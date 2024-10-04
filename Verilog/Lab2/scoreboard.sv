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
                $display("Error: Expected enter signal, but not received");
                error_count = error_count + 1;
            end
            if (dec_exp && ~exit) begin
                $display("Error: Expected exit signal, but not received");
                error_count = error_count + 1;
            end
            if (~inc_exp && enter) begin
                $display("Error: Unexpected enter signal");
                error_count = error_count + 1;
            end
            if (~dec_exp && exit) begin 
                $display("Error: Unexpected exit signal");
                error_count = error_count + 1;
            end
            if (count != count_exp) begin //ensure counter follows expected count
                $display("Error: Count mismatch. Expected: %d, Got: %d", count_exp, count);
                error_count = error_count + 1;
            end
        end
    end

    initial begin
        #500;  // Extend the simulation time
        $display("Test completed with %d errors.", error_count);
        $stop;
    end
endmodule
