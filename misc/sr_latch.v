module sr_latch(clk,reset,start,stop,count);
input clk;
input reset;
input start;
input stop;
output[3:0] count;

reg cnt_en;
reg[3:0] count=4'h0;
reg stop_d1;
reg stop_d2;

always @(posedge clk or posedge reset)
begin
        if(reset)
            cnt_en <= 1'b0;
        else if (start)
            cnt_en <= 1'b1;
        else if (stop)
            cnt_en <= 1'b0;
end

always @(posedge clk or posedge reset)
begin
    if (reset)
        count <= 4'h0;
    else if (cnt_en && count == 4'd13)
        count <= 4'h0;
    else if (cnt_en)
        count <= count + 1;
end

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        stop_d1 <= 1'b0;
        stop_d2 <= 1'b0;
    end
    else
    begin
        stop_d1 <= stop;
        stop_d2 <= stop_d1;
    end
end
endmodule

module sr_latch_tb;
reg clk;
reg reset;
reg start;
reg stop;
wire[3:0] count;

sr_latch UUT(
    .clk(clk),
    .reset(reset),
    .start(start),
    .stop(stop),
    .count(count)
);

initial begin
    $dumpfile("sr_latch.vcd");
    $dumpvars(0,sr_latch_tb);
    reset=0;stop=0;start=1;clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;

    stop=1;start=0;clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    start=1;stop=0;clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
    clk=1;#10;
    clk=0;#10;
end

endmodule