module fulladder ( input logic a,b,cin,
                   output logic s,cout);
logic p,g;

always_comb
begin
    p <= a ^ b; 
    g <= a & b; 
    s <= p ^ cin;  
    cout <= g | (p & cin);
end
endmodule

module fulladder_tb;
reg  a,b,cin;
wire s,cout;
fulladder UUT(
    .a(a),
    .b(b),
    .cin(cin),
    .s(s),
    .cout(cout)
);

initial begin
    $dumpfile("full.vcd");
    $dumpvars(0,fulladder_tb);
    $display("non blocking adder");
    a=0;b=1;cin=1;#10;
    a=1;b=1;cin=1;#10;
end
endmodule