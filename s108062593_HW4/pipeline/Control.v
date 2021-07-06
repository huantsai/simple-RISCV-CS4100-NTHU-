module Control(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	Branch_o,
	MemWrite_o,
	MemRead_o,
	MemtoReg_o
	);
     
//I/O ports
input  [7-1:0] instr_op_i;

output         RegWrite_o;
output [2-1:0] ALU_op_o;
output         ALUSrc_o;
output         Branch_o;
output		   MemWrite_o;
output		   MemRead_o;
output		   MemtoReg_o;

// RegWrite_o
// ALU_op_o
// ALUSrc_o
// Branch_o
// MemWrite_o
// MemRead_o
// MemtoReg_o

//Internal Signals
reg    [2-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegWrite_o;
reg            Branch_o;
reg			   MemWrite_o;
reg			   MemRead_o;
reg			   MemtoReg_o;

//Parameter

// if error happen ,check ALUSrc_o
//Main function
always@(*)
begin
	case(instr_op_i)
			7'b0110011: // R-type  Q: 沒有輸入function
			begin
				RegWrite_o = 1'b1;
				ALU_op_o = 2'b10;
				ALUSrc_o = 1'b0; 
				Branch_o = 1'b0;
				MemWrite_o = 1'b0;
				MemRead_o = 1'b0;
				MemtoReg_o	= 1'b0;
			end

			7'b0010011: // slti and addi
			begin
				RegWrite_o = 1'b1;
				ALU_op_o = 2'b11;
				ALUSrc_o = 1'b1; 
				Branch_o = 1'b0;
				MemWrite_o = 1'b0;
				MemRead_o = 1'b0;
				MemtoReg_o	= 1'b0;
			end

			7'b0000011: // LD
			begin
				RegWrite_o = 1'b1;
				ALU_op_o = 2'b00;
				ALUSrc_o = 1'b1; 
				Branch_o = 1'b0;
				MemWrite_o = 1'b0;
				MemRead_o = 1'b1;
				MemtoReg_o	= 1'b1;
			end

			7'b0100011: // SD
			begin
				RegWrite_o = 1'b0;
				ALU_op_o = 2'b00;
				ALUSrc_o = 1'b1; 
				Branch_o = 1'b0;
				MemWrite_o = 1'b1;
				MemRead_o = 1'b0;
				MemtoReg_o	= 1'b0;
			end

			7'b1100011: // beq
			begin
				RegWrite_o = 1'b0;
				ALU_op_o = 2'b01;
				ALUSrc_o = 1'b0; 
				Branch_o = 1'b1;
				MemWrite_o = 1'b0;
				MemRead_o = 1'b0;
				MemtoReg_o	= 1'b0;
			end
	endcase
end
	
endmodule