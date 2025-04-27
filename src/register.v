module reg8_general_purpose (
	/* Bus interface */
	input [7:0] bus_in,
	output [7:0] bus_out,

	/* Control signal */
	input clk,
	input rst,
	input reg_load,
	input reg_en,

	/* DEBUG */
	output [7:0] reg8_out
);
	reg_param #(8) reg_A_instance(
		.rst(rst),
		.clk(clk),
		.load(reg_load),
		.load_data(bus_in),
		.q(reg8_out)
	);
	bus_transceiver_param #(8) out_gate(.in(reg8_out), .out(bus_out), .enable(reg_en));
endmodule

module mem_addr_reg (
	/* Bus interface */
	input [7:0] bus_in,

	/* Control signal */
	input clk,
	input rst,
	input mi,

	/* Address output */
	output [3:0] address
);
	reg_param #(4) reg_MAR_instance(
		.rst(rst),
		.clk(clk),
		.load(mi),
		.load_data(bus_in[3:0]),
		.q(address)
	);
endmodule

module instruction_reg (
	/* Bus interface */
	input [7:0] bus_in,
	output [7:0] bus_out,

	/* Control signal */
	input clk,
	input rst,
	input ii,
	input io,

	/* opcode outputs */
	output [3:0] opcode
);
	wire [7:0] reg_IR_instance_out;
	reg_param #(8)  reg_IR_instance(
		.rst(rst),
		.clk(clk),
		.load(ii),
		.load_data(bus_in),
		.q(reg_IR_instance_out)
	);
	bus_transceiver_param #(4) out_gate(.in(reg_IR_instance_out[3:0]), .out(bus_out[3:0]), .enable(io));
	assign bus_out[7:4] = 4'b0000;
	assign opcode = reg_IR_instance_out[7:4];
endmodule

module program_cnt (
	/* Bus interface */
	input [7:0] bus_in,
	output [7:0] bus_out,

	/* Control signal */
	input co,	// output enable
	input j,	// jump
	input ce,	// increment
	input clk,
	input rst,	// async reset

	/* DEBUG output */
	output [3:0] pc_value
);
	reg [3:0] upcnt_out;
	assign pc_value = upcnt_out;

	always @(posedge clk or posedge rst) begin
		if(rst)
			upcnt_out <= 4'h0;
		else if(j)
			upcnt_out <= bus_in[3:0];
		else if(ce)
			upcnt_out <= upcnt_out + 1'b1;
		else
			upcnt_out <= upcnt_out;
	end	

	bus_transceiver_param #(4) upcnt_out_gate(
		.in(upcnt_out), 
		.out(bus_out[3:0]), 
		.enable(co)
	);
	assign bus_out[7:4] = 4'b0000;
endmodule