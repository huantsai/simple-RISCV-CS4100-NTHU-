module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [4-1:0] funct_i; // Q: funct_i跟ALUOp_i有什麼差別??
input      [2-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;   // equal to output reg[4-1:0] ALUCtrl_o
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o; // Q: 為什麼有兩個變數名稱一樣??

//Parameter


//Select exact operation, please finish the following code
always@(funct_i or ALUOp_i) 
begin
    case(ALUOp_i)
        2'b10: // R-type
            begin
                case(funct_i) // ch4 page 40
                    4'b0000: ALUCtrl_o = 4'b0010; // add
                    4'b1000: ALUCtrl_o = 4'b0110; // sub
                    4'b0111: ALUCtrl_o = 4'b0000; // and
                    4'b0110: ALUCtrl_o = 4'b0001; // or
                    4'b0010: ALUCtrl_o = 4'b0111; // slt
                    default: ALUCtrl_o = 4'b1111;
                endcase
            end
        2'b00: // ld, sd
            ALUCtrl_o = 4'b0010;
        2'b01: // beq
            ALUCtrl_o = 4'b0110;
        2'b11: // I-type
            begin
                case(funct_i[3-1:0])
                    3'b010: ALUCtrl_o = 4'b0111; // slti
                    3'b000: ALUCtrl_o = 4'b0010; // addi
                    default ALUCtrl_o = 4'b1111;
                endcase
            end
		default: ALUCtrl_o = 4'b1111; // must be write
    endcase
end
endmodule
