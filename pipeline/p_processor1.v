
module p_processor (reset,clk,switch,UART_rxd,led,digi_out1,digi_out2,digi_out3,digi_out4,UART_txd);
	input			reset,clk,UART_rxd;
	input	[7:0]	switch;
	output	[7:0]	led;
	wire	[11:0]	digi;
	output  [6:0]	digi_out1;	//0: CG,CF,CE,CD,CC,CB,CA
	output  [6:0] 	digi_out2;	//1: CG,CF,CE,CD,CC,CB,CA
	output  [6:0] 	digi_out3;	//2: CG,CF,CE,CD,CC,CB,CA
	output  [6:0] 	digi_out4;	//3: CG,CF,CE,CD,CC,CB,CA
	output			UART_txd;
	wire  			IRQ;
	reg		[31:0]	PC;
	wire 	[31:0] 	PC_next;
	wire 	[31:0]	PC_plus_4;
	wire 	[31:0]	Instruction;
//IF_ID
	reg		[31:0]	IF_ID_PC_plus_4,IF_ID_Instruction,IF_ID_PC;
	reg 			IF_ID_flush;
//dingyi

	wire 	[5:0]	OpCode,Funct;
	wire 	[4:0]	Rd,Rt,Rs,Shamt;
	wire 	[15:0]	Imm16;
	wire 	[25:0]	Jt;
//Hazard_detection
//control
	wire	[1:0]	RegDst;
	wire			RegWrite;
	wire 			ALUSrc1;
	wire 			ALUSrc2;
	wire 	[5:0]	ALUFun;
	wire 			Sign;
	wire 			MemWrite;
	wire 			MemRead;
	wire 	[1:0]	MemToReg;
	wire 			Extop;
	wire 			Luop;
	wire 			Branch;
//寄存器堆
	wire [4:0]	addr3;
	wire [31:0]	DataBus1,DataBus2,DataBusA,DataA;
//右移左移beq地址
	wire [31:0] Ext_out;
	wire [31:0] LU_out;
	wire [31:0]	ConBA;
//ID_EX
	reg	[31:0]	ID_EX_PC_plus_4,ID_EX_DataBus2,ID_EX_DataA,ID_EX_LU_out,ID_EX_Branch_Addr;
	reg [4:0]	ID_EX_Rs,ID_EX_Rt,ID_EX_Rd;
	reg [5:0]	ID_EX_OpCode,ID_EX_Funct;
	reg [4:0]	ID_EX_Write_Addr;
	reg			ID_EX_RegWrite;
	reg [5:0]	ID_EX_ALUFun;
	reg 		ID_EX_Sign;
	reg 		ID_EX_Branch;
	reg 		ID_EX_MemWrite;
	reg 		ID_EX_MemRead;
	reg [1:0]	ID_EX_MemToReg;
	reg 		ID_EX_ALUSrc2;
//冒险探测的输出
	wire [2:0]	PCSrc;
	wire 		IF_ID_Write,ID_flush,IF_flush,EX_flush;
//两个转发
	wire 		Select_ALU;
	wire [1:0]	Select_3;
	wire [1:0]	Select_ALUin1,Select_ALUin2;
//ALU输入
	wire [31:0]	ALUin1;
	wire [31:0]	ALUin2;
	wire [31:0]	DataB;
	wire [31:0]	ALUout;
	wire [31:0]	ALUout1;
//EX_MEM
	reg	[31:0]	EX_MEM_PC_plus_4,EX_MEM_ALUout,EX_MEM_DataBusB;
	reg [4:0]	EX_MEM_Write_Addr;	
 	reg [4:0]	EX_MEM_Rd;
	reg			EX_MEM_RegWrite;
	reg 		EX_MEM_MemWrite;
	reg 		EX_MEM_MemRead;
	reg [1:0]	EX_MEM_MemToReg;
//存储器
	wire [31:0]	Read_Data1,Read_DataA,Read_DataB,Read_Data;
	wire 		MemRead1,MemRead2,MemWrite1,MemWrite2;
//MEM_WB
	reg [31:0]	MEM_WB_Read_Data;
	reg [4:0]	MEM_WB_Write_Addr;
	reg [4:0]	MEM_WB_Rd;
	reg 		MEM_WB_RegWrite;
