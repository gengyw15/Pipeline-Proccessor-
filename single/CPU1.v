
module CPU1(reset,clk50,switch,UART_rxd,led,digi_out1,digi_out2,digi_out3,digi_out4,UART_txd);
	input	reset,clk50;
	input [7:0]	switch;
	input UART_rxd;
	output UART_txd;
	output [6:0] digi_out1;	//0: CG,CF,CE,CD,CC,CB,CA
	output [6:0] digi_out2;	//1: CG,CF,CE,CD,CC,CB,CA
	output [6:0] digi_out3;	//2: CG,CF,CE,CD,CC,CB,CA
	output [6:0] digi_out4;	//3: CG,CF,CE,CD,CC,CB,CA
	output	[7:0]	led;
        wire clk4;
BRG1 BRG2(.Sys_clk(clk50),.reset(reset),.clk4(clk4));
s_processor s_processor1(.clk50(clk50),.reset(reset),.clk(clk50),.switch(switch),.UART_rxd(UART_rxd),.led(led),.digi_out1(digi_out1),.digi_out2(digi_out2),.digi_out3(digi_out3),.digi_out4(digi_out4),.UART_txd(UART_txd));

endmodule