
module BRG1 (Sys_clk,reset,clk4);

	input 	    Sys_clk,reset;
	output reg  clk4;
	reg 		[8:0]count1;

	initial
	begin
		clk4 <= 0;
		count1 <= 0;
	end

	always @(posedge Sys_clk or negedge reset) 
	begin 
		if(~reset) 
		begin
			clk4<= 0;
			count1 <= 0;
		end else 
		begin
			if(count1 == 9'd1)
			begin
				clk4<= ~clk4;
				count1 <= 9'd0;
			end
			else
				count1 <= count1 +9'd1;
		end
	end
endmodule