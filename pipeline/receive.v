module receive (sysclk,clk,reset,in,rx_data,rx_status,rx_en);

	input 				sysclk,clk,reset,in,rx_en;
	output	reg	[7:0]	rx_data;
	output	reg			rx_status;	
			reg	[1:0]	n_state,state;
			reg [7:0]	n_count,count,temp_data;
			reg 		rx_ctl;

	initial
	begin
		rx_data <= 8'd0;
		rx_status <= 0;
		n_count <= 8'd0;
		n_state <=0;
		temp_data <= 8'd0;
		count <= 8'd0;
		state <=0;
		rx_ctl <= 0;
	end 

	always @(posedge sysclk or negedge reset ) 
	begin 
		if(~reset) 
		begin
			rx_ctl <= 0;
			rx_status <= 0;
		end 
		else 
		begin
			if(count == 8'd159)
			begin
				if(rx_ctl == 0)
				begin
					rx_status <= 1;
					rx_ctl <= 1;
				end
				else
					rx_status <= 0;
			end
			else
			begin
				rx_ctl <= 0;
				rx_status <=0;
			end
		end
	end

	always @(posedge clk or negedge reset) 
	begin 
		if(~reset) begin
			temp_data <= 8'd0;
		end 
		else begin
			if(count == 8'd23)
				temp_data[0] <= in;
			else if(count == 8'd39)
				temp_data[1] <= in;
			else if(count == 8'd55)				
				temp_data[2] <= in;
			else if(count == 8'd71)				
				temp_data[3] <= in;
			else if(count == 8'd87)				
				temp_data[4] <= in;
			else if(count == 8'd103)				
				temp_data[5] <= in;
			else if(count == 8'd119)				
				temp_data[6] <= in;
			else if(count == 8'd135)				
				temp_data[7] <= in;
		end
	end

	always @(posedge clk or negedge reset) 
	begin 
		if(~reset) 
		begin
			count <=8'd0;
			state <=2'b00;
		end 
		else begin
			count <= n_count;
			state <= n_state;
		end
	end

	always @(*)
	begin
		case(state)
			2'b00:
			begin
				n_state = (in == 00) ? 2'b01:2'b00;
				n_count = 8'd0;
			end
			2'b01:
			begin
				if(count == 8'd7) 
				begin
					n_count = count + 8'd1;
					n_state = 2'b10;
				end
				else
				begin
					n_count = count + 8'd1;
					n_state = 2'b01;
				end
			end
			2'b10:
				begin
					n_count = (count == 8'd159) ? 8'd0:count + 8'd1;
					n_state = (count == 8'd159) ? 2'b00:2'b10;
				end
				default:
				begin
					n_state = 2'b00;
					n_count = 8'd0;
				end
			
		endcase 
	end

	always @(posedge rx_status or negedge reset)
	begin
		if(~reset)
		begin
			rx_data <= 8'd0;
		end
		else
		begin
			rx_data <= temp_data;
		end
	end

endmodule // receive