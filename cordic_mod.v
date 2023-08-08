module cordic_mod(
	input clk, rst,
	input signed [15:0] inp_x, inp_y,
	output reg signed [15:0] arctan,
	output reg valid
);
	localparam [2:0] stStart = 0, stWait = 1, stRotate = 2, stFinal = 3;
	reg [2:0] state = stStart;
	reg signed [16:0] x, y;
	wire signed [16:0] xp, yp;
	wire is_x_negative = inp_x[15];
	wire is_y_negative = inp_y[15];
	wire is_x_zero = ~|inp_x;
	wire is_y_zero = ~|inp_y;
	
	reg enable;
	wire [2:0] count_val;
	counter cntr(clk, rst, enable, count_val);

	reg signed [15:0] initial_angle;
	wire signed [15:0] updated_angle;
	wire is_done;
	rotator rttr(enable, x, y, initial_angle, count_val, xp, yp, updated_angle, is_done);

	always @(posedge clk) begin
		if (rst) begin
			initial_angle <= 0;
			x <= 0;
			y <= 0;
			state <= stStart;
		end
		else begin
			case (state)
				stStart		:	begin
					if (is_x_zero | is_y_zero) begin
						state <= stFinal;
					end
					else begin
						x <= (is_x_negative) ? -inp_x : inp_x;
						y <= (is_y_negative) ? -inp_y : inp_y;
						state <= stWait;
					end
				end

				stWait		:	begin
					state <= stRotate;
				end

				stRotate	:	begin
					if (is_done) begin
						state <= stFinal;
						end
					else begin
						x <= xp;
						y <= yp;
						initial_angle <= updated_angle;
						state <= stRotate;
					end
				end

				stFinal		:	begin
					state <= stStart;
				end
			endcase
		end
	end

	always @(posedge clk) begin
		if (rst) begin
			valid = 0;
			enable = 0;
		end
		else begin
			case (state)
				stStart		:	begin

				end

				stWait		:	begin
					enable = 1;
				end

				stRotate	:	begin
					if (is_done) begin
						enable = 0;
					end
				end

				stFinal		:	begin
					if (is_x_zero) begin
						arctan = {is_y_negative, {15{~is_y_negative}}};
					end
					else if (is_y_zero) begin
						arctan = 0;
					end
					else begin
						arctan = updated_angle;
						case ({is_x_negative, is_y_negative})
							2'b00	:	arctan = updated_angle; 
							2'b01	:	arctan = -updated_angle;
							2'b10	:	arctan = 16'h7fff - updated_angle;
							2'b11	:	arctan = updated_angle - 16'h7fff;
						endcase
					end
					valid = 1;
				end
			endcase
		end
	end
endmodule

// synthesis translate_off

`timescale 1 ps / 1 ps
module tb_cordic_mod;
	reg [15:0] x, y;
	reg clk, rst;
	wire [15:0] arctan;
	wire valid;

	cordic_mod dut(clk, rst, x, y, arctan, valid);

	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 0;
		x = 0;
		y = 0;

		#6 rst = 1; x = 16'h6666; y = 16'h4ccd;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'h0000; y = 16'h9214;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'h0000; y = 16'h5214;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'h9214; y = 16'h0000;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'h5214; y = 16'h0000;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'h5214; y = 16'h3842;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'h5214; y = 16'hA200;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'hB268; y = 16'h7370;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;

		@(posedge valid); #2 rst = 1; x = 16'hB268; y = 16'hD073;
		@(posedge clk);
		@(posedge clk); #1 rst = 0;
		
		@(posedge valid); #2 rst = 1;
		#10 $finish;
	end
endmodule

// synthesis translate_on