module fsm (
    input wire clk,       // Clock
    input wire reset,     // Reset signal
    input wire a, b,      // Sensor inputs
    output reg enter,     // Enter signal
    output reg exit       // Exit signal
);

    // Declare state names
    localparam [2:0]
        IDLE          = 3'b000,
        WAIT_A_OR_B   = 3'b001,
        WAIT_AB       = 3'b010,
        WAIT_BA_ENTER = 3'b011,
        WAIT_B        = 3'b100,
        WAIT_BA_EXIT  = 3'b101;
    
    // State register
    reg [2:0] state_reg, state_next;
    reg [1:0] first_button; // a == 01 b == 10
/*
    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset)begin
            state_reg <= IDLE;  // Reset to IDLE
            first_button <= 2'b00;
        end
        else begin
            state_reg <= state_next;  // Transition to next state
            
            if(state_reg == IDLE)
                if(a==1 && b==0)
                    first_button <= 2'b01;
                else if(a==0 && b==1)
                    first button <= 2'b10;
            end
        end        
    end
 */
 
     // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;   // Reset to IDLE
            first_button <= 2'b00;  // Reset first_button
        end else begin
            state_reg <= state_next;  // Transition to next state

            // Only store the first button pressed in the IDLE state
            if (state_reg == IDLE) begin
                if (a == 1 && b == 0)
                    first_button <= 2'b01;  // First button was a
                else if (a == 0 && b == 1)
                    first_button <= 2'b10;  // First button was b
            end
        end
    end

    // Next-state and output logic
    always @(*) begin
        // Default values
        state_next = state_reg;
        enter = 1'b0;
        exit = 1'b0;
        //first_button = 2'b00;

        // FSM logic
        case (state_reg)
            IDLE: begin
                if (a == 1 && b == 0) begin
                    //first_button = 2'b01;
                    state_next = WAIT_A_OR_B;  // Car approaching from sensor a (entry)
                end
                else if (a==0 && b==1)
                    //first_button = 2'b10;
                    state_next = WAIT_A_OR_B;  // Car approaching from sensor b (exit)
            end

            // Entry path: car enters
            WAIT_A_OR_B: begin
                if (a==1 && b==1)
                    state_next = WAIT_AB;  // Both sensors triggered (car halfway, entry)
                else if (a == 0 && b == 0)
                    state_next = IDLE;     // Car left without entering
            end

            WAIT_AB: begin
                if (a==0 && b==1)
                    state_next = WAIT_BA_ENTER;  // Car exiting through sensor b (entry)
                else if (a==1 && b==0)
                    state_next = WAIT_BA_EXIT;     // Both sensors cleared, no car
            end

            WAIT_BA_ENTER: begin
                if (a==0 && b==0 && first_button == 2'b01) begin
                    enter = 1'b1;           // Car has fully entered
                    state_next = IDLE;
                end
            end

            WAIT_BA_EXIT: begin
                if (a==0 && b==0 && first_button == 2'b10) begin
                    exit = 1'b1;            // Car has fully exited
                    state_next = IDLE;
                end
            end

            default: state_next = IDLE;
        endcase
    end

endmodule
