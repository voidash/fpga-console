module mul_modi_16bit(a,b,out);

input signed [15:0] a,b;
output signed [31:0] out;

wire [15:0] w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;

wire [15:0] sum1,sum2,sum3,sum4,sum5,sum6,sum7,sum8,sum9,sum10,sum11,sum12,sum13,sum14,sum15;

wire c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15;


and16bit x1 (w1,a[0],b);

assign out[0]=w1[0];

and16bit x2 (w2,a[1],b);

add_sub_16bit cs1({1’b0,w1[15:1]},w2,sum1,c1,1’b0);

assign out[1]=sum1[0];

and16bit x3 (w3,a[2],b);

add_sub_16bit cs2({c1,sum1[15:1]},w3,sum2,c2,1’b0);

assign out[2]=sum2[0];

and16bit x4 (w4,a[3],b);

add_sub_16bit cs3({c2,sum2[15:1]},w4,sum3,c3,1’b0);

assign out[3]=sum3[0];

and16bit x5 (w5,a[4],b);

add_sub_16bit cs4({c3,sum3[15:1]},w5,sum4,c4,1’b0);

assign out[4]=sum4[0];

and16bit x6 (w6,a[5],b);

add_sub_16bit cs5({c4,sum4[15:1]},w6,sum5,c5,1’b0);

assign out[5]=sum5[0];

and16bit x7 (w7,a[6],b);

add_sub_16bit cs6({c5,sum5[15:1]},w7,sum6,c6,1’b0);

assign out[6]=sum6[0];

and16bit x8 (w8,a[7],b);

add_sub_16bit cs7({c6,sum6[15:1]},w8,sum7,c7,1’b0);

assign out[7]=sum7[0];

and16bit x9 (w9,a[8],b);

add_sub_16bit cs8({c7,sum7[15:1]},w9,sum8,c8,1’b0);

assign out[8]=sum8[0];

and16bit x10 (w10,a[9],b);

add_sub_16bit cs9({c8,sum8[15:1]},w10,sum9,c9,1’b0);

assign out[9]=sum9[0];

and16bit x11 (w11,a[10],b);

add_sub_16bit cs10({c9,sum9[15:1]},w11,sum10,c10,1’b0);

assign out[10]=sum10[0];

and16bit x12 (w12,a[11],b);

add_sub_16bit cs11({c10,sum10[15:1]},w12,sum11,c11,1’b0);

assign out[11]=sum11[0];

and16bit x13 (w13,a[12],b);

add_sub_16bit cs12({c11,sum11[15:1]},w13,sum12,c12,1’b0);

assign out[12]=sum12[0];

and16bit x14 (w14,a[13],b);

add_sub_16bit cs13({c12,sum12[15:1]},w14,sum13,c13,1’b0);

assign out[13]=sum13[0];

and16bit x15 (w15,a[14],b);

add_sub_16bit cs14({c13,sum13[15:1]},w15,sum14,c14,1’b0);

assign out[14]=sum14[0];

and16bit x16 (w16,a[15],b);

add_sub_16bit cs15({c14,sum14[15:1]},w16,sum15,c15,1’b0);
assign out[30:15]=sum15[15:0];
assign out[31]=c15;
endmodule