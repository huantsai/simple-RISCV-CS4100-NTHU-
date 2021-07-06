module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
//I/O ports
input  [64-1:0]  src1_i;
input  [64-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [64-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [64-1:0]  result_o;
wire             zero_o;
wire	[64-1:0]	tmp;
//Parameter

//Main function
assign zero_o = (result_o == 64'd0);
assign tmp = src1_i - src2_i;

always@(*) 
begin
	case (ctrl_i)
		4'b0000: // and
			result_o = src1_i & src2_i;
		4'b0001: // or
			result_o = src1_i | src2_i;
		4'b0010: // add
			result_o = $signed(src1_i) + $signed(src2_i);
		4'b0110: // sub
			result_o = $signed(src1_i) - $signed(src2_i);
		4'b0111: //slt ,slti
			result_o = {63'd0 ,tmp[64-1]};
		default: 
			result_o = 64'd1;
	endcase
end

endmodule
