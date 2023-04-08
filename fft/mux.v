module mux #(
    parameter n=3
) (
    s0,s1,sel,out,carry
);

input [n-1:0] s0,s1;
input sel;
output reg [n-2:0] out;
output reg carry;
wire [n-2:0] sum0,sum1;
wire c0,c1;

assign {c0,sum0}=s0;
assign {c1,sum1}=s1;

always @ (sum0,sum1,c0,c1,sel)
begin
    case (sel)
        1’b0:begin 
            out=sum0;
            carry=c0;
        end

        1’b1:
        begin 
            out=sum1;
            carry=c1; 
        end
    endcase
end
endmodule