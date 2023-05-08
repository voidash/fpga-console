`default_nettype none

module top
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
    input clk,
    output flashClk,
    input flashMiso,
    output flashMosi,
    output flashCs,
    input btn1,
    input btn2,
    output [5:0] led
);

// intermediate buttons because of 1.8v and 3.3v banks
reg btn1Reg = 1, btn2Reg = 1;
always @(negedge clk) begin
    btn1Reg <= btn1 ? 0 : 1;
    btn2Reg <= btn2 ? 0 : 1;
end

wire [10:0] flashReadAddr;
wire [7:0] byteRead;
wire enableFlash;
wire flashDataReady;

flash externalFlash(
    clk,
    flashClk,
    flashMiso,
    flashMosi,
    flashCs,
    flashReadAddr,
    byteRead,
    enableFlash,
    flashDataReady
);

wire [7:0] cpuChar;
wire [5:0] cpuCharIndex;
wire writeScreen;

cpu c(
    clk,
    flashReadAddr,
    byteRead,
    enableFlash,
    flashDataReady,
    led,
    btn1Reg,
    btn2Reg
);


endmodule