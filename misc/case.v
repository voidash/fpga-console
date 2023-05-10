`timescale 1ns/1ns
module case_statement ();
reg r_VAL_1 = 1'b0;
reg r_VAL_2 = 1'b0;
reg r_VAL_3 = 1'b0;

reg [3:0] r_RESULT = 4'b0000;

always@(*)
begin
    case ({r_VAL_1, r_VAL_2, r_VAL_3})
        3'b000 : r_RESULT <= 0;
        3'b001 : r_RESULT <= 1;
        3'b010 : r_RESULT <= 2;
        default: r_RESULT <= 9;
    endcase
end

// this can't be synthesized
initial begin
    r_VAL_1 <= 1'b0;
    r_VAL_2 <= 1'b0;
    r_VAL_3 <= 1'b0;
    #10
    r_VAL_2 <= 1'b0;
    r_VAL_3 <= 1'b1;
    #10
    r_VAL_2 <= 1'b1;
    r_VAL_3 <= 1'b1;
    #10
end
endmodule


