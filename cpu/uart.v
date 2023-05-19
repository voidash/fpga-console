`default_nettype none

module uart
#(
    parameter DELAY_FRAMES = 234 ,// 27,000,000 (27Mhz) / 115200 Baud rate
    parameter MEMORY_LENGTH = 4
)
(
    input clk,
    input [((MEMORY_LENGTH * 8) -1):0] dataToSend,
    output uart_tx,
    input data_ready,
    output data_written
);

reg [3:0] txState = 0;
reg [32:0] txCounter = 0;
reg [7:0] dataOut = 0;
reg txPinRegister = 1;
reg [2:0] txBitNumber = 0;
reg [3:0] txByteCounter = 0;

assign uart_tx = txPinRegister;



localparam TX_STATE_IDLE = 0;
localparam TX_STATE_START_BIT = 1;
localparam TX_STATE_WRITE = 2;
localparam TX_STATE_STOP_BIT = 3;
localparam TX_STATE_DEBOUNCE = 4;

always @(posedge clk) begin
    case (txState)
        TX_STATE_IDLE: begin
            // buttons are active low
            if (data_ready == 1) begin
                txState <= TX_STATE_START_BIT;
                txCounter <= 0;
                data_written <= 0;
                txByteCounter <= 0;
            end
            else begin
                txPinRegister <= 1;
            end
        end 
        TX_STATE_START_BIT: begin
            txPinRegister <= 0;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                txState <= TX_STATE_WRITE;
                dataOut <= dataToSend[(txByteCounter << 3) +: 8];
                txBitNumber <= 0;
                txCounter <= 0;
            end else 
                txCounter <= txCounter + 1;
        end
        TX_STATE_WRITE: begin
            txPinRegister <= dataOut[txBitNumber];
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txBitNumber == 3'b111) begin
                    txState <= TX_STATE_STOP_BIT;
                end else begin
                    txState <= TX_STATE_WRITE;
                    txBitNumber <= txBitNumber + 1;
                end
                txCounter <= 0;
            end else 
                txCounter <= txCounter + 1;
        end
        TX_STATE_STOP_BIT: begin
            txPinRegister <= 1;
            if ((txCounter + 1) == DELAY_FRAMES) begin
                if (txByteCounter == MEMORY_LENGTH-1 ) begin
                    txState <= TX_STATE_DEBOUNCE;
                end else begin
                    txByteCounter <= txByteCounter + 1;
                    txState <= TX_STATE_START_BIT;
                end
                txCounter <= 0;
            end else 
                txCounter <= txCounter + 1;
        end
        TX_STATE_DEBOUNCE: begin
            // about 10ms as the speed is 27Mhz 
            if (txCounter == 32'd27000000) begin
                    txState <= TX_STATE_IDLE;
                    data_written <= 1;
            end else
                txCounter <= txCounter + 1;
        end
    endcase      
end
endmodule