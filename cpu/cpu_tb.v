module cpu_tb();

reg clk = 0;
wire [23:0] flashReadAddr;
reg [15:0] flashByteRead;
wire flashEnabled;
reg flashDataReady=0; // only after this is turned, then the cpu goes to next step
wire [5:0] leds;
wire [255:0] uartData;
wire writeUart;
reg reset = 0;
reg btn1 = 1;
reg btn2 = 1;
reg btn3 = 1;
reg btn4 = 1;
reg uartWritten = 0;
reg [300:0] command_string = "";

// CPU module that adds two numbers
cpu #(8) UUT 
(
    clk,
    flashReadAddr,
    flashByteRead,
    flashEnabled,
    flashDataReady,
    leds,
    uartData,
    writeUart,
    uartWritten,
    reset,
    btn1,
    btn2,
    btn3,
    btn4
);

initial begin
    // clear B register
    #1 flashByteRead = 16'h0002;
    command_string = "clear b reg";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;
    // Add AC to C 
    #3 flashByteRead = 16'h0201;
    command_string = "add AC to C";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;

    //store AC contents in C 
    #3 flashByteRead = 16'h0402;
    command_string = "Store AC contents in C";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;

    // invert A
    #3 flashByteRead = 16'h0602;
    command_string = "invert C";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;

    //add intermediate
    #3 flashByteRead = 16'h8200;
    command_string = "Add intermediate";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;
    #3 flashByteRead = 16'h0010;
    #1 flashDataReady = 1;
    #4 flashDataReady = 0;

    //test print
    #3 flashByteRead = 16'h8802;
    command_string = "print 123";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;
    // prints 0123
    #3 flashByteRead = 16'b0000_0001_0010_0011;
    #1 flashDataReady = 1;
    #4 flashDataReady = 0;
    #10 uartWritten = 1;

    //halt check
    #3 flashByteRead = 16'h0e00;
    command_string = "halt";
    #3 flashDataReady = 1;
    #4 flashDataReady = 0;

    #1000 $finish;
end

initial begin
    $dumpfile("cpu_test.vcd");
    $dumpvars(0, cpu_tb);
end

always 
#1 clk = ~clk;


endmodule