//PC_beq_地址
	wire [31:0]	Jump_target;

	parameter	RESETPC = 32'h80000000;
	parameter	ILLOP 	= 32'h80000004;
	parameter	XADR 	= 32'h80000008;
	parameter	Ra 		= 5'd31;
	parameter	Xp 		= 5'd26;

	initial
	begin
		PC = 32'd0;
		IF_ID_PC_plus_4 = 32'd0;
		IF_ID_PC = 0;
		IF_ID_Instruction = 32'd0;
		IF_ID_flush = 0;
		ID_EX_PC_plus_4 = 32'd0;
		ID_EX_DataBus2 = 32'd0;
		ID_EX_DataA = 32'd0;
		ID_EX_LU_out = 32'd0;
		ID_EX_Branch_Addr = 32'd0;
		ID_EX_Rs = 5'd0;
		ID_EX_Rt = 5'd0;
		ID_EX_Rd = 5'd0;
		ID_EX_OpCode = 0;
		ID_EX_Funct = 0;
		ID_EX_Write_Addr = 5'd0;
		ID_EX_ALUFun = 6'd0;
		ID_EX_RegWrite = 0;
		ID_EX_Sign = 0;
		ID_EX_MemWrite = 0;
		ID_EX_MemRead = 0;
		ID_EX_MemToReg = 0;
		ID_EX_ALUSrc2 = 0;
		EX_MEM_PC_plus_4 = 0;
		EX_MEM_ALUout = 0;
		EX_MEM_DataBusB = 0;
		EX_MEM_Write_Addr = 0;	
	 	EX_MEM_Rd = 0;
		EX_MEM_RegWrite = 0;
		EX_MEM_MemWrite = 0;
		EX_MEM_MemRead = 0;
		EX_MEM_MemToReg = 0;
		MEM_WB_Read_Data = 0;
		MEM_WB_Write_Addr = 0;
		MEM_WB_Rd = 0;
		MEM_WB_RegWrite = 0;
	end 

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

//IF/ID寄存器
	always @(posedge clk or negedge reset) 
	begin
		if(~reset) begin
			IF_ID_PC_plus_4   <= RESETPC;
			IF_ID_PC 		  <= RESETPC;
			IF_ID_Instruction <= 0;
			IF_ID_flush		  <= 0;
		end else begin
			IF_ID_PC_plus_4   <= IF_flush?0:IF_ID_Write?PC_plus_4:IF_ID_PC_plus_4;
			IF_ID_PC          <= IF_flush?0:IF_ID_Write?PC:IF_ID_PC;
			IF_ID_Instruction <= IF_flush?0:IF_ID_Write?Instruction:IF_ID_Instruction;
			IF_ID_flush  	  <= IF_flush;
		end
	end

//定义一下~~
	assign 	OpCode= IF_ID_Instruction[31:26];
	assign	Funct = IF_ID_Instruction[5:0];
	assign	Rs    = IF_ID_Instruction[25:21];
	assign	Rt 	  = IF_ID_Instruction[20:16];
	assign 	Rd 	  = IF_ID_Instruction[15:11];
	assign	Shamt = IF_ID_Instruction[10:6];
	assign	Imm16 = IF_ID_Instruction[15:0];
	assign	Jt 	  = IF_ID_Instruction[25:0];

//产生控制信号
	Control control1(.Flush(IF_ID_flush),.PCK(IF_ID_PC[31]),.IRQ(IRQ),
		.OpCode(OpCode), .Funct(Funct),
		.RegWrite(RegWrite), .RegDst(RegDst), 
		.MemRead(MemRead),	.MemWrite(MemWrite), .MemtoReg(MemToReg),
		.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ExtOp(Extop), .LuOp(Luop),
		.ALUFun(ALUFun),.sign(Sign),.Branch(Branch));

