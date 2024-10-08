module fsm (
    input wire clk,       //clock
    input wire reset,     //reset signal
    input wire a, b,      //sensor inputs
    output reg enter,     //enter signal
    output reg exit       //exit signal
);

    //declare states 7 in total
    localparam [2:0]
        IDLE            = 3'b000,
        a_blocked       = 3'b001,
        b_blocked       = 3'b010,
        both_blocked_a  = 3'b011,
        both_blocked_b  = 3'b100,
        enter_blocked   = 3'b101,
        exit_blocked    = 3'b110;
    
    //state register
    reg [2:0] state_reg, state_next;
 
 
     //state transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;   //reset to IDLE
        end else begin
            state_reg <= state_next;  //transition to next state

        end
    end

    //FSM logic
    always @(*) begin
        //default values
        state_next = state_reg;
        enter = 1'b0;
        exit = 1'b0;

        case (state_reg)
            IDLE: begin
                if (a == 1 && b == 0) begin //car begins to enter car park (sensor a blocked but not b)
                    state_next = a_blocked;  
                end
                else if (a == 0 && b == 1) begin
                    state_next = b_blocked;  //car begins to exit car park (sensor b blocked but not a)
                end
            end

           
            a_blocked: begin
                if (a == 1 && b == 1) begin
                    state_next = both_blocked_a;  //both sensors triggered (car moving further into entry)
                end
                else if (a == 0 && b == 0) begin
                    state_next = IDLE;     //car left without entering/exiting
                end
            end
            
            b_blocked:begin
                if (a == 1 && b == 1) begin
                    state_next = both_blocked_b;  //both sensors triggered (car moving further into exit sequence)
                end
                else if (a == 0 && b == 0) begin
                    state_next = IDLE;     //car left without entering/exiting
                end
            end

            both_blocked_a: begin
                if (a == 0 && b == 1) begin
                    state_next = enter_blocked;  //Car passing towards b (moving further inside car park)
                end
                else if (a == 1 && b == 0) begin
                    state_next = IDLE;   //invalid pattern (car has moved wrong direction for entry)
                end
            end
            
             both_blocked_b: begin
                if (a == 1 && b == 0) begin
                    state_next = exit_blocked;  //car passing towards a (moving further out of car park (exitting))
                end
                else if (a == 0 && b == 1) begin
                    state_next = IDLE;   // invalid input car begins to reverse
                end
            end

            enter_blocked: begin
                if (a == 0 && b == 0) begin
                    enter = 1'b1;           //car has fully entered
                    state_next = IDLE;      //go back to IDLE
                end
            end

            exit_blocked: begin
                if (a == 0 && b == 0) begin
                    exit = 1'b1;            //car has fully exited
                    state_next = IDLE;      //go back to IDLE
                end
            end

            default: state_next = IDLE;
        endcase
    end

endmodule
