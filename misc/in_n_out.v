module basic (
    input in_1,
    input in_2,
    input in_3,
    // output
    output out_1,
    output out_2
);

    assign out_1 = in_1 & in_2 & in_3;
    assign out_2 = in_1 | in_2 | in_3;
endmodule


module basic_tb; 
    reg a,b,c;
    wire d,e;

    basic UUT (
        .in_1(a),
        .in_2(b),
        .in_3(c),
        .out_1(d),
        .out_2(e)
    );
    
    initial begin
        $dumpfile("basic.vcd");
        $dumpvars(0,basic_tb);

        a=0;b=0;c=0; #10;
        a=0;b=1;c=0; #10;
        a=0;b=0;c=0; #10;
        a=1;b=1;c=1; #10;
    end

endmodule


