//输入：A,B，ALU功能码，sign（符号扩展）
//输出:result

module ALU (A,B,ALUFun,sign,result);
	input	[31:0]	A,B;
	input	[5:0]	ALUFun;
	input			sign;
	output	[31:0]	result;
	wire	[31:0]	result00,result11,result01,result10;
	wire			zero,overflow,negative;
	
	AddSub	addsub(.s(sign),.A(A),.B(B),.alufun(ALUFun[0]),.result(result00),.zero(zero),.overflow(overflow),.negative(negative));
	CMP		cmp(.sign(sign),.zero(zero),.overflow(overflow),.negative(negative),.alufun(ALUFun[3:1]),.result(result11));
	Logic	logic(.A(A),.B(B),.alufun(ALUFun[3:0]),.result(result01));
	Shift	shift(.A(A),.B(B),.alufun(ALUFun[1:0]),.result(result10));

	assign	result = (ALUFun[5:4] == 2'b00)?result00:(ALUFun[5:4] == 2'b11)?result11:(ALUFun[5:4] == 2'b01)?result01:result10;
	
endmodule

