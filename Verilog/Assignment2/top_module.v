`timescale 1ns / 1ps

module top_module(
    input wire CCLK,          // 100MHz clock
    input wire reset,         // System reset
    output wire [3:0] anode_select, // Anode selection for 7-segment display
    output wire [15:0] lfsr_led, // LED output to board
    output wire [6:0] led_out // LED output for display
);


wire [23:0] lfsr_output;
wire seq_in = lfsr_output[0]; //take new sequence input from here 
wire seq_detected; //flagged when sequence detected
wire clk; //clock

// Sequence detection counter
reg [7:0] detect_counter = 0; //count amount of detections

clk1hz clock_1hz(
    .clk_input(CCLK), 
    .clk_output(clk) // 100 Hz signal
);

// Instantiate the 24-bit LFSR
lfsr lfsr (
    .clk(clk),
    .reset(reset),
    .lfsr_reg(lfsr_output)
);

// Instantiate the sequence detector
FSM seq_detector (
    .seq_in(seq_in),
    .clk(clk),
    .reset(reset),
    .seq_det(seq_detected)
);

// Increment detect_counter whenever a sequence is detected
always @(posedge clk) begin
    if (reset)
        detect_counter <= 0;
    else if (seq_detected)
        detect_counter <= detect_counter + 1;
end


sevenseg display(
    .clk(CCLK), // Use 100Mhz to refresh screen
    .reset(reset),
    .detect_counter(detect_counter), 
    .anode_select(anode_select),
    .LED_out(led_out)
);

assign lfsr_led = lfsr_output[15:0];

endmodule
