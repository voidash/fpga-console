module flashtb #(
    parameter STARTUP_WAIT = 32'd10000000
) ();


localparam MEMORY_LENGTH = 5;

reg clk = 1;
reg [((MEMORY_LENGTH * 8) -1): 0] data = "hello";
wire flashClk;
reg flashMiso;
wire flashCs;
reg [23:0] readAddress = 23'b0;
wire [((MEMORY_LENGTH * 8) -1): 0] dataBuffer;
reg enable = 1 ;
wire dataReady;

flashNavigator #(10,MEMORY_LENGTH) UUT(
    clk,
    readAddress,
    enable,
    flashClk,
    flashMiso,
    flashMosi,
    flashCs,
    dataBuffer,
    dataReady
);

integer i;
initial begin
    $display("starting flash test");
    #10
    #1 
    #16
    #48
    #75
    #4
    for( i = ((MEMORY_LENGTH * 8) -1) ; i >= 0 ; i = i - 1 ) 
    begin
        #4 flashMiso = data[i];
    end
    #1000 $finish;
end

initial begin
    $dumpfile("flash.vcd");
    $dumpvars(0,flashtb);
end

always 
    #1 clk = ~clk;

endmodule