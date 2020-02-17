`timescale 1ns/1ps
module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,UART_rxd,UART_txd);
input reset,clk,UART_rxd; //clk为要用的时钟
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;
output UART_txd;
output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;
reg [31:0] TH,TL;
reg [2:0] TCON;
wire clk16,clkt,rx_status,tx_status,rx_en,txstop;
wire [7:0]	rx_data;
reg	tx_en;
reg	[7:0]	ctl_data;
reg   n_enable,enable;
reg  [4:0] UART_CON;
reg  [7:0] txdata;
assign rx_en=UART_CON[1];
assign txstop=UART_CON[0];
assign irqout = TCON[2];

BRG 		BRG1(.Sys_clk(clk),.reset(reset),.clk16(clk16),.clk(clkt));
receive 	receive1(.sysclk(clk),.clk(clk16),.reset(reset),.in(UART_rxd),.rx_data(rx_data),.rx_status(rx_status),.rx_en(rx_en));//读进来后会发送一个高电平
sender 		sender1(.sysclk(clk),.clk(clkt),.reset(reset),.tx_en(tx_en),.txdata(txdata),.tx_status(tx_status),.UART_tx(UART_txd),.txstop(txstop));

initial
	begin
	   rdata<=0;
		tx_en <= 0;
		enable <=0;
		n_enable <= 0;
		ctl_data <= 0;
		UART_CON<=4'd0;
                txdata<=0;
	end


always@(*) begin
   if (~reset) rdata<=0;
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;			
			32'h40000004: rdata <= TL;			
			32'h40000008: rdata <= {29'b0,TCON};				
			32'h4000000C: rdata <= {24'b0,led};			
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000020: rdata <= {27'b0,UART_CON};		//利用rd轮询，读取控制信号，发现[3]==1时，可以从UART中读取
			32'h4000001C: rdata <= {24'b0,ctl_data};//读取后清零
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
if (~reset)
begin
ctl_data<=0;
UART_CON[3]<=0;
end
else if (rx_status==1)
begin
ctl_data<=rx_data;
UART_CON[3]<=1;
end
else if (rd&&addr==32'h4000001C)
UART_CON[3]<=0;
end
always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	
		led<=8'b0;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else TL <= TL + 1;
		end
		
		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];			
				32'h40000014: digi <= wdata[11:0];
				default: ;
			endcase
		end
	end
end

//发送wdata低8位
always @(posedge clk or negedge reset)
	begin 
		if(~reset)
		begin
			enable <= 1'b0;
			txdata<=0;
		end
		else 
		begin
			enable <= n_enable;
			txdata<= (wr&&addr == 32'h40000018)? wdata[7:0]:txdata;
		end
	end

	always @(*)
	begin
	  if (~reset)
	  begin
	   tx_en<=0;
		n_enable<=0;
	  end
		case(enable)
			1'b0:n_enable <= (wr&&addr == 32'h40000018) ? 1'b1:1'b0; //判断是否要把wdata的低八位从串口输出，控制tx_en
			1'b1:n_enable <= 1'b0;   //要小心txen一直为1的情况,建议wr只保持1个数据位的时间
			default:n_enable <= 1'b0;
		endcase // enable

		case(enable)
			1'b0:tx_en <= 0;
			1'b1:tx_en <= 1;
			default:tx_en <= 0;
		endcase
	end
endmodule

