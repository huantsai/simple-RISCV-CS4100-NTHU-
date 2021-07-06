`timescale 1ns / 1ps
module Pipe_CPU(
        clk_i,
		rst_i
		);
    
/****************************************
*               I/O ports               *
****************************************/
input clk_i;
input rst_i;

/****************************************
*            Internal signal            *
****************************************/

/**** IF stage ****/
//control signal...
wire [32-1:0] instr_w;
wire [64-1:0] pc_addr_w;
wire [64-1:0] mux_pc_result_w;
wire [64-1:0] add1_result_w;
wire [64-1:0] add1_source_w;
assign add1_source_w = 64'd4;


/**** ID stage ****/
//control signal...
wire [64-1:0] Imm_Gen_w;
wire [64-1:0] rf_rs1_data_w;
wire [64-1:0] rf_rs2_data_w;

wire ctrl_write_mux_w; // not be used in simple CPU
wire ctrl_register_write_w;
wire ctrl_branch_w;
wire ctrl_alu_mux_w;


/**** EX stage ****/
//control signal...
wire [64-1:0] shift_left_w;
wire [64-1:0] mux_alusrc_w;
wire [64-1:0] add2_sum_w;
wire [4-1:0]  alu_control_w;
wire [64-1:0] alu_result_w;
wire [2-1:0]  ctrl_alu_op_w;
wire alu_zero_w;


/**** MEM stage ****/
//control signal...
wire [64-1:0] dataMem_read_w;
wire ctrl_mem_write_w;
wire ctrl_mem_read_w;
wire and_result_w;


/**** WB stage ****/
//control signal...
wire [64-1:0] mux_dataMem_result_w;
wire ctrl_mem_mux_w;

/**** Data hazard ****/
//control signal...
wire [2-1:0] ctrl_ForwardA_mux;
wire [2-1:0] ctrl_ForwardB_mux;
wire [64-1:0] ForwardA_res_w;
wire [64-1:0] ForwardB_res_w;

/**** Pipeline Register ****/
wire [64+32-1:0] IF_ID_o;
wire [283-1:0] ID_EXE_o;
wire [203-1:0] EXE_MEM_o;
wire [135-1:0] MEM_WB_o;

Forwarding_Unit FU(
	.EX_MEMRegWrite(EXE_MEM_o[202]),	// EXE_MEM_ctrl_register_write_w
	.MEM_WBRegWrite(MEM_WB_o[134]),		// MEM_WB_ctrl_register_write_w
	.EX_MEMRegisterRd(EXE_MEM_o[4:0]),	// EXE_MEM rd
	.MEM_WBRegisterRd(MEM_WB_o[4:0]),	// MEM_WB Rd 
	.ID_EXRegisterRs1(ID_EXE_o[9:5]),	// ID_EXE Rs1
	.ID_EXRegisterRs2(ID_EXE_o[4:0]),	// ID_EXE Rs2
	.ForwardA(ctrl_ForwardA_mux),
	.ForwardB(ctrl_ForwardB_mux)
	);

/****************************************
*          Instantiate modules          *
****************************************/
//Instantiate the components in IF stage
Program_Counter PC(
	.clk_i(clk_i),      
	.rst_i (rst_i),     
	.pc_in_i(mux_pc_result_w),   
	.pc_out_o(pc_addr_w) 
	);
		
MUX_2to1 #(.size(64)) Mux_PC_Source(
	.data0_i(add1_result_w),
	.data1_i(add2_sum_w),
	.select_i(and_result_w),
	.data_o(mux_pc_result_w)
	);	

Instr_Mem IM(
	.pc_addr_i(pc_addr_w),  
	.instr_o(instr_w)
	);
			
Adder Add_pc(
	.src1_i(pc_addr_w),
	.src2_i(add1_source_w),
	.sum_o(add1_result_w)
	);

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(64+32)) IF_ID(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.data_i({pc_addr_w/*64bit*/ ,instr_w/*32bit*/}),
	.data_o(IF_ID_o)
	);
		
//Instantiate the components in ID stage
Reg_File RF(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.RS1addr_i(IF_ID_o[19:15]),
	.RS2addr_i(IF_ID_o[24:20]),
	.RDaddr_i(MEM_WB_o[4:0]),
	.RDdata_i(mux_dataMem_result_w), // no need to change
	.RegWrite_i(MEM_WB_o[134]), // come from ME/WB pipeline reg
	.RS1data_o(rf_rs1_data_w),
	.RS2data_o(rf_rs2_data_w)
	);

Control Control(
	.instr_op_i(IF_ID_o[6:0]),
	.Branch_o(ctrl_branch_w), 			// be used in MEM
	.MemRead_o(ctrl_mem_read_w), 		// be used in MEM
	.MemtoReg_o(ctrl_mem_mux_w), 		// be used in WB
	.ALU_op_o(ctrl_alu_op_w), 			// be used in EXE
	.MemWrite_o(ctrl_mem_write_w), 		// be used in MEM
	.ALUSrc_o(ctrl_alu_mux_w), 			// be used in EXE
	.RegWrite_o(ctrl_register_write_w) 	// after WB stage, be used in ID
	);

Imm_Gen IG(
	.data_i(IF_ID_o[32-1:0]),
	.data_o(Imm_Gen_w)
	);	

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(283)) ID_EX(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.data_i({
		// WB							// size		addr			// meaning
		ctrl_register_write_w, 			// 1bit  	ID_EXE_o[282]	writeToReg
		ctrl_mem_mux_w, 				// 1bit 	ID_EXE_o[281]	write memRead or ALU  to reg
		// M
		ctrl_branch_w, 					// 1bit 	ID_EXE_o[280]
		ctrl_mem_read_w, 				// 1bit		ID_EXE_o[279]
		ctrl_mem_write_w, 				// 1bit		ID_EXE_o[278]
		// EX
		ctrl_alu_mux_w, 				// 1bit		ID_EXE_o[277]
		ctrl_alu_op_w, 					// 2bit		ID_EXE_o[276:275]
		// pc
		IF_ID_o[63+32:0+32],			// 64bit	ID_EXE_o[274:211]	PC address
		// data	
		rf_rs1_data_w, 					// 64bit	ID_EXE_o[210:147]
		rf_rs2_data_w, 					// 64bit	ID_EXE_o[146:83]
		Imm_Gen_w, 						// 64bit 	ID_EXE_o[82:19]
		// ALU fun
		{IF_ID_o[30],IF_ID_o[14:12]}, 	// 4bit		ID_EXE_o[18:15]		ALU function
		IF_ID_o[11:7], 					// 5bit		ID_EXE_o[14:10]		Rd
		IF_ID_o[19:15],					// 5bit		ID_EXE_o[9:5]		Rs1
		IF_ID_o[24:20] 					// 5bit		ID_EXE_o[4:0]		Rs2
	}),
	.data_o(ID_EXE_o)
	);
				
//Instantiate the components in EX stage	   
ALU ALU(
	.src1_i(ForwardA_res_w),
	.src2_i(mux_alusrc_w),
	.ctrl_i(alu_control_w),
	.result_o(alu_result_w),
	.zero_o(alu_zero_w)
	);
		
MUX_3to1 #(.size(64)) Mux3_1(
	.data0_i(ID_EXE_o[210:147]),	// rf_rs1_data_w
	.data1_i(mux_dataMem_result_w),	// WB mux data
	.data2_i(EXE_MEM_o[132:69]), 	// EXE/MEM alu_result_w
	.select_i(ctrl_ForwardA_mux),
	.data_o(ForwardA_res_w)
    );
		
MUX_3to1 #(.size(64)) Mux3_2(
	.data0_i(ID_EXE_o[146:83]),		// rf_rs2_data_w
	.data1_i(mux_dataMem_result_w),	// WB mux data
	.data2_i(EXE_MEM_o[132:69]),  	// EXE/MEM alu_result_w
	.select_i(ctrl_ForwardB_mux),
	.data_o(ForwardB_res_w)
    );
		
ALU_Ctrl AC(
	.funct_i(ID_EXE_o[18:15]),
	.ALUOp_i(ID_EXE_o[276:275]),
	.ALUCtrl_o(alu_control_w)
	);

MUX_2to1 #(.size(64)) Mux1(
	.data0_i(ForwardB_res_w),
	.data1_i(ID_EXE_o[82:19]), 	// ID/EXE Imm_Gen_w
	.select_i(ID_EXE_o[277]),	// ctrl_alu_mux_w
	.data_o(mux_alusrc_w)
    );
				
Shift_Left_One_64 Shifter(
	.data_i(ID_EXE_o[82:19]), // ID/EXE Imm_Gen_w
	.data_o(shift_left_w)
	); 	
		
Adder Add_pc2(
	.src1_i(ID_EXE_o[274:211]), // PC
	.src2_i(shift_left_w),
	.sum_o(add2_sum_w)
	);

//You need to instantiate many pipe_reg
Pipe_Reg #(.size(203)) EX_MEM(
	.rst_i(rst_i),
	.clk_i(clk_i),
	.data_i({
	// WB					// size		addr				mean
	ID_EXE_o[282],			// 1bit		EXE_MEM_o[202]		ctrl_register_write_w
	ID_EXE_o[281],			// 1bit		EXE_MEM_o[201]		ctrl_mem_mux_w

	// M
	ID_EXE_o[280],			// 1bit		EXE_MEM_o[200]		ctrl_branch_w
	ID_EXE_o[279],			// 1bit		EXE_MEM_o[199]		ctrl_mem_read_w
	ID_EXE_o[278],			// 1bit		EXE_MEM_o[198]		ctrl_mem_write_w

	// branch target PC
	add2_sum_w,				// 64bit	EXE_MEM_o[197:134]

	// ALU result
	alu_zero_w,				// 1bit		EXE_MEM_o[133]
	alu_result_w,				// 64bit	EXE_MEM_o[132:69] 跑到地72bit

	ID_EXE_o[146:83],		// 64bit	EXE_MEM_o[68:5]		rf_rs2_data_w
	ID_EXE_o[14:10]			// 5bit		EXE_MEM_o[4:0]		rd
	}),
	.data_o(EXE_MEM_o));	

//Instantiate the components in MEM stage
					  // ctrl_branch	 alu_zero_w
assign and_result_w = EXE_MEM_o[200] && EXE_MEM_o[133];

Data_Mem DM(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.addr_i(EXE_MEM_o[132:69]), // alu_result_w
	.data_i(EXE_MEM_o[68:5]),	// rf_rs2_data_w
	.MemRead_i(EXE_MEM_o[199]), // ctrl_mem_read_w
	.MemWrite_i(EXE_MEM_o[198]), // ctrl_mem_write_w
	.data_o(dataMem_read_w)
	);

Pipe_Reg #(.size(135)) MEM_WB(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.data_i({
	// WB				// size		addr			mean
	EXE_MEM_o[202],		// 1bit		MEM_WB_o[134]	ctrl_register_write_w
	EXE_MEM_o[201],		// 1bit		MEM_WB_o[133]	ctrl_mem_mux_w

	dataMem_read_w,		// 64bit	MEM_WB_o[132:69]
	EXE_MEM_o[132:69],	// 64bit	MEM_WB_o[68:5]	alu_result_w
	EXE_MEM_o[4:0]		// 5bit		MEM_WB_o[4:0]	rd
	}),
	.data_o(MEM_WB_o)
	);

//Instantiate the components in WB stage
MUX_2to1 #(.size(64)) Mux2(
	.data0_i(MEM_WB_o[68:5]),	// alu_result_w
	.data1_i(MEM_WB_o[132:69]),	// dataMem_read_w
	.select_i(MEM_WB_o[133]),	// ctrl_mem_mux_w
	.data_o(mux_dataMem_result_w)
    );

/****************************************
*           Signal assignment           *
****************************************/
	
endmodule

