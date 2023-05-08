module flashNavigator
#(
    parameter STARTUP_WAIT = 32'd10000000,
    parameter MEMORY_LENGTH = 4 
) (
    input clk,
    output reg flashClk = 0,
    input flashMiso,
    output reg flashMosi,
    output reg flashCs = 1,
    output reg [((MEMORY_LENGTH * 8)-1):0] dataBuffer = 0,
    input btn1,
    input btn2
);
    
    reg [23:0] readAddress = 0;
    reg [7:0] command = 8'h03;
    reg [7:0] currentByteOut = 0;
    reg [7:0] currentByteNum = 0;
    reg [((MEMORY_LENGTH * 8) - 1):0] dataIn = 0;
    // reg [255:0] dataInBuffer = 0;

    localparam STATE_INIT_POWER = 8'd0;
    localparam STATE_LOAD_CMD_TO_SEND = 8'd1;
    localparam STATE_SEND = 8'd2;
    localparam STATE_LOAD_ADDRESS_TO_SEND = 8'd3;
    localparam STATE_READ_DATA = 8'd4;
    localparam STATE_DONE = 8'd5;

    reg [23:0] dataToSend = 0;
    reg [8:0] bitsToSend = 0;

    reg [32:0] counter = 0;
    reg [2:0] state = 0;
    reg [2:0] returnState = 0;

    reg dataReady = 0;

      always @(posedge clk) begin
      case (state)
  	    STATE_INIT_POWER: begin
            if (counter > STARTUP_WAIT) begin
                state <= STATE_LOAD_CMD_TO_SEND;
                counter <= 32'b0;
                dataReady <= 0;
                currentByteNum <= 0;
                currentByteOut <= 0;
            end
            else
                counter <= counter + 1;
            end
        STATE_LOAD_CMD_TO_SEND: begin
            flashCs <= 0;
            // choose only the MSB 8 bits out of the 24 bits
            dataToSend[23-:8] <= command; 
            bitsToSend <= 8;
            state <= STATE_SEND;
            returnState <= STATE_LOAD_ADDRESS_TO_SEND;
        end
        STATE_SEND: begin
            if (counter == 32'd0) begin
                flashClk <= 0;
                flashMosi <= dataToSend[23];
                dataToSend <= {dataToSend[22:0], 1'b0};
                bitsToSend <= bitsToSend - 1;
                counter <= 1;
            end
            else begin
                counter <= 32'd0;
                flashClk <= 1;
                if (bitsToSend == 0)
                    state <= returnState;
            end
        end

        STATE_LOAD_ADDRESS_TO_SEND: begin
            dataToSend <= readAddress;
            bitsToSend <= 24;
            state <= STATE_SEND;
            returnState <= STATE_READ_DATA;
            currentByteNum <= 0;
        end

        STATE_READ_DATA: begin
            if (counter[0] == 1'd0) begin
                flashClk <= 0;
                counter <= counter + 1;
                // reading 8th byte means setting it to counter to = 1000
                if (counter[3:0] == 0 && counter > 0) begin
                    // counter <= 1;
                    dataIn[(currentByteNum << 3) +: 8] <= currentByteOut;
                    currentByteOut <= 0;
                    currentByteNum <= currentByteNum + 1;
                    if (currentByteNum == MEMORY_LENGTH)
                    begin
                        state <= STATE_DONE;
                        flashCs <= 1;
                    end
                end
            end
            else begin
                flashClk <= 1;
                currentByteOut <= {currentByteOut[6:0], flashMiso};
                counter <= counter + 1;
            end
        end

        STATE_DONE: begin
            dataReady <= 1;
            flashCs <= 1;
            dataBuffer <= dataIn;
            counter <= STARTUP_WAIT;
            if (btn2 == 0) begin
                readAddress <= readAddress + 1;
                state <= STATE_INIT_POWER;
            end
        end



    
      endcase
  end
  
endmodule