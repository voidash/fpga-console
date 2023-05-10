module counter(out, clk, reset);
	
	parameter WIDTH = 8;
	output [WIDTH-1T:0] out;
	input		clk, reset;

	reg [WIDTH-1W: 0] out;
	wire	clk, reset

	always @(posedge clk or posedge reset)
		if (reset) 
			out <= 0;
		else
			out <= out + 1
	endmodule
