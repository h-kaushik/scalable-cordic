module rotator
(
	input enable,
	input signed [16:0] x, y,
	input signed [15:0] initial_angle,
	input [2:0] count_val,
	output signed [16:0] xp, yp,
	output signed [15:0] updated_angle,
	output is_done
);
	// Scaled angular values
//	reg [15:0] angle_table [0:7];
//	angle_table[0] = 16'h4000;
//	angle_table[1] = 16'h25C8;
//	angle_table[2] = 16'h13F6;
//	angle_table[3] = 16'h0A22;
//	angle_table[4] = 16'h0516;
//	angle_table[5] = 16'h028C;
//	angle_table[6] = 16'h0146;
//	angle_table[7] = 16'h00A3;
	
	//reg [15:0] angle_table [0:7] = {16'h4000, 16'h25C8, 16'h13F6, 16'h0A22, 16'h0516, 16'h028C, 16'h0146, 16'h00A3};

	reg signed [15:0] angle_table [0:7];
	initial begin
		$readmemh("scaled_angles.hex", angle_table);
	end

	wire [16:0] x_shifted, y_shifted;
	reg signed [15:0] update_angle;
	reg signed [16:0] xnew, ynew;
	reg signed [15:0] new_angle;
	reg d;
	
	assign x_shifted = x >> count_val;
	assign y_shifted = y >>> count_val;

	assign updated_angle = new_angle;
	assign xp = xnew;
	assign yp = ynew;
	assign is_done = d;

	always @(*) begin
		if (enable) begin
			if (y[16]) begin
				xnew = x - y_shifted;
				ynew = x_shifted + y;
				update_angle = -angle_table[count_val];
			end
			else begin
				xnew = x + y_shifted;
				ynew = y - x_shifted;
				update_angle = angle_table[count_val];
			end
			new_angle = initial_angle + update_angle;
			d = (~|ynew) | (&count_val);
		end
	end
endmodule