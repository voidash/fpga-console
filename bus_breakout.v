module bus_breakout (
    in_1,
    in_2,
    out_1
);
   input [3:0]  in_1;
   input [3:0] in_2;
   output [5:0] out_1;

//    concatenation
   assign out_1 = {
    in_2[3:2],
    (in_1[3] & in_2[1]),
    (in_1[2] & in_2[0]),
    in_1[1:0]
   };
   endmodule