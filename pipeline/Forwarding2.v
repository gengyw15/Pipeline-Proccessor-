module Forwarding_Unit2 (ID_EX_Rs,ID_EX_Rt,EX_MEM_Rd,MEM_WB_Rd,EX_MEM_RegWrite,MEM_WB_RegWrite,Select_ALUin1,Select_ALUin2);
	input		[4:0]	ID_EX_Rs,ID_EX_Rt,EX_MEM_Rd,MEM_WB_Rd;
	input				EX_MEM_RegWrite,MEM_WB_RegWrite;
	output	reg [1:0]	Select_ALUin1,Select_ALUin2;

	always @(*)
	begin
		if((EX_MEM_RegWrite == 1) && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs))
			Select_ALUin1 = 2'd1;
		else if((MEM_WB_RegWrite == 1) && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rs))
			Select_ALUin1 = 2'd2;
		else
			Select_ALUin1 = 0;
	end 

	always @(*)
	begin
		if((EX_MEM_RegWrite == 1) && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rt)) 
		begin
			Select_ALUin2 = 2'd1;
		end
		else if((MEM_WB_RegWrite == 1) && (MEM_WB_Rd != 0) && (MEM_WB_Rd == ID_EX_Rt))
			Select_ALUin2 = 2'd2;
		else
			Select_ALUin2 = 0;
	end 
endmodule