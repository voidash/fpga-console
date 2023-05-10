module bus_signals
(
    in_1,
    in_2,
    in_3,
    out_1
);

input [3:0] in_1;
input [3:0] in_2;
input in_3;

output [3:0] out_1;
wire [3:0] in_3_bus;

assign in_3_bus = {4{in_3}};
assign out_1 = (~in_3_bus & in_1) | (in_3_bus & in_2);
endmodule

module bus_signal_tb;

reg [3:0] in_1 = 4'b0000;
reg [3:0] in_2 = 4'b1111;
reg in_3 = 1;
wire [3:0] out_1;

bus_signals UUT(
    .in_1(in_1),
    .in_2(in_2),
    .in_3(in_3),
    .out_1(out_1)
);

initial begin

    $dumpfile("multi.vcd");
    $dumpvars(0, bus_signal_tb);
    for(integer ii =  0;ii < 15;ii = ii+1)
    begin
        in_1= in_1 + 1; in_2= in_2-1; in_3 = 1; #10;
    end

    for(integer ii =  0;ii < 15;ii = ii+1)
    begin
        in_1= in_1 + 1; in_2= in_2-1; in_3 = 0; #10;
    end
end

endmodule