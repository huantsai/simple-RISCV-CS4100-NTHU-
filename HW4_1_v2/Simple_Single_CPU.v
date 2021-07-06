`timescale 1ns / 1ps
module Simple_Single_CPU(
    clk_i,
	rst_i
);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire [32-1:0] instr_w;
wire [64-1:0] pc_addr_w;
wire [64-1:0] Imm_Gen_w;
wire [64-1:0] shift_left_w;
wire [64-1:0] mux_alusrc_w;
wire [64-1:0] mux_pc_result_w;
wire [64-1:0] add2_sum_w;
wire [4-1:0]  alu_control_w;
wire [64-1:0] alu_result_w;
wire [64-1:0] dataMem_read_w;
wire [64-1:0] mux_dataMem_result_w;
wire [64-1:0] rf_rs1_data_w;
wire [64-1:0] rf_rs2_data_w;
wire [64-1:0] add1_result_w;
wire [64-1:0] add1_source_w;
assign add1_source_w = 64'd4;
wire [2-1:0]  ctrl_alu_op_w;
wire ctrl_write_mux_w;
wire ctrl_register_write_w;
wire ctrl_branch_w;
wire ctrl_alu_mux_w;
wire and_result_w;
wire alu_zero_w;
wire ctrl_mem_write_w;
wire ctrl_mem_read_w;
wire ctrl_mem_mux_w;

//Create components
ProgramCounter PC(
        .clk_i(),      
	    .rst_i (),     
	    .pc_in_i() ,   
	    .pc_out_o() 
	    );
	
Adder Adder1(
        .src1_i(),
	    .src2_i(),     
	    .sum_o()    
	    );
	
Instr_Mem IM(
        .pc_addr_i(),  
	    .instr_o()    
	    );

//DO NOT MODIFY	.RDdata_i && .RegWrite_i
Reg_File RF(
        .clk_i(),
		.rst_i(),
		.RS1addr_i() ,
		.RS2addr_i() ,
		.RDaddr_i() ,
		.RDdata_i(mux_dataMem_result_w[64-1:0]),
		.RegWrite_i(ctrl_register_write_w),
		.RS1data_o() ,
		.RS2data_o()
        );
	
//DO NOT MODIFY	.RegWrite_o
Control Control(
        .instr_op_i(),
		.Branch_o(),
		.MemRead_o(),
		.MemtoReg_o(),
	    .ALU_op_o(),
		.MemWrite_o(),
	    .ALUSrc_o(),
	    .RegWrite_o(ctrl_register_write_w)
	    );

ALU_Ctrl AC(
        .funct_i(),   
        .ALUOp_i(),   
        .ALUCtrl_o() 
        );
	
Imm_Gen IG(
        .data_i(),
        .data_o()
        );

MUX_2to1 #(.size(64)) Mux_ALUSrc(
        .data0_i(),
        .data1_i(),
        .select_i(),
        .data_o()
        );	
		
ALU ALU(
        .src1_i(),
	    .src2_i(),
	    .ctrl_i(),
	    .result_o(),
		.zero_o()
	    );
		
Adder Adder2(
        .src1_i(),     
	    .src2_i(),     
	    .sum_o()      
	    );
		
Shift_Left_One_64 Shifter(
        .data_i(),
        .data_o()
        ); 		
		
MUX_2to1 #(.size(64)) Mux_PC_Source(
        .data0_i(),
        .data1_i(),
        .select_i(),
        .data_o()
        );	
		
		
Data_Mem DataMemory(
		.clk_i(),
		.rst_i(),
		.addr_i(),
		.data_i(),
		.MemRead_i(),
		.MemWrite_i(),
		.data_o()
		);

//DO NOT MODIFY	.data_o
 MUX_2to1 #(.size(64)) Mux_DataMem_Read(
        .data0_i(),
        .data1_i(),
        .select_i(),
        .data_o(mux_dataMem_result_w)
		);

endmodule