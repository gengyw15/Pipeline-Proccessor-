
module Control(Flush,PCK,IRQ,OpCode,Funct,RegWrite,RegDst,
				MemRead,MemWrite,MemtoReg,ALUSrc1, ALUSrc2, 
				ExtOp, LuOp,ALUFun,sign,Branch);

	input				PCK,IRQ,Flush;
	input		[5:0]	OpCode,Funct;
	output	reg [1:0]	RegDst;
	output	reg 		RegWrite;
	output	reg 		ALUSrc1;
	output	reg 		ALUSrc2;
	output	reg [5:0]	ALUFun;
	output	reg 		sign;
	output	reg 		MemWrite;
	output	reg 		MemRead;
	output	reg [1:0]	MemtoReg;
	output	reg 		ExtOp;
	output	reg 		LuOp;
	output 	reg  		Branch;

	parameter	Add = 6'd0;
	parameter	Sub = 6'd1;
	parameter	And = 6'b011000;
	parameter	Or 	= 6'b011110;
	parameter	Xor = 6'b010110;
	parameter	Nor = 6'b010001;
	parameter	A 	= 6'b011010;
	parameter	Sll = 6'b100000;
	parameter	Srl = 6'b100001;
	parameter	Sra = 6'b100011;
	parameter	Eq	= 6'b110011;
	parameter	Neq	= 6'b110001;
	parameter	Lt	= 6'b110101;
	parameter	Lez = 6'b111101;
	parameter	Ltz = 6'b111011;
	parameter	Gtz = 6'b111111;

	always @(*) 
	begin 
		if(IRQ && ~PCK && ~Flush) begin
			RegDst = 2'b11;
		end
		else
		begin
			case (OpCode)
				6'h23,6'h0f,6'h08,6'h09,6'h0c,6'h0a,6'h0b,6'h0d:
					RegDst = 2'b01;
				6'h03:
					RegDst = 2'b10;
				6'h00:
				begin
					case (Funct)
						6'h20,6'h21,6'h22,6'h23,6'h24,6'h25,6'h26,6'h27,6'h00,6'h02,6'h03,6'h2a,6'h09:
							RegDst = 2'b00;
						default : 
							RegDst = 2'b11;
					endcase
				end
				default : 
					RegDst = 2'b11;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			RegWrite = 1;
		end
		else
		begin
			case (OpCode)
				6'h2b,6'h02,6'h04,6'h05,6'h06,6'h07,6'h01:
					RegWrite = 0;
				6'h23,6'h0f,6'h08,6'h09,6'h0c,6'h0d,6'h0a,6'h0b,6'h03:
					RegWrite = 1;
				6'h00:
				begin
					case (Funct)
						6'h08:
							RegWrite = 0;
						6'h20,6'h21,6'h22,6'h23,6'h24,6'h25,6'h26,6'h27,6'h00,6'h02,6'h03,6'h2a,6'h09:
							RegWrite = 1;
						default : 
							RegWrite = 1;
					endcase
				end
				default : 
					RegWrite = 1;
			endcase
		end
		if(IRQ && ~PCK && ~Flush) begin
			ALUSrc1 = 1;
		end
		else
		begin
			case (OpCode)
				6'h00:
				begin 
					case (Funct)
						6'h00,6'h02,6'h03:
							ALUSrc1 = 1;
						default : 
							ALUSrc1 = 0;
					endcase
				end
				default :   ALUSrc1 = 0;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			ALUSrc2 = 1;
		end
		else
		begin
			case (OpCode)
				6'h23,6'h2b,6'h0f,6'h08,6'h09,6'h0c,6'h0d,6'h0a,6'h0b:
					ALUSrc2 = 1;
				default : ALUSrc2 = 0;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			ALUFun = 5'd0;
		end
		else
		begin
			case (OpCode)
				6'h23,6'h2b,6'h0f,6'h08,6'h09:
					ALUFun = Add;
				6'h0c:
					ALUFun = And;
				6'h0d:
					ALUFun = Or;
				6'h0a,6'h0b:
					ALUFun = Lt;
				6'h04:
					ALUFun = Eq;
				6'h05:
					ALUFun = Neq;
				6'h06:
					ALUFun = Lez;
				6'h07:
					ALUFun = Gtz;
				6'h01:
					ALUFun = Ltz;
				6'h00:
				begin
					case (Funct)
						6'h20,6'h21:
							ALUFun = Add;
						6'h22,6'h23:
							ALUFun = Sub;
						6'h24:
							ALUFun = And;
						6'h25:
							ALUFun = Or;
						6'h26:
							ALUFun = Xor;
						6'h27:
							ALUFun = Nor;
						6'h00:
							ALUFun = Sll;
						6'h02:
							ALUFun = Srl;
						6'h03:
							ALUFun = Sra;
						6'h2a:
							ALUFun = Lt;
						default : 
							ALUFun = 5'd0;
					endcase
				end
				default :   ALUFun = 5'd0;
			endcase
		end
		if(IRQ && ~PCK && ~Flush) begin
			sign = 0;
		end
		else
		begin
			case (OpCode)
				6'h23,6'h2b,6'h09,6'h0b:
					sign = 0;
				6'h00:
				begin
					case (Funct)
						6'h21,6'h23:
							sign = 0;
						default : sign = 1;
					endcase
				end
				default : sign = 1;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			MemWrite = 0;
		end
		else
		begin
			case (OpCode)
				6'h2b:
					MemWrite = 1;
				default : MemWrite = 0;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			MemRead = 0;
		end
		else
		begin
			case (OpCode)
				6'h23:
					MemRead = 1;
				default : MemRead = 0;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			MemtoReg = 2'b10;
		end
		else
		begin
			case (OpCode)
				6'h03:
					MemtoReg = 2'b10;
				6'h00:
				begin
					case (Funct)
						6'h09:
							MemtoReg = 2'b10;
						6'h20,6'h21,6'h22,6'h23,6'h24,6'h25,6'h26,6'h27,6'h00,6'h02,6'h03,6'h2a,6'h08:
							MemtoReg = 2'b00;
						default : MemtoReg = 2'b10;
					endcase
				end
				6'h23:
					MemtoReg = 2'b01;
				6'h0f,6'h08,6'h09,6'h0c,6'h0a,6'h0b,6'h0d:
					MemtoReg = 2'b00;
				default : MemtoReg = 2'b10;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			ExtOp = 0;
		end
		else
		begin
			case (OpCode)
				6'h23,6'h2b,6'h08,6'h09,6'h0a,6'h0b,6'h04,6'h05,6'h06,6'h07,6'h01:
					ExtOp = 1;
				6'h0c,6'h0d:
					ExtOp = 0;
				default : ExtOp = 0;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			LuOp = 0;
		end
		else
		begin
			case (OpCode)
				6'h0f:
					LuOp = 1;
				default : LuOp = 0;
			endcase
		end

		if(IRQ && ~PCK && ~Flush) begin
			Branch = 0;
		end
		else
		begin
			case (OpCode)
				6'h04,6'h05,6'h06,6'h07,6'h01:
					Branch = 1;
				default : Branch = 0;
			endcase
		end
	end
	
endmodule
