module rom (
	input wire [31:0] inst_addr_i,
	output reg [31:0] inst_o
);

	reg[31:0] rom_mem[0:4095]; //4096 32bits instruction
	
	always @(*)begin
		inst_o = rom_mem[inst_addr_i>>2]; //shift right 2 -- divide by 4 = 2^2
	end

endmodule