`timescale 1ns/1ps
//读写存储器方式
module DataMemory (reset,clk,rd,wr,addr,wdata,rdata);
input reset,clk;
input rd,wr;
input [31:0] addr;	//Address Must be Word Aligned
output [31:0] rdata;
input [31:0] wdata;

parameter RAM_SIZE = 256;
reg [31:0] RAMDATA [RAM_SIZE-1:0];
integer i;

initial
begin
	for(i=0;i<RAM_SIZE;i=i+1)	RAMDATA[i] = 32'b0;
end

assign rdata=(rd && (addr[31:2] < RAM_SIZE))?RAMDATA[addr[31:2]]:32'b0;

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		for(i=0;i<RAM_SIZE;i=i+1)	RAMDATA[i] <= 32'b0;
	end
	else	
	begin
		if(wr && (addr[31:2] < RAM_SIZE)) RAMDATA[addr[31:2]]<=wdata;
	end
end

endmodule
