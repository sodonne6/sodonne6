module ALU(
input wire [5:0] a,b,
input wire [2:0] fxn,
output reg [5:0] x
    );
    
wire [5:0] Ainvert,Binvert,AnxorB,AplusB,AminusB;           //6 bit output
wire AlessB;                                                //Output is 1 bit so initialise as 1bit and alter in subroutine

invert6 A_invert (.x(a), .invertx(Ainvert));                                   //X -> -A
invert6 B_invert (.x(b), .invertx(Binvert));                                   //X -> -B
less6 A_less_B (.x(a), .y(b), .less_6(AlessB));                                //X -> A<B 
nxor6 A_nxor_B (.x(a),.y(b), .nxor_6(AnxorB));                                 //X -> A nxor B (BITWISE NXOR)
AdderSubtractor6Bit A_plus_B (.x(a), .y(b), .sel(0), .sum(AplusB));            //X -> A + B
AdderSubtractor6Bit A_minus_B (.x(a), .y(b), .sel(1), .sum(AminusB));          //X -> A - B      

//sort function calls
always @(*)
begin 
    if (fxn == 3'b000) {x} = {a};                                           // X -> A                        //DONE
    if (fxn == 3'b001) {x} = {b};                                           // X -> B                        //DONE
    if (fxn == 3'b010) {x} = {Ainvert};                                     // X -> -A                       //DONE //work
    if (fxn == 3'b011) {x} = {Binvert};                                     // X -> -B                       //DONE //work
    if (fxn == 3'b100) {x[5:1],x[0]} = {0,AlessB};                          // X -> A<B                      //DONE //work
    if (fxn == 3'b101) {x} = {AnxorB};                                      // X -> A nxor B (BITWISE NXOR)  //DONE //work
    if (fxn == 3'b110) {x} = {AplusB};                                      // X -> A + B                    //DONE //work
    if (fxn == 3'b111) {x} = {AminusB};                                     // X -> A - B                    //DONE //work
    
end
endmodule
