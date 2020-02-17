
module sender (sysclk,clk,reset,tx_en,txdata,tx_status,UART_tx,txstop);
	input				sysclk,clk,reset,tx_en,txstop;
	input		[7:0]	txdata;
	output	reg			UART_tx,tx_status;
			reg	[1:0]	state,n_state;		
			reg	[3:0]	count2,n_count2;
			reg	[15:0]	count1,n_count1;
			reg	[1:0]	send_state,n_send_state;
			reg   [7:0]  tx_data;
	initial
	begin
		UART_tx <= 1;
		tx_status <= 1;
		count2 <= 4'd0;
		count1 <= 16'd0;
		state <= 2'd0;	
		n_count2 <= 4'd0;
		tx_data<=0;
	end
always @(posedge tx_en or negedge reset) 
begin
if (~reset) tx_data<=0;
else tx_data<=txdata;
end

	always @(posedge sysclk or negedge reset) 
	begin 
		if(~reset) begin
			state <= 2'b00;
			count1 <= 16'd0;
		end else begin
			state <= n_state;
			count1 <= n_count1;
		end
	end

	always @(*)
	begin
		case (state)
			2'b00:
			begin
				n_state = tx_en ? 2'b01:2'b00;
				n_count1 = 16'd0;
			end
			2'b01:
			begin
				n_state = 2'b10;
				n_count1 = 16'd0;
			end
			2'b10:
			begin
				n_state = (count1 == 16'd57288) ? 2'b00:2'b10;
				n_count1 = (count1 == 16'd57288) ? 16'd0:count1 + 16'd1;
			end
			default : 
			begin
				n_state = 2'b00;
				n_count1 = 16'd0;
			end
		endcase

		case (state)
			2'b00:tx_status = 1;
			2'b01:tx_status = 1;
			2'b10:tx_status = 0;
			default : tx_status = 1;
		endcase
	end

	always @(posedge clk or negedge reset) 
	begin
		if(~reset) begin
			count2 <= 4'd0;
			send_state <= 2'd0;
		end else begin
			count2 <= n_count2;
			send_state <= n_send_state;
		end
	end

	always @(*) 
	begin 
		case(send_state)
			2'b00:
			begin
				n_send_state = (tx_status == 0) ? 2'b01:2'b00;
				n_count2 = 4'd0;
				UART_tx = 1;
			end
			2'b01:
			begin
				n_send_state = 2'b10;
				n_count2 = count2 + 4'd1;
				UART_tx = 0;
			end
			2'b10:
			begin
				n_send_state = (count2 == 4'd8) ? 2'b11:2'b10;
				n_count2 = count2 + 4'd1;
				case(count2)
					4'd1:UART_tx = tx_data[0];
					4'd2:UART_tx = tx_data[1];
					4'd3:UART_tx = tx_data[2];
					4'd4:UART_tx = tx_data[3];
					4'd5:UART_tx = tx_data[4];
					4'd6:UART_tx = tx_data[5];
					4'd7:UART_tx = tx_data[6];
					4'd8:UART_tx = tx_data[7];
					default:UART_tx = 1;
				endcase
			end
			2'b11:
			begin
				n_send_state = 2'b00;
				n_count2 = 4'd0;
				UART_tx = 1;
			end
		endcase
	end
endmodule