`timescale 1ns/1ps
module tb_CPU;
	reg clk;
	reg rst;
	reg user_halt;

	CPU uut(
		.rst(rst),
		.clk (clk),
		.user_halt(user_halt)
	);

	localparam CLK_PERIOD = 10;
	always #(CLK_PERIOD/2) clk=~clk;

	initial begin
		$dumpfile("wave.vcd");
		$dumpvars(0, tb_CPU);
	end

	initial begin
		clk = 1;
		rst = 1;
		user_halt = 1;

		/* Start simulation */
		#1
		rst = 0;

		/* Wait for RAM to be program */
		#335
		user_halt = 0;

		/* Wait for a while */
		#5000

		$finish();
	end

endmodule