module s_processor (reset,clk50,clk,switch,UART_rxd,led,digi_out1,digi_out2,digi_out3,digi_out4,UART_txd);
	input	reset,clk50,clk;
	reg		[31:0]	PC;
	wire 	[31:0] PC_next;
	wire [31:0] PC_plus_4;
	wire [31:0] Instruction;
//控制
	wire [1:0] RegDst;
	wire [2:0] PCSrc;
	wire [1:0] MemtoReg;
	wire ExtOp;
	wire LuOp;
	wire MemWrite;
	wire MemRead;
	wire ALUSrc1;
	wire ALUSrc2;
	wire RegWrite;
	wire [5:0]	ALUFun;
	wire sign;
//寄存器
	wire [4:0]	addr3;
	wire [31:0]	DataBusA,DataBusB,data3;
//右移左移beq地址
	wire [31:0] Ext_out;
	wire [31:0] LU_out;
	wire [31:0]	ConBA;
//ALU运算
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [31:0] ALU_out;
//存储器
	wire [31:0] Read_data1;
	wire [31:0]	Read_data2;
	wire 		IRQ;
//存储器指令选择，分支，跳转
	wire [31:0]	Read_data;
	wire [31:0]	Branch_target;
	wire [31:0]	Jump_target;

	output	[7:0]	led;
	wire [11:0]	digi;
	input [7:0]	switch;
	input UART_rxd;
	output UART_txd;
	output [6:0] digi_out1;	//0: CG,CF,CE,CD,CC,CB,CA
	output [6:0] digi_out2;	//1: CG,CF,CE,CD,CC,CB,CA
	output [6:0] digi_out3;	//2: CG,CF,CE,CD,CC,CB,CA
	output [6:0] digi_out4;	//3: CG,CF,CE,CD,CC,CB,CA

	parameter	ILLOP = 32'h80000004;
	parameter	XADR = 32'h80000008;
	parameter	Ra = 5'd31;
	parameter	Xp = 5'd26;

	wire 	[4:0]	Rd,Rt,Rs,Shamt;
	wire 	[15:0]	Imm16;
	wire 	[25:0]	Jt;
	

	initial
	begin
		PC = 32'h00000000;
	end
//获取PC值
	
	always @(negedge reset or posedge clk)
	begin
		if (~reset)
			PC <= 32'h80000000;
		else
			PC <= PC_next;
	end 

	
	assign PC_plus_4 = PC + 32'd4;

//从PC中读取指令
	
	ROM ROM1(.addr(PC),.data(Instruction));
	assign	Rs    = Instruction[25:21];
	assign	Rt 	  = Instruction[20:16];
	assign 	Rd 	  = Instruction[15:11];
	assign	Shamt = Instruction[10:6];
	assign	Imm16 = Instruction[15:0];
	assign	Jt 	  = Instruction[25:0];
//产生控制信号(ALU控制信号也是这里产生的)
	
	
	Control control1(.PCK(PC[31]),.IRQ(IRQ),
		.OpCode(Instruction[31:26]), .Funct(Instruction[5:0]),
		.PCSrc(PCSrc), .RegWrite(RegWrite), .RegDst(RegDst), 
		.MemRead(MemRead),	.MemWrite(MemWrite), .MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(ExtOp), .LuOp(LuOp),
		.ALUFun(ALUFun),.sign(sign));

//寄存器堆的读写
//输出：DataBusA和data2
	
	assign addr3 = (RegDst == 2'b00)?Instruction[15:11]:(RegDst == 2'b01)?Instruction[20:16]:(RegDst == 2'b10)?Ra:Xp;//buqueding
	RegFile regfile1(.reset(reset),.clk(clk),.wr(RegWrite),.addr1(Rs),.addr2(Rt),.addr3(addr3),.data3(data3),.data1(DataBusA),.data2(DataBusB));

//右移
	
	assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]}; //把{i[15]}重复16遍，把{，}连接起来

//左移
	
	assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;


//beq地址计算 buqueding
	
	assign ConBA = PC_plus_4 + (Ext_out<<2);

//ALU运算
	
	assign ALU_in1 = ALUSrc1? {27'h00000, Instruction[10:6]}: DataBusA;//buqueding为什么是22位的shamt
	assign ALU_in2 = ALUSrc2? LU_out: DataBusB;
	ALU alu1(.A(ALU_in1), .B(ALU_in2), .ALUFun(ALUFun), .sign(sign), .result(ALU_out));

//选择外设部分还是数据部分
	
	assign	MemRead1	= (ALU_out[30])?0:MemRead;
	assign	MemWrite1	= (ALU_out[30])?0:MemWrite;
	assign	MemRead2	= (ALU_out[30])?MemRead:0;
	assign	MemWrite2	= (ALU_out[30])?MemWrite:0;
//存储器
	
	DataMemory data_memory1(.reset(reset), .clk(clk), .rd(MemRead1), .wr(MemWrite1), .addr(ALU_out), .wdata(DataBusB), .rdata(Read_data1));
//与存储器并列的外设控制器
	
	Peripheral Peripheral(.sysclk(clk50),.reset(reset),.clk(clk50),.rd(MemRead2),.wr(MemWrite2),.addr(ALU_out),.wdata(DataBusB),.rdata(Read_data2),.led(led),.switch(switch),.digi(digi),.irqout(IRQ),.UART_rxd(UART_rxd),.UART_txd(UART_txd));
	digitube_scan digitube_scan1(.digi_in(digi),.digi_out1(digi_out1),.digi_out2(digi_out2),.digi_out3(digi_out3),.digi_out4(digi_out4));
//选择存储器数据
	
	assign	Read_data = ALU_out[30]?Read_data2:Read_data1;
//产生寄存器data3（要写的数据）
	assign data3 = (MemtoReg == 2'b00)?ALU_out:(MemtoReg == 2'b01)?Read_data:PC_plus_4;

//分支指令的选择  
	
	assign 	Branch_target = (ALU_out[0])?ConBA:PC_plus_4;

//Jump_target
	
	assign	Jump_target = {PC[31:28],Instruction[25:0],2'b00};

//PC值选择
	assign PC_next = (PCSrc == 3'b000)? PC_plus_4:(PCSrc == 3'b001)?Branch_target:(PCSrc == 3'b010)?  Jump_target:(PCSrc == 3'b011)? DataBusA:(PCSrc == 3'b100)?ILLOP:XADR;


endmodule
