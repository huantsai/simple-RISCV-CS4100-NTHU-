VLOG = ncverilog
WAV = +access+r
Test = Test_Bench.v
CPU = Simple_Single_CPU.v
Mem = Data_Mem.v Reg_File.v Instr_Mem.v
ALU = Adder.v ALU.v ALU_Ctrl.v Control.v MUX_2to1.v ProgramCounter.v Shift_Left_One_64.v Imm_Gen.v
all:
	$(VLOG) $(CPU) $(Mem) $(ALU) $(Test) $(WAV)