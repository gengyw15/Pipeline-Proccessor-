module Forwarding_Unit1(OpCode,Funct,Rs,ID_EX_RegWrite,EX_MEM_RegWrite,ID_EX_Write_Addr,EX_MEM_Write_Addr,Select_3,Select_ALU);
	input		[4:0]	Rs,ID_EX_Write_Addr,EX_MEM_Write_Addr;
	input		[5:0]	OpCode,Funct;
	input				ID_EX_RegWrite,EX_MEM_RegWrite;
	output	reg [1:0]	Select_3;
	output  reg         Select_ALU;

	always @(*) 
	begin 
		if(ID_EX_RegWrite &&(ID_EX_Write_Addr != 0)&&(Rs == ID_EX_Write_Addr))
		begin
			Select_3 = 2'd1;
		end
		else if(EX_MEM_RegWrite &&(EX_MEM_Write_Addr != 0)&&(Rs == EX_MEM_Write_Addr))
		begin
			Select_3 = 2'd2;
		end
		else
		begin
			Select_3 = 0;
		end

		if(OpCode == 6'd3) 
			Select_ALU = 1;
		else if((OpCode == 6'd0) && (Funct == 6'd9))
			Select_ALU = 1;
		else 
			Select_ALU = 0;
	end
endmodule // Forwarding_Unit1