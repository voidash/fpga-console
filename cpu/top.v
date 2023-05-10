module top #(
    parameter STARTUP_WAIT = 32'd10000000
) (
    input clk,
    output flashClk,
    input flashMiso,
    output flashMosi,
    output flashCs,
    output uart_tx,
    input btn1,
    input btn2,
    output [5:0] leds
);
    
    

reg btn1Reg = 1, btn2Reg = 1;
always @(negedge clk) begin
    btn1Reg <= btn1 ? 0 : 1;
    btn2Reg <= btn2 ? 0 : 1;
end

reg [23:0] flashReadAddr = 0;
reg enableFlash = 1;
    always @(posedge clk)
    begin
        if (counter == 32'd10000000)
        begin
            enableFlash <= 0;
            counter <= 0;
        end
        else 
            counter <= counter + 1;
    end

    always @(negedge btn1)
    begin
        flashReadAddr <= flashReadAddr + 1;
        enableFlash <= 1;
        counter <= 0;
    end

    localparam MEMORY_LENGTH = 2;
    localparam DELAY_FRAMES = 234;
    wire [((MEMORY_LENGTH * 8) - 1):0] flashByteRead;
    wire flashDataReady;

    flashNavigator #(STARTUP_WAIT, MEMORY_LENGTH) externalFlash(
        clk,
        flashReadAddr,
        enableFlash,
        flashClk,
        flashMiso,
        flashMosi,
        flashCs,
        flashByteRead,
        flashDataReady
    );



    uart #(DELAY_FRAMES, MEMORY_LENGTH) dataSend(
        clk,
        flashByteRead,
        uart_tx,
        flashDataReady,
    );

    wire writeUart;
    reg reset = 0;
    wire[100:0] uartData;

    cpu c(
        clk,
        flashReadAddr,
        flashByteRead,
        enableFlash,
        flashDataReady,
        leds,
        uartData,
        writeUart,
        reset,
    );

 
endmodule