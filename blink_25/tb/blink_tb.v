`timescale 1 ns / 1 ps

module tb;
	reg clk;
	reg rst_n;
	wire led;

	initial begin
`ifdef CCSDF
		$sdf_annotate("blink_00.sdf", dut);
`endif
		$dumpfile("sim/blink_tb.vcd");
		$dumpvars(0, tb);
		clk = 0;
		rst_n = 0;
	end

	always clk = #1 ~clk;

	blink #(
                .period_g(15),
		.high_g(5))
        dut (
		.clk(clk),
		.rst_n(rst_n),
		.o(led)
	);

	initial begin
		#200;
		rst_n = 1;
		#500;
		$finish;
	end

endmodule
