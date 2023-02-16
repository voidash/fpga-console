module andOr (
    input inp1,
    input inp2,
    input inp3,
    output out1
);
   wire g1; 
   and(g1, inp1, inp2);
   or(out1, g1, inp3);

endmodule