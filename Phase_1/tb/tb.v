module tb;
	reg clk;
	reg rst;
	integer r;


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
		$readmemh(".\inst_txt\rv32ui-p-add.txt", tb.open_risc_v_soc_inst.rom_inst.rom_mem); //tester from official is hex so is: readmem"h"
	end
	
	initial begin
		// while(1)begin
		// 	@(posedge clk)
		// 	$display ("x27 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27]);
		// 	$display ("x28 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
		// 	$display ("x29 register value is %d", tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[29]);
		// 	$display ("======================================");
		// end
		wait(x26 == 32'b1); 		//finish testings

		if(x27 == 32'b1)begin
			$display("========= PASS ==========");
		end
		else begin
			$display("========= FAIL ==========");
			for(r=0 ; r < 31 ; r = r + 1) begin

				$display ("x%2d register value is %d", r, tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[r]);

			end
		end
	end

	open_risc_v_soc open_risc_v_soc_inst(
		.clk		(clk),
		.rst		(rst)		
	);

endmodule