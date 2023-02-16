`include "ledBlink.v"
`timescale 1us/1ns

module led_blink_tb;

    reg r_CLOCK = 1'b0;
    reg r_ENABLE = 1'b0;
    reg r_SWITCH_1 = 1'b0;
    reg r_SWITCH_2 = 1'b0;

    wire w_LED_DRIVE;

led_blink UUT 
(
    .i_clock(r_CLOCK),
    .i_enable(r_ENABLE),
    .i_switch_1(r_SWITCH_1),
    .i_switch_2(r_SWITCH_2),
    .o_led_drive(w_LED_DRIVE),
);

awlays #20 r_CLOCK <= !r_CLOCK

initial begin
    r_ENABLE <= 1'b1;

    r_SWITCH_1 <= 1'b0;
    r_SWITCH_2 <= 1'b0;
    #200000

    r_SWITCH_1 <= 1'b0;
    r_SWITCH_2 <= 1'b1;
    #200000

    r_SWITCH_1 <= 1'b1;
    r_SWITCH_2 <= 1'b0;
    #200000

    r_SWITCH_1 <= 1'b1;
    r_SWITCH_2 <= 1'b1;
    #200000

    $display("Test Complete");
end

endmodule