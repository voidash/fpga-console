module fulladder(
    input A,
    input B,
    input Cin,
    output sum,
    output carry
);
    wire X,Y,Z;
    assign X = A ^ B;
    assign Y = X & Cin;
    assign Z = A & B;

    assign carry = Y | Z;
    assign sum = X ^ Cin;
endmodule


module fulladder_tb;
    reg A, B, Cin;
    wire sum,carry;

    fulladder UUT(
        .A(A),
        .B(B),
        .Cin(Cin),
        .sum(sum),
        .carry(carry)
    );

    initial begin
        $dumpfile("fulladder.vcd");
        $dumpvars(0, fulladder_tb);
        
        A=0;B=1;Cin=0;#10;
        A=1;B=1;Cin=0;#10;
        A=1;B=1;Cin=1;#10;
    end
endmodule