module top_module(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);
    wire cout,c2;
    add16 df(a[15:0], b[15:0] ^ {16{sub}}, sub, sum[15:0],cout);
    add16 df2(a[31:16], b[31:16] ^ {16{sub}}, cout, sum[31:16], c2);
endmodule
