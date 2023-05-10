module add1(input a, input b, input cin, output sum, output cout);
  wire buf1, buf2, buf3;
  assign buf1 = a ^ b;
  assign sum = buf1 ^ cin;

  assign buf2 = a & b;
  assign buf3 = buf1 & cin;
  assign cout = buf2 ^ buf3; 
endmodule

module top_module (
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);

endmodule
