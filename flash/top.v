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
);
    
    // 3.3v bank and 1.8v bank
    reg btn1Reg = 1, btn2Reg = 1;
    always @(negedge clk) begin
        btn1Reg <= btn1 ? 1 : 0;
        btn2Reg <= btn2 ? 1 : 0;
    end

    localparam MEMORY_LENGTH = 4;
    localparam DELAY_FRAMES = 234;
    wire [((MEMORY_LENGTH * 8) - 1):0] dataBuffer;

    flashNavigator #(STARTUP_WAIT, MEMORY_LENGTH) externalFlash(
        clk,
        flashClk,
        flashMiso,
        flashMosi,
        flashCs,
        dataBuffer,
        btn1Reg,
        btn2Reg
    );


    uart #(DELAY_FRAMES, MEMORY_LENGTH) dataSend(
        clk,
        dataBuffer,
        uart_tx,
        btn1
    );

 
endmodule