//寄存器堆
	assign addr3 = (RegDst == 2'b00)?Rd:(RegDst == 2'b01)?Rt:(RegDst == 2'b10)?Ra:Xp;
	RegFile regfile1(.reset(reset),.clk(clk),.wr(MEM_WB_RegWrite),.addr1(Rs),.addr2(Rt),.addr3(MEM_WB_Write_Addr),.data3(MEM_WB_Read_Data),.data1(DataBus1),.data2(DataBus2));
	assign DataA = ALUSrc1? {27'h00000, Shamt}: DataBus1;
	
//右移
	assign Ext_out = {Extop? {16{IF_ID_Instruction[15]}}: 16'h0000, Imm16}; //把{i[15]}重复16遍，把{，}连接起来

//左移
	assign LU_out = Luop? {IF_ID_Instruction[15:0], 16'h0000}: Ext_out;//buqueding

//beq地址计算 
	assign ConBA = IF_ID_PC_plus_4 + (Ext_out<<2);

//ID/EX寄存器
	always @(posedge clk or negedge reset) 
	begin
		if(~reset) begin
			ID_EX_PC_plus_4 	<= RESETPC;
			ID_EX_Rs			<= 0;
			ID_EX_Rt 			<= 0;
			ID_EX_Rd			<= 0;
			ID_EX_OpCode		<= 0;
			ID_EX_Funct 		<= 0;
			ID_EX_DataBus2		<= 0;
			ID_EX_DataA 		<= 0;
			ID_EX_LU_out 		<= 0;
			ID_EX_Branch_Addr 	<= 0;
			ID_EX_Write_Addr 	<= 0;
			ID_EX_ALUSrc2		<= 0;
			ID_EX_RegWrite 		<= 0;
			ID_EX_ALUFun 		<= 0;
	 		ID_EX_Sign 			<= 0;
	 		ID_EX_Branch 		<= 0;
	 		ID_EX_MemWrite 		<= 0;
	 		ID_EX_MemRead 		<= 0;
			ID_EX_MemToReg 		<= 0;
		end else begin
			ID_EX_PC_plus_4 	<= IF_ID_PC_plus_4;
			ID_EX_Rs 			<= Rs;
			ID_EX_Rt 			<= Rt;
			ID_EX_Rd 			<= Rd;
			ID_EX_OpCode		<= ID_flush?0:OpCode;
			ID_EX_Funct 		<= ID_flush?0:Funct;
			ID_EX_DataBus2		<= DataBus2;
			ID_EX_LU_out 		<= LU_out;
			ID_EX_DataA 		<= DataA;
			ID_EX_Branch_Addr 	<= ConBA;
			ID_EX_Write_Addr 	<= addr3;
			ID_EX_ALUSrc2 		<= ID_flush?0:ALUSrc2;
			ID_EX_RegWrite 		<= ID_flush?0:RegWrite;
			ID_EX_ALUFun 		<= ID_flush?0:ALUFun;
	 		ID_EX_Sign 			<= ID_flush?0:Sign;
	 		ID_EX_Branch 		<= ID_flush?0:Branch;
	 		ID_EX_MemWrite 		<= ID_flush?0:MemWrite;
	 		ID_EX_MemRead 		<= ID_flush?0:MemRead;
			ID_EX_MemToReg 		<= ID_flush?0:MemToReg;
		 	
		end
	end

//冒险探测
	HazardDetectionUnit HazardDetectionUnit1(.Flush(IF_ID_flush),.PCK(IF_ID_PC[31]),.IRQ(IRQ),.Rs(Rs),.Rt(Rt),.ID_EX_MemRead(ID_EX_MemRead),.ID_EX_Rt(ID_EX_Write_Addr),.OpCode(OpCode),.Funct(Funct),.ID_EX_Branch(ID_EX_Branch),.ALUout(ALUout[0]),.PCSrc(PCSrc),.IF_ID_Write(IF_ID_Write),.ID_flush(ID_flush),.IF_flush(IF_flush),.EX_flush(EX_flush));

//转发jr
	Forwarding_Unit1	forwarding_Unit1(.OpCode(ID_EX_OpCode),.Funct(ID_EX_Funct),.Rs(Rs),.ID_EX_RegWrite(ID_EX_RegWrite),.EX_MEM_RegWrite(EX_MEM_RegWrite),.ID_EX_Write_Addr(ID_EX_Write_Addr),.EX_MEM_Write_Addr(EX_MEM_Write_Addr),.Select_3(Select_3),.Select_ALU(Select_ALU));

//转发add
	Forwarding_Unit2	forwarding_Unit2(.ID_EX_Rs(ID_EX_Rs),.ID_EX_Rt(ID_EX_Rt),.EX_MEM_Rd(EX_MEM_Write_Addr),.MEM_WB_Rd(MEM_WB_Write_Addr),.EX_MEM_RegWrite(EX_MEM_RegWrite),.MEM_WB_RegWrite(MEM_WB_RegWrite),.Select_ALUin1(Select_ALUin1),.Select_ALUin2(Select_ALUin2));

//ALU_in的选择
	assign	ALUin1 = (Select_ALUin1 == 2'b00)?ID_EX_DataA:(Select_ALUin1 == 2'b01)?EX_MEM_ALUout:MEM_WB_Read_Data;
	assign	DataB = (Select_ALUin2 == 2'b00)?ID_EX_DataBus2:(Select_ALUin2 == 2'b01)?EX_MEM_ALUout:MEM_WB_Read_Data;
	assign  ALUin2 = (ID_EX_ALUSrc2 == 0)?DataB:ID_EX_LU_out;

//ALU
	ALU alu1(.A(ALUin1), .B(ALUin2), .ALUFun(ID_EX_ALUFun), .sign(ID_EX_Sign), .result(ALUout1));

//beq_addr
	//assign	Branch_Addr = ALUout1[0]?ID_EX_Branch_Addr:PC_plus_4;
	assign 	ALUout = Select_ALU?ID_EX_PC_plus_4:ALUout1;
//EX/MEM寄存器
	always @(posedge clk or negedge reset) 
	begin
		if(~reset) begin
			EX_MEM_PC_plus_4 	<= RESETPC;
			EX_MEM_Rd 			<= 0;
			EX_MEM_ALUout		<= 0;
			EX_MEM_Write_Addr 	<= 0;
			EX_MEM_RegWrite 	<= 0;
	 		EX_MEM_MemWrite 	<= 0;
	 		EX_MEM_MemRead 		<= 0;
			EX_MEM_MemToReg 	<= 0;
			EX_MEM_DataBusB		<= 0;
		end else begin
			EX_MEM_PC_plus_4 	<= ID_EX_PC_plus_4;
			EX_MEM_Rd 			<= ID_EX_Rd;
			EX_MEM_ALUout		<= ALUout;
			EX_MEM_Write_Addr 	<= ID_EX_Write_Addr;
			EX_MEM_DataBusB		<= DataB;
			EX_MEM_RegWrite 	<= EX_flush?0:ID_EX_RegWrite;
	 		EX_MEM_MemWrite 	<= EX_flush?0:ID_EX_MemWrite;
	 		EX_MEM_MemRead 		<= EX_flush?0:ID_EX_MemRead;
			EX_MEM_MemToReg 	<= EX_flush?0:ID_EX_MemToReg;
		end
	end

//选择外设部分还是数据部分
	assign	MemRead1	= (EX_MEM_ALUout[30])?0:EX_MEM_MemRead;
	assign	MemWrite1	= (EX_MEM_ALUout[30])?0:EX_MEM_MemWrite;
	assign	MemRead2	= (EX_MEM_ALUout[30])?EX_MEM_MemRead:0;
	assign	MemWrite2	= (EX_MEM_ALUout[30])?EX_MEM_MemWrite:0;
//存储器
	DataMemory data_memory1(.reset(reset), .clk(clk), .rd(MemRead1), .wr(MemWrite1), .addr(EX_MEM_ALUout), .wdata(EX_MEM_DataBusB), .rdata(Read_DataA));
	
//外设
	//Peripheral Peripheral(.Rst(reset),.Clk(clk),.MemRd(MemRead2),.MemWr(MemWrite2),.Addr(EX_MEM_ALUout),.WrData(EX_MEM_DataBusB),.RdData(Read_DataB),.IRQout(IRQ),.Led(led),.Switch(switch),.Digi(digi),.UART_RX(UART_rxd),.UART_TX(UART_txd));
	Peripheral peripheral1(		.reset(reset),.clk(clk),.rd(MemRead2),.wr(MemWrite2),.addr(EX_MEM_ALUout),.wdata(EX_MEM_DataBusB),.rdata(Read_DataB),.led(led),.switch(switch),.digi(digi),.irqout(IRQ),.UART_rxd(UART_rxd),.UART_txd(UART_txd));
	digitube_scan digitube_scan1(.digi_in(digi),.digi_out1(digi_out1),.digi_out2(digi_out2),.digi_out3(digi_out3),.digi_out4(digi_out4));
	assign	Read_Data = EX_MEM_ALUout[30]?Read_DataB:Read_DataA;
	assign	Read_Data1 = (EX_MEM_MemToReg == 2'd0)?EX_MEM_ALUout:(EX_MEM_MemToReg == 2'd1)?Read_Data:EX_MEM_PC_plus_4;
//MEM_WB
	always @(posedge clk or negedge reset) 
	begin 
		if(~reset) begin
			MEM_WB_Read_Data	<= 0;
			MEM_WB_Rd 			<= 0;
			MEM_WB_Write_Addr	<= 0;
	 		MEM_WB_RegWrite		<= 0;
		end else begin
			MEM_WB_Read_Data	<= Read_Data1;
			MEM_WB_Rd 			<= EX_MEM_Rd;
			MEM_WB_Write_Addr	<= EX_MEM_Write_Addr;
	 		MEM_WB_RegWrite		<= EX_MEM_RegWrite;
		end
	end

//PC选择
	
	assign	Jump_target = {IF_ID_PC_plus_4[31:28],IF_ID_Instruction[25:0],2'b00};
	assign	DataBusA = (Select_3 == 2'd0)?DataBus1:(Select_3 == 2'd1)?ALUout:Read_Data1;
	assign	PC_next = (PCSrc == 3'd1)?ID_EX_Branch_Addr:(PCSrc == 3'd2)?Jump_target:(PCSrc == 3'd3)?DataBusA:(PCSrc == 3'd4)?ILLOP:(PCSrc == 3'd5)?XADR:(PCSrc == 3'd6)?PC:PC_plus_4;
endmodule // p_processor
