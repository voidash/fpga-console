
module uarttb #(
    parameter STARTUP_WAIT = 32'd10000000
) ();

localparam MEMORY_LENGTH = 2;
reg clk = 0;
reg [((MEMORY_LENGTH * 8) -1):0] data = 16'b1010101010101010;
wire uart_tx;
reg dataReady = 0;

uart #(8,MEMORY_LENGTH) UUT 
(clk,
data,
uart_tx,
dataReady
);


initial begin
    $display("starting UART Tx");
    $monitor("%b", uart_tx);
    #10 dataReady=1;
    #8 dataReady = 0;
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #8
    #1000 $finish;
end

initial begin
    $dumpfile("uart_test.vcd");
    $dumpvars(0,uarttb);
end

always 
    #1 clk = ~clk;

endmodule