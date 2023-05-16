module cpu_tb();

reg clk = 0;
wire [23:0] flashReadAddr;
reg [15:0] flashByteRead;
wire flashEnabled;
reg flashDataReady=0; // only after this is turned, then the cpu goes to next step
wire [5:0] leds;
wire [100:0] uartData;
wire writeUart;
reg reset = 0;
reg btn1 = 1;
reg btn2 = 1;
reg btn3 = 1;
reg btn4 = 1;


// CPU module that adds two numbers
cpu UUT(
    clk,
    flashReadAddr,
    flashByteRead,
    flashEnabled,
    flashDataReady,
    leds,
    uartData,
    writeUart,
    reset,
    btn1,
    btn2,
    btn3,
    btn4
);

initial begin
    // clear A register
    #1 flashByteRead = 16'h0002;
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;
    // Add AC to B
    #8 flashByteRead = 16'h0104;
    #11 flashDataReady = 1;
    #12 flashDataReady = 0;

    #1000 $finish;
end

initial begin
    $dumpfile("cpu_test.vcd");
    $dumpvars(0, cpu_tb);
end

always 
#1 clk = ~clk;


endmodule