module reg_param #(
	parameter WIDTH = 8
)(
	input wire rst,
	input wire clk,
	input wire load,
	input wire [WIDTH-1:0] load_data,
	output reg [WIDTH-1:0] q
);
	always @(posedge clk or posedge rst) begin
		if (rst)
			q <= {WIDTH{1'b0}};
		else if (load)
			q <= load_data;
		else
			q <= q;
	end
endmodule