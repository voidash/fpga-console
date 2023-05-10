module top_module (
    input d, 
    input ena,
    output q);
	
    reg w;
    always @(*)
        begin
            if (ena == 1) 
                w <= d;
           	q <= w;
        end
endmodule
