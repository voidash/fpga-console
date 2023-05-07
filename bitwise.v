`timescale 1us/1ns

module bitwise_operators ();

reg r_A = 1'b1;
reg r_B = 1'b0;


reg [3:0] r_X = 4'b0101;
reg [3:0] r_Y = 4'b1100; 
reg [12:0] test = 12'b110011011111; 
wire [3:0] w_AND_VECTOR, w_OR_VECTOR, w_XOR_VECTOR, w_NOT_VECTOR;

assign w_AND_SCALAR = r_A & r_B;
assign w_OR_SCALAR = r_A | r_B;
assign w_XOR_SCALAR = r_A ^ r_B;
assign w_NOT_SCALAR = ~r_A;

assign w_AND_VECTOR = r_X & r_Y;
assign w_OR_VECTOR = r_X | r_Y;
assign w_XOR_VECTOR = r_X ^ r_Y;
assign w_NOT_VECTOR = ~r_X;

initial
    begin
        #10;
        $display( "AND of 1 and 0 is %b", w_AND_SCALAR );
        $display( "XOR of 1 and 0 is %b", w_XOR_SCALAR );
        $display( "testing %b", test[12-:8]);
        $display( "testing %b", test[12:3]);
        $display( "testing %b", test[0+:4]);
        $display( "testing stuff %b", test[12:0]);
        $display( "NOT of 1 is %b", w_NOT_SCALAR );
        #10;
        $display( "AND of 1 and 0 is %b", w_AND_VECTOR );
        $display( "OR of 1 and 0 is %b", w_OR_VECTOR );
        $display( "XOR of 1 and 0 is %b", w_XOR_VECTOR );
        $display( "NOT of 1 is %b", w_NOT_VECTOR );
    end
endmodule
