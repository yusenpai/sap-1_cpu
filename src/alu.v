module ALU (
	/* Bus interface */
	output [7:0] bus_out,

	/* Operand */
	input [7:0] A, B,
	
	/* Control signal */
	input eo, su,
	output cy
);
	wire [7:0] adder_s;
	wire adder_cout;
	adder_param #(8) FA8(
		.a(A), 
		.b(B ^ {8{su}}), 
		.cin(su), 
		.s(adder_s),
		.cout(adder_cout)
	);
	bus_transceiver_param #(9) ALU_out_gate(
		.in({adder_s, adder_cout}), 
		.out({bus_out, cy}),
		.enable(eo) 
	);
endmodule
