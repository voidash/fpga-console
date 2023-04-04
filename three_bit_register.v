module threeBit (
    clk,
    d,
    q,
    en,
    reset
);

input clk;
input[3:0] d;
output[3:0] q;
input en;
input reset;

reg[3:0] q;
// synchronously resettable flipflop
always_ff @(posedge clk) 
begin
    if (reset == 1) 
        q <= 4'h0;
    else if (en == 1)
        q <= d;
end
endmodule



