module counter (
	input clk, rst, enable,
	output reg [2:0] count_val
);

	always @(posedge clk) begin
		if (rst) begin
			count_val <= 3'b000;
		end
		else if (enable) begin
			count_val <= count_val + 1;
		end
	end

endmodule