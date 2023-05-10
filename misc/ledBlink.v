module led_blink(
    input i_clock,
    input i_enable,
    input i_switch_1,
    input i_switch_2,
    output o_led_drive
);

begin
// as per the question if our
// input clock is 25kHz and with 50% duty cycle
// we have a 100Hz long led blink
// so total blinks we have is : 25kHz * 0.5 / 100Hz 

parameter c_CNT_100Hz = 125;
parameter c_CNT_50Hz = 250;
parameter c_CNT_10Hz = 1250;
parameter c_CNT_1Hz = 12500;

//counters
reg [31:0] r_CNT_100Hz = 0;
reg [31:0] r_CNT_50Hz = 0;
reg [31:0] r_CNT_10Hz = 0;
reg [31:0] r_CNT_1Hz = 0;

reg r_TOGGLE_100Hz = 1'b0;
reg r_TOGGLE_50Hz = 1'b0;
reg r_TOGGLE_10Hz = 1'b0;
reg r_TOGGLE_1Hz = 1'b0;

reg r_LED_SELECT;
wire w_LED_SELECT;

begin
    always @ (posedge i_clock)
    begin
    if (r_CNT_100Hz == c_CNT_100Hz-1)
        begin
            r_TOGGLE_100Hz <= !r_TOGGLE_100Hz;
            r_CNT_100Hz <= 0;
        end
    else
        r_CNT_100Hz <= r_CNT_100Hz + 1;
    end
end

begin
    always @ (posedge i_clock)
    begin
    if (r_CNT_50Hz == c_CNT_50Hz-1)
        begin
            r_TOGGLE_50Hz <= !r_TOGGLE_50Hz;
            r_CNT_50Hz <= 0;
        end
    else
        r_CNT_50Hz <= r_CNT_50Hz + 1;
    end
end

begin
    always @ (posedge i_clock)
    begin
    if (r_CNT_10Hz == c_CNT_10Hz-1)
        begin
            r_TOGGLE_10Hz <= !r_TOGGLE_10Hz;
            r_CNT_10Hz <= 0;
        end
    else
        r_CNT_10Hz <= r_CNT_10Hz + 1;
    end
end

begin
    always @ (posedge i_clock)
    begin
    if (r_CNT_1Hz == c_CNT_1Hz-1)
        begin
            r_TOGGLE_1Hz <= !r_TOGGLE_1Hz;
            r_CNT_1Hz <= 0;
        end
    else
        r_CNT_1Hz <= r_CNT_1Hz + 1;
    end
end

always @ (*)
begin
    case ({i_switch_1, i_switch_2})
    2'b11: r_LED_SELECT <= r_TOGGLE_1Hz;
    2'b10: r_LED_SELECT <= r_TOGGLE_10Hz;
    2'b01: r_LED_SELECT <= r_TOGGLE_50Hz;
    2'b00: r_LED_SELECT <= r_TOGGLE_100Hz;
    endcase
end

assign o_led_drive = r_LED_SELECT & i_enable;
end
endmodule