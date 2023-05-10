module simple_dflop (clk,
                    in_1,
                    out_1
                    );
                
    input clk;
    input in_1;
    output out_1;
    reg out_1;

    always @ (posedge clk)
    begin
        out_1 <= in_1;
    end
endmodule
