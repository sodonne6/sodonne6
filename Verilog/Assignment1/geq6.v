// THIS MODULE ALLOWS FOR THE 8-BIT >= CIRCUIT TO BE USED AS A 6-BIT 2'S COMPLEMENT >= CIRCUIT
// THE INPUTS TO THE CIRCUIT ARE THE TWO 2'S COMPLEMENT 6-BIT INPUTS TO THE ALU
// THESE 6-BIT INPUTS ARE TURNED INTO 8-BIT INPUTS AND ARE PASSED TO THE 8-BIT >= CIRCUIT
// THE 1-BIT OUTPUT OF THE >= CIRCUIT AND THE MSB OF EACH 6-BIT INPUT ARE USED TO GENERATE A 1-BIT OUTPUT SIGNAL

module geq6
    (
    input wire [5:0] i0, i1,
    output wire two_comp_greq
    );
    
    //TEMPORARY WIRES FOR USING 6-BIT INPUTS TO ALU AS 8-BIT INPUTS TO THE >= CIRCUIT
    wire [7:0] A8, B8;
    //TEMPORARY VARIABLES FOR STORING THE MSB OF EACH 6-BIT INPUT FOR USE IN 2'S COMPLEMENT COMPARISON, ALONG WITH THE 1-BIT COMPARATOR RESULT
    wire msbA, msbB, out; 
    assign msbA = i0[5];
    assign msbB = i1[5];  
      
    //FOR EACH 8-BIT INPUT FOR THE >= CIRCUIT, LET BITS 0->5 = THE 6-BIT INPUT TO THE ALU AND LET THE OTHER BITS =0
    assign A8[7:6] = 0;
    assign A8[5:0] = i0; 
    assign B8[7:6] = 0;
    assign B8[5:0] = i1;
    
    //PASS THESE CREATED 8-BIT NUMBERS TO THE 8-BIT >= CIRCUIT
    eq8 A_GREQ_B (.c(A8), .d(B8), .greq(out));
          
    //USING THE MSB OF EACH INPUT TO THE ALU AND THE RESULT OF THE >= CIRCUIT, THIS NOW WORKS AS A 2'S COMPLEMENT COMPARATOR
    assign two_comp_greq = ~msbA & out | ~msbA & msbB | msbB & out;
       
endmodule
