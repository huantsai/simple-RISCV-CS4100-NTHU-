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
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(mux_pc_result_w) ,   
	    .pc_out_o(pc_addr_w) 
	    );
	
Adder Adder1(
        .src1_i(pc_addr_w),
	    .src2_i(add1_source_w),     
	    .sum_o(add1_result_w)    
	    );
	
Instr_Mem IM(
        .pc_addr_i(pc_addr_w),  
	    .instr_o(instr_w)    
	    );

//DO NOT MODIFY	.RDdata_i && .RegWrite_i
Reg_File RF(
        .clk_i(clk_i),
		.rst_i(rst_i),
		.RS1addr_i(instr_w[19:15]) ,
		.RS2addr_i(instr_w[24:20]) ,
		.RDaddr_i(instr_w[11:7]) ,
		.RDdata_i(mux_dataMem_result_w[64-1:0]),
		.RegWrite_i(ctrl_register_write_w),
		.RS1data_o(rf_rs1_data_w) ,
		.RS2data_o(rf_rs2_data_w)
        );
	
//DO NOT MODIFY	.RegWrite_o
Control Control(
        .instr_op_i(instr_w[6:0]),
		.Branch_o(ctrl_branch_w),
		.MemRead_o(ctrl_mem_read_w),
		.MemtoReg_o(ctrl_mem_mux_w),
	    .ALU_op_o(ctrl_alu_op_w),
		.MemWrite_o(ctrl_mem_write_w),
	    .ALUSrc_o(ctrl_alu_mux_w),
	    .RegWrite_o(ctrl_register_write_w)
	    );

ALU_Ctrl AC(
        .funct_i({instr_w[30], instr_w[14:12]}),   
        .ALUOp_i(ctrl_alu_op_w),   
        .ALUCtrl_o(alu_control_w) 
        );
	
Imm_Gen IG(
        .data_i(instr_w),
        .data_o(Imm_Gen_w)
        );

MUX_2to1 #(.size(64)) Mux_ALUSrc( // use #(.size(64)) replace size in NUX_2to1
        .data0_i(rf_rs2_data_w),
        .data1_i(Imm_Gen_w),
        .select_i(ctrl_alu_mux_w),
        .data_o(mux_alusrc_w)
        );	
		
ALU ALU(
        .src1_i(rf_rs1_data_w),
	    .src2_i(mux_alusrc_w),
	    .ctrl_i(alu_control_w),
	    .result_o(alu_result_w),
		.zero_o(alu_zero_w)
	    );
		
Adder Adder2(
        .src1_i(pc_addr_w),     
	    .src2_i(shift_left_w),     
	    .sum_o(add2_sum_w)      
	    );
		
Shift_Left_One_64 Shifter(
        .data_i(Imm_Gen_w),
        .data_o(shift_left_w)
        ); 		
		
MUX_2to1 #(.size(64)) Mux_PC_Source(
        .data0_i(add1_result_w),
        .data1_i(add2_sum_w),
        .select_i(ctrl_branch_w && alu_zero_w),
        .data_o(mux_pc_result_w)
        );	
		
		
Data_Mem DataMemory(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.addr_i(alu_result_w),
		.data_i(rf_rs2_data_w),
		.MemRead_i(ctrl_mem_read_w),
		.MemWrite_i(ctrl_mem_write_w),
		.data_o(dataMem_read_w)
		);

//DO NOT MODIFY	.data_o
 MUX_2to1 #(.size(64)) Mux_DataMem_Read( // what is #??
        .data0_i(alu_result_w),
        .data1_i(dataMem_read_w),
        .select_i(ctrl_mem_mux_w),
        .data_o(mux_dataMem_result_w)
		);

endmodule