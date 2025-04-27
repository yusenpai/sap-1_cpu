module adder1 (
	input wire a,
	input wire b,
	input wire cin,
	output wire s,
	output wire cout
);
	assign s = a ^ b ^ cin;
	assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

module adder_param #(
	parameter WIDTH = 8
) (
	input wire [WIDTH - 1:0] a,
	input wire [WIDTH - 1:0] b,
	input wire cin,
	output wire [WIDTH - 1:0] s,
	output wire cout
);
	wire [WIDTH:0] carry;
	assign carry[0] = cin;
	genvar i;
	generate
		for (i = 0; i < WIDTH; i = i + 1) begin
			adder1 FA(
				.a(a[i]),
				.b(b[i]), 
				.cin(carry[i]),
				.s(s[i]),
				.cout(carry[i+1])
			);
		end
	endgenerate
	assign cout = carry[WIDTH];
endmodule