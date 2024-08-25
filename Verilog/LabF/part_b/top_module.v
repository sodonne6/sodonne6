module top_module(
    input wire clk, // Clock signal
    input wire reset, // Reset signal
    input wire [4:0] button_input, // button input
    output wire [3:0] anode_sel, // Anode selection for 7-segment display
    output wire [6:0] led_out // LED output for display
);

// Signal declarations
wire [7:0] q; // 8bit wire to connect to DFF outputs
reg [7:0] q_next; // 8bit signal for next state of q
wire [4:0] buttons; // 5bit wire vector for debouncer buttons

// Instantiate 8 D flip-flops (DFF0 to DFF7)
d_ff_reset DFF0(.clk(clk),.reset(reset),.d(q_next[0]),.q(q[0]));
d_ff_reset DFF1(.clk(clk),.reset(reset),.d(q_next[1]),.q(q[1]));
d_ff_reset DFF2(.clk(clk),.reset(reset),.d(q_next[2]),.q(q[2]));
d_ff_reset DFF3(.clk(clk),.reset(reset),.d(q_next[3]),.q(q[3]));
d_ff_reset DFF4(.clk(clk),.reset(reset),.d(q_next[4]),.q(q[4]));
d_ff_reset DFF5(.clk(clk),.reset(reset),.d(q_next[5]),.q(q[5]));
d_ff_reset DFF6(.clk(clk),.reset(reset),.d(q_next[6]),.q(q[6]));
d_ff_reset DFF7(.clk(clk),.reset(reset),.d(q_next[7]),.q(q[7]));


debouncer db(.clk(clk), .reset(reset), .button_in(button_input), .button_out(buttons));

//Button logic 
always @(*) 
    begin
    q_next = q; // state stays the same
    if (buttons[0] | buttons[3]) //top and right button means increase by 1
    begin
        q_next = q + 1; 
    end else if (buttons[2] | buttons[1]) //down and left button means decrease by 1
    begin
        q_next = q - 1; 
    end else if (buttons[4]) 
    begin
        q_next = 8'd22; // load 22 if the center button is pressed
    end
end


seven_segment_controller ssc(
    .clk(clk),
    .reset(reset),
    .temp(q),
    .anode_select(anode_sel),
    .LED_out(led_out)
);

endmodule
