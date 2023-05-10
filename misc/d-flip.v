module d_flipflop (
    clk,
    reset,
    in_1,
    enable,
    clear,
    out_1
);

input clk; 
input reset;
input in_1;
input enable;
input clear;
output out_1;

reg out_1;

always @(posedge clk or posedge reset)
begin
    if (reset)
        out_1 <= 1'b0;
    else if ( clear == 1'b0)
        out_1 <= 1'b0;
    else if (enable)
        out_1 <= in_1;
end
endmodule

module d_flipflop_tb;
reg clk = 0,reset,in_1,enable,clear;
wire out_1;

d_flipflop UUT(
    .clk(clk),
    .reset(reset),
    .in_1(in_1),
    .enable(enable),
    .clear(clear),
    .out_1(out_1)
);


initial begin


    $dumpfile("d_flip.vcd");
    $dumpvars(0,d_flipflop_tb);

    clk=0;enable=1;in_1=1;#10;
    clk=1;enable=0;in_1=0;#10;
    clk=0;enable=0;reset=1;#10;
end
endmodule