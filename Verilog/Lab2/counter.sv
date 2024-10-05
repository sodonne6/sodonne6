module counter (
    input clk,
    input reset,
    input inc,
    input dec,
    output reg [3:0] count
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 4'b0000;  // Reset count to 0
        end else begin
            if (inc) begin
                count <= count + 1;  // Increment count
            end else if (dec) begin
                count <= count - 1;  // Decrement count
            end
        end
    end
endmodule
 