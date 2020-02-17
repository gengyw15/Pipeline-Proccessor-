`timescale 1ns/1ns
module top_tb1 ;
	reg			Rst, Clk;
	wire	[7:0]	Led;
	reg		[7:0]	Switch;
	wire	[6:0]	digi_out1;
	wire	[6:0]	digi_out2;
	wire	[6:0]	digi_out3;
	wire	[6:0]	digi_out4;
	reg				UART_RX;
	wire			UART_TX;
	p_processor cpu(.reset(Rst),.clk(Clk),.switch(Switch),.UART_rxd(UART_RX),.led(Led),.digi_out1(digi_out1),.digi_out2(digi_out2),.digi_out3(digi_out3),.digi_out4(digi_out4),.UART_txd(UART_TX));
	// Rst
	initial begin
		Rst = 1;
	#13	Rst = 0;
	#10	Rst = 1;
	end

	// Clk
	initial begin
		Clk = 0;
		forever
		#10	Clk = ~Clk;
	end

	// Switch
	initial begin
		Switch = 0;
	end

	// UART_RX
	initial begin
			UART_RX = 1;
	#1001	UART_RX = 0;	// start	1000+1
	#104167	UART_RX = 0;
	#104167	UART_RX = 1;
	#104167	UART_RX = 0;
	#104167	UART_RX = 1;
	#104167	UART_RX = 1;
	#104167	UART_RX = 1;
	#104167	UART_RX = 1;
	#104167	UART_RX = 1;
	#104167	UART_RX = 1;	// stop		938503+1
	#104167	UART_RX = 1;	//			1042670+1
	#104167	UART_RX = 0;	// start
	#104167	UART_RX = 0;
	#104167	UART_RX = 1;
	#104167	UART_RX = 0;
	#104167	UART_RX = 0;
	#104167	UART_RX = 1;
	#104167	UART_RX = 1;
	#104167	UART_RX = 0;
	#104167	UART_RX = 0;
	#104167	UART_RX = 1;	// stop		2084340+1		2188507+1
	#104167	;
	#104167	;
	end
endmodule

