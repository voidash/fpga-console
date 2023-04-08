module ripple_carry_adder #(
    parameter n=16
) (
    sum,
    carry,
    a,
    b,
    enable
);
    output [n-1:0] sum;
    output carry;
    input [n-1:0] a,b;
    input enable;
    
    assign {carry,sum} = a+b+enable;
endmodule