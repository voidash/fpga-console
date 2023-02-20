`timescale 1ns/1ns

module d_ff (i_clk, i_d,  o_q, o_qbar);
input i_d, i_clk;
output o_q, o_qbar;
reg o_q = 1'b0, o_qbar = 1'b0;

always @ (posedge i_clk)
begin
    o_q <= i_d;
    o_qbar <= !i_d;
end
endmodule


module d_ff_tb;
    reg r_D_TB, r_CLK_TB;
    wire w_Q_TB, w_QBAR_TB;

    always #5 r_CLK_TB = !r_CLK_TB;

    d_ff UUT
    (
        .i_clk(r_CLK_TB),
        .i_d(r_D_TB),
        .o_q(w_Q_TB),
        .o_qbar(w_QBAR_TB)
    );

    initial begin
        r_CLK_TB <= 1'b0;
        r_D_TB <= 1'b0;
        #40;
        r_D_TB <= 1'b1;
        #40;
        r_D_TB <= 1'b0;
        #40;
        r_D_TB <= 1'b1;
    end
endmodule

