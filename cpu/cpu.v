module cpu(
    input clk,
    output reg[23:0] flashReadAddr = 0,
    input [15:0] flashByteRead,
    output reg flashEnabled=0,
    input flashDataReady,
    output reg [5:0] leds = 6'b111111,
    output reg [100:0] uartData = 100'b0,
    output reg writeUart = 0,
    input reset,
    input btn1,
    input btn2, 
    input btn3,
    input btn4
);

reg [7:0] rect [11:0];
reg [7:0] circle [9:0];
reg [7:0] pixel [4:0];
reg [7:0] number [3:0];
initial begin
    // defing rectangle
    rect[0] = "r";
    rect[1] = "e";
    rect[2] = "c";
    rect[3] = "t";
    rect[4] = " ";
    rect[5] = "x";
    rect[6] = " ";
    rect[7] = "y";
    rect[8] = " ";
    rect[9] = "w";
    rect[10] = " ";
    rect[11] = "h";

    // defining circle
    circle[0] = "c";
    circle[1] = "i";
    circle[2] = "r";
    circle[3] = "c";
    circle[4] = " ";
    circle[5] = "x";
    circle[6] = " ";
    circle[7] = "y";
    circle[8] = " ";
    circle[9] = "r";

    // pixel
    pixel[0] = "p";
    pixel[1] = " ";
    pixel[2] = "x";
    pixel[3] = " ";
    pixel[4] = "y";

    // number

    number[0] = "n";
    number[1] = " ";
    number[2] = "0";
    number[3] = "2";

end

localparam CMD_CLR = 0;
localparam CMD_ADD = 1;
localparam CMD_STA = 2;
localparam CMD_INV = 3;
localparam CMD_PRNT = 4;
localparam CMD_JMPZ = 5;
localparam CMD_WAIT = 6;
localparam CMD_HLT = 7;
localparam CMD_SUB = 7;
localparam CMD_RECT = 8;
localparam CMD_CIRC = 9;
localparam CMD_PIX = 10;
localparam CMD_NUM = 11;


reg [5:0] state = 0;
reg [10:0] pc = 0;
reg [9:0] a = 1, b = 2;
reg [9:0] c = 3, ac = 1;
reg [15:0] param = 0, command = 0;

reg [15:0] waitCounter = 0;

// state machine for our CPU
localparam STATE_FETCH = 0;
localparam STATE_FETCH_WAIT_START = 1;
localparam STATE_FETCH_WAIT_DONE = 2;
localparam STATE_DECODE = 3;
localparam STATE_RETRIEVE = 4;
localparam STATE_RETRIEVE_WAIT_START = 5;
localparam STATE_RETRIEVE_WAIT_DONE = 6;
localparam STATE_EXECUTE = 7;
localparam STATE_HALT = 8;
localparam STATE_WAIT = 9;
localparam STATE_PRINT = 10;


always @(posedge clk) begin
    if (reset) begin
        pc <= 0;
        a <= 0;
        b <= 0;
        c <= 0;
        ac <= 0;
        command <= 0;
        param <= 0;
        state <= STATE_FETCH;
        flashEnabled <= 0;
        leds <= 6'b111111;
    end
    else begin
        case(state)
        STATE_FETCH: begin
            if (~flashEnabled) begin
                flashReadAddr <= {13'b0,pc};
                flashEnabled <= 1;
                state <= STATE_FETCH_WAIT_START;
            end
        end
        STATE_FETCH_WAIT_START: begin
            if (~flashDataReady) begin
                state <= STATE_FETCH_WAIT_DONE;
            end
        end
        STATE_FETCH_WAIT_DONE: begin
            if (flashDataReady) begin
                command <= flashByteRead;
                flashEnabled <= 0;
                state <= STATE_DECODE;
            end
        end
        STATE_DECODE: begin
            pc <= pc + 1;
            if (command[15]) begin
                state <= STATE_RETRIEVE;
            end else begin
                param <= command[2] ? a : (command[1] ? b : (command[0] ? c : ac));
                state <= STATE_EXECUTE;
            end
        end
        STATE_RETRIEVE: begin
            if (~flashEnabled) begin
                flashReadAddr <= {13'b0,pc};
                flashEnabled <= 1;
                state <= STATE_RETRIEVE_WAIT_START;
            end
        end
        STATE_RETRIEVE_WAIT_START: begin
            if (~flashDataReady) begin
                state <= STATE_RETRIEVE_WAIT_DONE;
            end
        end
        STATE_RETRIEVE_WAIT_DONE: begin
            if (flashDataReady) begin
                param <= flashByteRead;
                flashEnabled <= 0;
                state <= STATE_EXECUTE;
                pc <= pc + 1;
            end
        end
        STATE_EXECUTE: begin
            state <= STATE_FETCH;
            case (command[14:9])
                CMD_CLR: begin
                    if(command[0])
                        ac <= 0;
                    else if(command[1])
                        b <= 0;
                    else if(command[2])
                        a <= 0;
                    else if (command[3])
                        ac <= btn1 ? 0 : (ac ? 1 : 0);
                    else if (command[4])
                        ac <= btn2 ? 0 : (ac ? 1 : 0);
                    else if (command[5])
                        ac <= btn3 ? 0 : (ac ? 1 : 0);
                    else if (command[6])
                        ac <= btn4 ? 0 : (ac ? 1 : 0);
                end
                CMD_ADD: begin
                    ac <= ac + param;
                end
                CMD_STA: begin
                    if(command[0])
                        leds <= ~ac[5:0];
                    else if (command[1])
                        c <= ac;
                    else if (command[2])
                        b <= ac;
                    else if (command[3])
                        a <= ac;
                end
                CMD_INV: begin
                    if ( command[0] )
                        ac <= ~ac;
                    else if (command[1])
                        c <= ~c;
                    else if (command[2])
                        b <= ~b;
                    else if (command[3])
                        a <= ~a;
                end
                CMD_PRNT: begin
                    // todo
                end
                CMD_JMPZ: begin
                    pc <= (ac == 8'd0) ? {3'b0, param} : pc;
                end
                CMD_WAIT: begin
                    waitCounter <= 0;
                    state <= STATE_WAIT;
                end
                CMD_HLT: begin
                    state <= STATE_HALT;
                end

            endcase
        end
        STATE_WAIT: begin
            if (waitCounter == 27000) begin
                param <= param -1;
                waitCounter <= 0;
                if (param == 0)
                    state <= STATE_FETCH;
            end else 
                waitCounter <= waitCounter + 1;
        end

        STATE_HALT: begin
        end

        endcase
    end
end

endmodule