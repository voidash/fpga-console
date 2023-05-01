module test();
reg clk = 0;
reg uart_rx = 1;
wire uart_tx;
wire[5:0] led;
reg btn = 1;

// lowering the clock pulse to 8
uart #(8'd8) u(
    clk,
    uart_rx,
    uart_tx,
    led, 
    btn
);


initial begin
    $display("starting UART RX");
    $monitor("LED Value %b", led);
    #10 uart_rx=0;
    #16 uart_rx=1;
    #16 uart_rx=0;
    #16 uart_rx=0;
    #16 uart_rx=0;
    #16 uart_rx=0;
    #16 uart_rx=1;
    #16 uart_rx=1;
    #16 uart_rx=0;
    #16 uart_rx=1;
    #1000 $finish;
end

initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0,test);
end

always 
    #1 clk = ~clk;

endmodule