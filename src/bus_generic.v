module bus_transceiver_param #(
	parameter WIDTH = 8
)(
	input [WIDTH - 1: 0] in,
	input enable,
	output [WIDTH - 1: 0] out
);
	assign out = in & {WIDTH{enable}};
endmodule