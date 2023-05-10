module conti (
    a,b,c,d
);
input a;
input[3:0] b;
input[3:0] c;
output d;

assign d = a ? b : c;
endmodule
