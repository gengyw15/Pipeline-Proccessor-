//ALU单元（有没有必要把逻辑运算也写进来，那么写的话有什么好处吗）
//输入：a，b，加减法ALUFun【0】，上一位的进位carryin
//输出：结果，进位
module ALUunit (alufun,a,b,carryin,result,carryout);
	input	a,b,alufun,carryin;
	output	reg		result,carryout;

	always @(*) 
	begin 
		if(alufun == 1)//减法
		begin
			if(a == 1&&b == 0)
			begin
				result = carryin;
				carryout = 1;
			end
			else if(a == 0&&b == 1)
			begin
				result = carryin;
				carryout = 0;
			end
			else
			begin
				if(carryin == 1) 
				begin
					result = 0;
					carryout = 1;
				end
				else
				begin
					result = 1;
					carryout = 0;
				end

			end
		end
		else
		begin
			if(a == 1&&b == 1)
			begin
				result = carryin;
				carryout = 1;
			end
			else if(a == 0&&b == 0)
			begin
				result = carryin;
				carryout = 0;
			end
			else
			begin
				if(carryin == 1) 
				begin
					result = 0;
					carryout = 1;
				end
				else
				begin
					result = 1;
					carryout = 0;
				end

			end
		end
	end
endmodule

//算术
//输入：A,B，符号s，ALUFun最后一位
//输出：zero,overflow,negative,result
module AddSub (s,A,B,alufun,result,zero,overflow,negative);
	input			s,alufun;
	input	[31:0]	A,B;
	output	[31:0]	result;
	output			zero,overflow,negative;
	wire	[31:0]	CO;

	ALUunit alu0(alufun,A[0],B[0],alufun,result[0],CO[0]);
	ALUunit alu1(alufun,A[1],B[1],CO[0],result[1],CO[1]);
	ALUunit alu2(alufun,A[2],B[2],CO[1],result[2],CO[2]);
	ALUunit alu3(alufun,A[3],B[3],CO[2],result[3],CO[3]);
	ALUunit alu4(alufun,A[4],B[4],CO[3],result[4],CO[4]);
	ALUunit alu5(alufun,A[5],B[5],CO[4],result[5],CO[5]);
	ALUunit alu6(alufun,A[6],B[6],CO[5],result[6],CO[6]);
	ALUunit alu7(alufun,A[7],B[7],CO[6],result[7],CO[7]);
	ALUunit alu8(alufun,A[8],B[8],CO[7],result[8],CO[8]);
	ALUunit alu9(alufun,A[9],B[9],CO[8],result[9],CO[9]);
	ALUunit alu10(alufun,A[10],B[10],CO[9],result[10],CO[10]);
	ALUunit alu11(alufun,A[11],B[11],CO[10],result[11],CO[11]);
	ALUunit alu12(alufun,A[12],B[12],CO[11],result[12],CO[12]);
	ALUunit alu13(alufun,A[13],B[13],CO[12],result[13],CO[13]);
	ALUunit alu14(alufun,A[14],B[14],CO[13],result[14],CO[14]);
	ALUunit alu15(alufun,A[15],B[15],CO[14],result[15],CO[15]);
	ALUunit alu16(alufun,A[16],B[16],CO[15],result[16],CO[16]);
	ALUunit alu17(alufun,A[17],B[17],CO[16],result[17],CO[17]);
	ALUunit alu18(alufun,A[18],B[18],CO[17],result[18],CO[18]);
	ALUunit alu19(alufun,A[19],B[19],CO[18],result[19],CO[19]);
	ALUunit alu20(alufun,A[20],B[20],CO[19],result[20],CO[20]);
	ALUunit alu21(alufun,A[21],B[21],CO[20],result[21],CO[21]);
	ALUunit alu22(alufun,A[22],B[22],CO[21],result[22],CO[22]);
	ALUunit alu23(alufun,A[23],B[23],CO[22],result[23],CO[23]);
	ALUunit alu24(alufun,A[24],B[24],CO[23],result[24],CO[24]);
	ALUunit alu25(alufun,A[25],B[25],CO[24],result[25],CO[25]);
	ALUunit alu26(alufun,A[26],B[26],CO[25],result[26],CO[26]);
	ALUunit alu27(alufun,A[27],B[27],CO[26],result[27],CO[27]);
	ALUunit alu28(alufun,A[28],B[28],CO[27],result[28],CO[28]);
	ALUunit alu29(alufun,A[29],B[29],CO[28],result[29],CO[29]);
	ALUunit alu30(alufun,A[30],B[30],CO[29],result[30],CO[30]);
	ALUunit alu31(alufun,A[31],B[31],CO[30],result[31],CO[31]);
	
	assign overflow = s?(CO[30]^CO[31]):0;
	assign zero = ~|result;
	assign negative = s?result[31]:~CO[31];
