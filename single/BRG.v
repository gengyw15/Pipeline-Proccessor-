
module BRG (Sys_clk,reset,clk16,clk);

	input 	    Sys_clk,reset;
	output reg  clk16,clk;
	reg 		[8:0]count1;
	reg 		[11:0]count2;

	initial
	begin
		clk16 <= 0;
		count1 <= 0;
		count2 <= 0;
		clk <=0;
	end

	always @(posedge Sys_clk or negedge reset) 
	begin 
		if(~reset) 
		begin
			clk16<= 0;
			count1 <= 0;
			count2 <= 0;
		end else 
		begin
			if(count1 == 9'd163)
			begin
				clk16 <= ~clk16;
				count1 <= 9'd0;
			end
			else
				count1 <= count1 +9'd1;
			if(count2 == 12'd2604)
			begin
				clk <= ~clk;
				count2<=12'd0;
			end
			else
				count2 <= count2 + 12'd1;
		end
	end
endmodule