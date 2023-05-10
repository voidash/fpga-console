module slice (
);

reg [7:0] my_bit = 8'b10110111;

initial begin
    $display("slice test");
    $display("%b", my_bit[7:3]);
    $display("%b", my_bit[7:4]);
    $display("%b", my_bit[7:2]);
    $display("%b", my_bit[3:0]);
    $display("%b", my_bit[-1:-2]);
end

endmodule
