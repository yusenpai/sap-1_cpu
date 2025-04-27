module micro_ins_cnt (
	input clk,
	input rst,
	output reg [2:0] out
);
	always @(posedge clk or posedge rst) begin
		if (rst)
			out <= 3'b000;
		else begin
			if (out == 3'd5)
				out <= 3'b000;
			else
				out <= out + 3'b1;
		end
	end
endmodule

module opcode_rom (
	input [3:0] opcode,
	input [2:0] step,
	output reg [15:0] control_word
);

	/* Control signal bit positions */
	localparam co = 16'b0000000000000001;
	localparam jp = 16'b0000000000000010;
	localparam ce = 16'b0000000000000100;
	localparam ai = 16'b0000000000001000;
	localparam ao = 16'b0000000000010000;
	localparam bi = 16'b0000000000100000;
	localparam bo = 16'b0000000001000000;
	localparam eo = 16'b0000000010000000;
	localparam su = 16'b0000000100000000;
	localparam mi = 16'b0000001000000000;
	localparam ri = 16'b0000010000000000;
	localparam ro = 16'b0000100000000000;
	localparam ii = 16'b0001000000000000;
	localparam io = 16'b0010000000000000;
	localparam ht = 16'b1000000000000000;

	always @(*) begin
		case({opcode, step})
			// NOP
			7'b0000_000: control_word = co | mi;
			7'b0000_001: control_word = ro | ii;
			7'b0000_010: control_word = io | mi;
			7'b0000_011: control_word = 16'b0;
			7'b0000_100: control_word = 16'b0;
			7'b0000_101: control_word = ce;
			7'b0000_110: control_word = 16'b0;
			7'b0000_111: control_word = 16'b0;

			// LDA
			7'b0001_000: control_word = co | mi;
			7'b0001_001: control_word = ro | ii;
			7'b0001_010: control_word = io | mi;
			7'b0001_011: control_word = ro | ai;
			7'b0001_100: control_word = 16'b0;
			7'b0001_101: control_word = ce;
			7'b0001_110: control_word = 16'b0;
			7'b0001_111: control_word = 16'b0;

			// ADD
			7'b0010_000: control_word = co | mi;
			7'b0010_001: control_word = ro | ii;
			7'b0010_010: control_word = io | mi;
			7'b0010_011: control_word = ro | bi;
			7'b0010_100: control_word = eo | ai;
			7'b0010_101: control_word = ce;
			7'b0010_110: control_word = 16'b0;
			7'b0010_111: control_word = 16'b0;
			
			// suB
			7'b0011_000: control_word = co | mi;
			7'b0011_001: control_word = ro | ii;
			7'b0011_010: control_word = io | mi;
			7'b0011_011: control_word = ro | bi;
			7'b0011_100: control_word = eo | ai | su;
			7'b0011_101: control_word = ce;
			7'b0011_110: control_word = 16'b0;
			7'b0011_111: control_word = 16'b0;

			// STA
			7'b0100_000: control_word = co | mi;
			7'b0100_001: control_word = ro | ii;
			7'b0100_010: control_word = io | mi;
			7'b0100_011: control_word = ao | ri;
			7'b0100_100: control_word = 16'b0;
			7'b0100_101: control_word = ce;
			7'b0100_110: control_word = 16'b0;
			7'b0100_111: control_word = 16'b0;

			// LDI
			7'b0101_000: control_word = co | mi;
			7'b0101_001: control_word = ro | ii;
			7'b0101_010: control_word = io | ai;
			7'b0101_011: control_word = 16'b0;
			7'b0101_100: control_word = 16'b0;
			7'b0101_101: control_word = ce;
			7'b0101_110: control_word = 16'b0;
			7'b0101_111: control_word = 16'b0;

			// JMP
			7'b0110_000: control_word = co | mi;
			7'b0110_001: control_word = ro | ii;
			7'b0110_010: control_word = io | jp;
			7'b0110_011: control_word = 16'b0;
			7'b0110_100: control_word = 16'b0;
			7'b0110_101: control_word = 16'b0;
			7'b0110_110: control_word = 16'b0;
			7'b0110_111: control_word = 16'b0;

			// hlt
			7'b1111_000: control_word = ht;
			7'b1111_001: control_word = 16'b0;
			7'b1111_010: control_word = 16'b0;
			7'b1111_011: control_word = 16'b0;
			7'b1111_100: control_word = 16'b0;
			7'b1111_101: control_word = ce;
			7'b0111_110: control_word = 16'b0;
			7'b0111_111: control_word = 16'b0;
		endcase
	end
endmodule

module instruction_decoder (
	input [3:0] opcode,
	input clk, rst,
	output co, j, ce,
	output ai, ao,
	output bi, bo,
	output eo, su,
	output mi,
	output ri, ro,
	output ii, io,
	output hlt,

	/* DEBUG out */
	output [2:0] step_out
);
	wire [2:0] STEP;
	assign step_out = STEP;
	micro_ins_cnt micro_ins_step_cnt(
		.clk(clk),
		.rst(rst),
		.out(STEP)
	);
	wire [15:0] control_word;
	opcode_rom roM_coDE(
		.opcode(opcode),
		.step(STEP),
		.control_word(control_word)
	);
	assign co = control_word[0];
	assign j = control_word[1];
	assign ce = control_word[2];
	assign ai = control_word[3];
	assign ao = control_word[4];
	assign bi = control_word[5];
	assign bo = control_word[6];
	assign eo = control_word[7];
	assign su = control_word[8];
	assign mi = control_word[9];
	assign ri = control_word[10];
	assign ro = control_word[11];
	assign ii = control_word[12];
	assign io = control_word[13];
	assign hlt = control_word[15];
endmodule