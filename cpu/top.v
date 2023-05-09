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
    
    

reg [23:0] flashReadAddr = 1;
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

    // always @(negedge btn2)
    // begin
    //     if(flashReadAddr > 0)
    //     begin
    //         flashReadAddr <= flashReadAddr - 1;
    //         enableFlash <= 1;
    //         counter <= 0;
    //     end
    // end
    localparam MEMORY_LENGTH = 1;
    localparam DELAY_FRAMES = 234;
    wire [((MEMORY_LENGTH * 8) - 1):0] data;
    wire dataReady;

    flashNavigator #(STARTUP_WAIT, MEMORY_LENGTH) externalFlash(
        clk,
        flashReadAddr,
        enableFlash,
        flashClk,
        flashMiso,
        flashMosi,
        flashCs,
        data,
        dataReady
    );


    uart #(DELAY_FRAMES, MEMORY_LENGTH) dataSend(
        clk,
        data,
        uart_tx,
        dataReady
    );

 
endmodule