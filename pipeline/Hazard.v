module HazardDetectionUnit(Flush,PCK,IRQ,Rs,Rt,ID_EX_MemRead,ID_EX_Rt,OpCode,Funct,ID_EX_Branch,ALUout,PCSrc,IF_ID_Write,ID_flush,IF_flush,EX_flush);
	input		[4:0]	Rs,Rt,ID_EX_Rt;
	input				ID_EX_MemRead,IRQ,ALUout,PCK,Flush,ID_EX_Branch;
	input		[5:0]	OpCode,Funct;
	output	reg			IF_ID_Write,ID_flush,IF_flush,EX_flush;
	output	reg	[2:0]	PCSrc;
			reg			excep1;

	always @(*)
	begin 
		case (OpCode)
			6'h04,6'h05,6'h06,6'h07,6'h01,6'h02,6'h03,6'h23,6'h2b,6'h0f,6'h08,6'h09,6'h0c,6'h0a,6'h0b,6'h0d:
				excep1 = 0;
			6'h00:
				begin
					case (Funct)
						6'h08,6'h09,6'h20,6'h21,6'h22,6'h23,6'h24,6'h25,6'h26,6'h27,6'h00,6'h02,6'h03,6'h2a:
							excep1 = 0;
						default :
							excep1 = 1;
					endcase
				end	
			default : excep1 = 1;
		endcase

	end
	always @(*) 
	begin 
		if(ID_EX_Branch && ALUout)
		begin
				PCSrc = 3'd1;
				IF_flush = 1;
				ID_flush = 1;
				IF_ID_Write = 1;
				EX_flush = 0;
		end
		else
		begin
			if(IRQ && ~PCK && ~Flush)
			begin
				PCSrc = 3'b100;
				IF_flush = 1;
				ID_flush = 0;
				EX_flush = 0;
				IF_ID_Write = 1;
			end
			else if(ID_EX_MemRead&&((ID_EX_Rt == Rs)||(ID_EX_Rt == Rt)))//LU
			begin
				PCSrc = 3'd6;
				IF_ID_Write = 0;
				ID_flush = 1;
				IF_flush = 0;
				EX_flush = 0;
			end
			else if(OpCode == 6'd2 || OpCode == 6'd3)
			begin
				PCSrc = 3'd2;
				IF_flush = 1;
				IF_ID_Write = 1;
				ID_flush = 0;
				EX_flush = 0;
			end
			else if((OpCode == 6'd0 && Funct == 6'd8)||(OpCode == 0 && Funct == 6'd9))
			begin
				PCSrc = 3'd3;
				IF_flush = 1;
				IF_ID_Write = 1;
				ID_flush = 0;
				EX_flush = 0;
			end
			
			else if(excep1)
			begin
				PCSrc = 3'd5;
				IF_ID_Write = 1;
				ID_flush = 0;
				IF_flush = 1;
				EX_flush = 0;
			end
			else
			begin
				PCSrc = 0;
				IF_ID_Write = 1;
				IF_flush = 0;
				ID_flush = 0;
				EX_flush = 0;
			end
		end
	end
endmodule // Hazard