endmodule

//比较
//输入：zero,overflow,negative,alufun【3:1】
//输出：result
module CMP(sign,zero,overflow,negative,alufun,result);
	input				zero,overflow,negative,sign;
	input		[2:0]	alufun;
	output	reg	[31:0]	result;
			wire		n_negative;

	parameter	EQ = 3'b001;
	parameter	NEQ = 3'b000;
	parameter	LT = 3'b010;
	parameter	LEZ = 3'b110;
	parameter	LTZ = 3'b101;
	parameter	GTZ = 3'b111;

	
	assign	n_negative = sign?overflow^negative:negative;
	always @(*)
	begin
		
		case(alufun)
			EQ:result = zero?32'd1:0;
			NEQ:result = zero?0:32'd1;
			LT:result = n_negative?32'd1:0;
			LEZ:result = (zero||n_negative)?32'd1:0;
			LTZ:result = n_negative?32'd1:0;
			GTZ:result = ~(zero||n_negative)?32'd1:0;
			
			default:result = 0;
		endcase
	end
endmodule

//输入：A，B，ALUFun【3:0】
//输出：
//逻辑运算

module Logic(A,B,alufun,result);
	input		[31:0]	A,B;
	input		[3:0]	alufun;
	output	reg	[31:0]	result;

	parameter	AND = 4'b1000;
	parameter	OR	= 4'b1110;
	parameter	XOR	= 4'b0110;
	parameter	NOR	= 4'b0001;
	parameter	a= 4'b1010;

	
	always @(*)
	begin
		case(alufun)
			AND:result = A&B;
			OR:	result = A|B;
			XOR:result = A^B;
			NOR:result = ~(A|B);
			a:result = A;
			default:result = 31'd0;
		endcase // alufun
	end
endmodule

//移位
//输入：A,B，ALUFun【1:0】
//输出：
module Shift(A,B,alufun,result);
	input		[31:0]	A,B;
	input		[1:0]	alufun;
	output	reg	[31:0]	result;

	parameter	SLL = 2'b00;
	parameter	SRL = 2'b01;
	parameter	SRA = 2'b11;

	

	always @(*)
	begin
		if(A[4] == 1)
		begin
			case(alufun)
				SLL:result = B<<16;
				SRL:result = B>>16;
				SRA:result = B>>>16;
				default:result = B<<16;
			endcase
		end
		else
			result = B;

		if(A[3] == 1)
		begin 
			case(alufun)
				SLL:result = result<<8;
				SRL:result = result>>8;
				SRA:result = result>>>8;
				default:result = result<<8;
			endcase
		end
		else
			result = result;

		if(A[2] == 1)
		begin 
			case(alufun)
				SLL:result = result<<4;
				SRL:result = result>>4;
				SRA:result = result>>>4;
				default:result = result<<4;
			endcase
		end
		else
			result = result;

		if(A[1] == 1)
		begin 
			case(alufun)
				SLL:result = result<<2;
				SRL:result = result>>2;
				SRA:result = result>>>2;
				default:result = result<<2;
			endcase
		end
		else
			result = result;

		if(A[0] == 1)
		begin 
			case(alufun)
				SLL:result = result<<1;
				SRL:result = result>>1;
				SRA:result = result>>>1;
				default:result = result<<1;
			endcase
		end
		else
			result =result;
	end
endmodule