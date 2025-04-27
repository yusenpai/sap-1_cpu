module ram_programmer (
	input wire rst,
	input wire clk,
	output reg [7:0] prog_data,
	output reg [3:0] prog_address,
	output reg prog_enable,
	output reg ram_clk,
	output reg ram_halt
);

	// ROM-like function to access instruction data
	function [7:0] program_data;
		input [3:0] addr;
		begin
			case (addr)
				4'h0: program_data = 8'h50;
				4'h1: program_data = 8'h4E;
				4'h2: program_data = 8'h51;
				4'h3: program_data = 8'h4F;
				4'h4: program_data = 8'h2E;
				4'h5: program_data = 8'h4E;
				4'h6: program_data = 8'h2F;
				4'h7: program_data = 8'h4F;
				4'h8: program_data = 8'h64;
				default: program_data = 8'h00;
			endcase
		end
	endfunction

	reg [4:0] counter;
	reg writing;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			counter <= 0;
			prog_address <= 0;
			prog_data <= 0;
			prog_enable <= 0;
			ram_clk <= 1;
			ram_halt <= 1;  // halt CPU during programming
			writing <= 1;
		end 
		else if (writing) begin
			prog_data <= program_data(counter[3:0]);
			prog_address <= counter[3:0];
			prog_enable <= 1;
			ram_clk <= ~ram_clk;

			if (~ram_clk) begin
				counter <= counter + 1;
				if (counter == 15) begin
					writing <= 0;
					prog_enable <= 0;
					prog_address <= 0;
					ram_halt <= 0; // release CPU
				end
			end
		end else begin
			prog_enable <= 0;
			ram_clk <= 0;
		end
	end
endmodule

module CPU (
	/* Clock and rst */
	input clk, rst, user_halt,

	/* DEBUG */
	output [7:0] debug_pc_out,
	output [7:0] debug_regA_out,
	output [7:0] debug_regB_out,
	output [3:0] debug_ram_address,
	output [7:0] debug_bus,
	output [7:0] debug_opcode,
	output [2:0] debug_microinstruction_step,
	output debug_cy
);
	/* PC control signal */
	wire co, j, ce;	

	/* REG A control signal */
	wire ai, ao;

	/* REG B control signal */
	wire bi, bo;

	/* ALU control signal */
	wire eo, su;

	/* MAR control signal */
	wire mi;

	/* RAM control signal */
	wire ri, ro;

	/* IR control signal */
	wire ii, io;

	/* Other internal signal */
	wire sys_clk;
	wire hlt;
	wire cy;
	wire [7:0] regA_out;
	wire [7:0] regB_out;
	wire [7:0] bus;
	wire [7:0] bus_out [5:0];
	wire [3:0] opcode;

	/* RAM programing interface */
	wire [7:0] prog_data_in;
	wire [3:0] prog_address;
	wire prog_enable;
	wire ram_clk;
	wire ram_halt;
	assign sys_clk = clk & (~(hlt | user_halt | ram_halt));

	/* Bus position of each block */
	localparam PC_bus_pos = 0;
	localparam REGA_bus_pos = 1;
	localparam REGB_bus_pos = 2;
	localparam ALU_bus_pos = 3;
	localparam RAM_bus_pos = 4;
	localparam IR_bus_pos = 5;
	localparam INS_DEC_bus_pos = 6;

	program_cnt PC_block(
		.bus_in(bus),
		.bus_out(bus_out[PC_bus_pos]),
		.co(co),
		.j(j),
		.clk(sys_clk),
		.ce(ce),
		.rst(rst),
		.pc_value(debug_pc_out)
	);
	reg8_general_purpose REGA_block(
		.bus_in(bus),
		.bus_out(bus_out[REGA_bus_pos]),
		.clk(sys_clk),
		.rst(rst),
		.reg_load(ai),
		.reg_en(ao),
		.reg8_out(regA_out)
	);
	reg8_general_purpose REGB_block(
		.bus_in(bus),
		.bus_out(bus_out[REGB_bus_pos]),
		.clk(sys_clk),
		.rst(rst),
		.reg_load(bi),
		.reg_en(bo),
		.reg8_out(regB_out)
	);
	ALU ALU_block(
		.bus_out(bus_out[ALU_bus_pos]),
		.A(regA_out),
		.B(regB_out),
		.eo(eo), 
		.su(su),
		.cy(cy)
	);
	wire [3:0] ram_address;
	mem_addr_reg MAR_block(
		.bus_in(bus),
		.clk(sys_clk),
		.rst(rst),
		.mi(mi),
		.address(ram_address)
	);
	ram RAM_block(
		.bus_in(bus),
		.bus_out(bus_out[RAM_bus_pos]),
		.clk(sys_clk),
		.rst(rst),
		.address(ram_address),
		.ri(ri),
		.ro(ro),
		.prog_data_in(prog_data_in),
		.prog_enable(prog_enable),
		.ram_clk(ram_clk),
		.prog_address(prog_address)
	);
	instruction_reg IR_block(
		.bus_in(bus),
		.bus_out(bus_out[IR_bus_pos]),
		.clk(sys_clk),
		.rst(rst),
		.ii(ii),
		.io(io),
		.opcode(opcode)
	);
	instruction_decoder INS_DEC_block(
		.opcode(opcode),
		.clk(sys_clk), 
		.rst(rst),
		.co(co),
		.j(j),
		.ce(ce),
		.ai(ai),
		.ao(ao),
		.bi(bi),
		.bo(bo),
		.eo(eo),
		.su(su),
		.mi(mi),
		.ri(ri),
		.ro(ro),
		.ii(ii),
		.io(io),
		.hlt(hlt),
		.step_out(debug_microinstruction_step)
	);

	ram_programmer RAM_PROG_block(
		.rst(rst),
		.clk(clk),
		.prog_data(prog_data_in),
		.prog_address(prog_address),
		.prog_enable(prog_enable),
		.ram_clk(ram_clk),
		.ram_halt(ram_halt)
	);

	/* Bus arbitration */
	assign bus = bus_out[0] | bus_out[1] | bus_out[2] | bus_out[3] | bus_out[4] | bus_out[5];

	/* DEBUG output */
	assign debug_regA_out = regA_out;
	assign debug_regB_out = regB_out;
	assign debug_cy = cy;
	assign debug_ram_address = ram_address;
	assign debug_bus = bus;
	assign debug_opcode = opcode;

endmodule