module pc_reg(
	input wire		clk,
	input wire		rst,
	output reg[31:0] pc_o
);

	always @ (posedge clk) begin
		if(rst == 1'b0)				//if system is being reset
			pc_o <=32'b0;
		else
			pc_o <= pc_o + 3'd4; 	//every address is 4 bytes long
		
	end
	
	
endmodule