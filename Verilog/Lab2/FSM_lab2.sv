module fsm (
    input wire clk,       // Clock
    input wire reset,     // Reset signal
    input wire a, b,      // Sensor inputs
    output reg enter,     // Enter signal
    output reg exit       // Exit signal
);

    // Declare state names
    localparam [2:0]
        IDLE            = 3'b000,
        a_blocked       = 3'b001,
        b_blocked       = 3'b010,
        both_blocked_a  = 3'b011,
        both_blocked_b  = 3'b100,
        enter_blocked   = 3'b101,
        exit_blocked    = 3'b110;
    
    // State register
    reg [2:0] state_reg, state_next;
 
 
     // State transition logic (sequential logic)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;   // Reset to IDLE
        end else begin
            state_reg <= state_next;  // Transition to next state

        end
    end

    // Next-state and output logic (combinational logic)
    always @(*) begin
        // Default values
        state_next = state_reg;
        enter = 1'b0;
        exit = 1'b0;

        // FSM logic
        case (state_reg)
            IDLE: begin
                if (a == 1 && b == 0) begin
                    state_next = a_blocked;  // Car approaching from sensor a (entry)
                end
                else if (a == 0 && b == 1) begin
                    state_next = b_blocked;  // Car approaching from sensor b (exit)
                end
            end

           
            a_blocked: begin
                if (a == 1 && b == 1) begin
                    state_next = both_blocked_a;  // Both sensors triggered (car halfway)
                end
                else if (a == 0 && b == 0) begin
                    state_next = IDLE;     // Car left without entering/exiting
                end
            end
            
            b_blocked:begin
                if (a == 1 && b == 1) begin
                    state_next = both_blocked_b;  // Both sensors triggered (car halfway)
                end
                else if (a == 0 && b == 0) begin
                    state_next = IDLE;     // Car left without entering/exiting
                end
            end

            both_blocked_a: begin
                if (a == 0 && b == 1) begin
                    state_next = enter_blocked;  // Car passing towards b (entry path)
                end
                else if (a == 1 && b == 0) begin
                    state_next = IDLE;   // Car passing towards a (exit path)
                end
            end
            
             both_blocked_b: begin
                if (a == 1 && b == 0) begin
                    state_next = exit_blocked;  // Car passing towards b (entry path)
                end
                else if (a == 1 && b == 0) begin
                    state_next = IDLE;   // Car passing towards a (exit path)
                end
            end

            enter_blocked: begin
                if (a == 0 && b == 0) begin
                    enter = 1'b1;           // Car has fully entered
                    state_next = IDLE;      // Go back to IDLE
                end
            end

            exit_blocked: begin
                if (a == 0 && b == 0) begin
                    exit = 1'b1;            // Car has fully exited
                    state_next = IDLE;      // Go back to IDLE
                end
            end

            default: state_next = IDLE;
        endcase
    end

endmodule
