module tb;
	reg clk;
	reg rst;


	wire x3  = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[3];
	wire x26 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[26];
	wire x27 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27];
	always #100 clk = ~clk;

	initial begin
		clk <= 1'b1;
		rst <= 1'b0;

		#300;
		rst <= 1'b1;
	end

	//rom initial value
	initial begin
		$readmemh("./generated/inst_data.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem.dual_ram_template_inst.memory);
	end

	// get waveform
	// initial begin
	// 	$dumpfile("tb.vcd");
	// 	$dumpvars;
	// end

	integer r;
	initial begin
		// while(1)begin
		// 	@(posedge clk)
		// 	$display ("x27 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27]);
		// 	$display ("x28 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
		// 	$display ("x29 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[29]);
		// 	$display ("======================================");
		// end
		wait(x26 == 32'b1); 		//finish testings

		#2000;						//will have error, comparing the wrong datas

		if(x27 == 32'b1)begin
			$display("=========================");
			$display("========= pass ==========");
			$display("=========================");
		end
		else begin
			$display("=========================");
			$display("========= FAIL ==========");
			$display("=========================");
			$display("fail testnum = %2d", x3);
			for(r=0 ; r < 31 ; r = r + 1) begin

				$display ("x%2d register value is %d", r, tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[r]);

			end
		end

		$finish();
	end

	open_risc_v_soc open_risc_v_soc_inst(
		.clk		(clk),
		.rst		(rst)		
	);

endmodule