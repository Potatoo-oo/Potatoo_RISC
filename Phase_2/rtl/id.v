`include "defines.v"



module id(
	//from if_id
	input wire[31:0] inst_i,
	input wire[31:0] inst_addr_i,
	
	//to regs
	output reg[4:0] rs1_addr_o,
	output reg[4:0] rs2_addr_o,
	
	//from regs
	input wire[31:0] rs1_data_i,
	input wire[31:0] rs2_data_i,
	
	//to id_ex
	output reg[31:0] inst_o,
	output reg[31:0] inst_addr_o,
	output reg[31:0] op1_o,
	output reg[31:0] op2_o,
	output reg[4:0]  rd_addr_o,
	output reg		 reg_wen
);

//extract instructions
	wire[6:0] 	opcode;
	wire[4:0] 	rd;
	wire[2:0] 	func3;
	wire[4:0] 	rs1;
	wire[11:0] 	imm;
	wire[4:0]	rs2;
	wire[6:0]	func7;
	wire[4:0]	shamt;

//I type
	assign opcode 	= inst_i[6:0];
	assign rd 		= inst_i[11:7];
	assign func3 	= inst_i[14:12];
	assign rs1 		= inst_i[19:15];
	assign imm 		= inst_i[31:20];
	assign shamt	= inst_i[24:20];

//R type (others included on top)
	assign rs2 		= inst_i[24:20];
	assign func7	= inst_i[31:25];

	always @ (*)begin
		inst_o 			= inst_i;
		inst_addr_o 	= inst_addr_i;
		case (opcode)

//============================================ I TYPE =================================================

			`INST_TYPE_I:begin
				case(func3)
					// ADD IMMEDIATE
					`INST_ADDI, `INST_SLTI, `INST_SLTIU, `INST_XORI, `INST_ORI, `INST_ANDI:begin
						rs1_addr_o = rs1;
						rs2_addr_o = 5'b0; 				//not used
						op1_o		= rs1_data_i;
						op2_o		= {{20{imm[11]}},imm};
						rd_addr_o	= rd;
						reg_wen		= 1'b1;					//write to registers?
					end

					`INST_SLLI, `INST_SRI: begin
						rs1_addr_o = rs1;
						rs2_addr_o = 5'b0; 				//not used
						op1_o		= rs1_data_i;
						op2_o		= {27'b0, shamt};
						rd_addr_o	= rd;
						reg_wen		= 1'b1;					//write to registers?
					end

					default:begin
						rs1_addr_o = 5'b0;
						rs2_addr_o = 5'b0; 				//not used
						op1_o		= 32'b0;
						op2_o		= 32'b0;
						rd_addr_o	= 5'b0;
						reg_wen		= 1'b0;	
					end
				endcase
			end

//============================================ R TYPE =================================================

			`INST_TYPE_R_M:begin
				case(func3)
					// ADD or SUB
					`INST_ADD_SUB, `INST_SLL, `INST_SLT, `INST_SLTU, `INST_XOR, `INST_SR, `INST_OR, `INST_AND:begin
						rs1_addr_o = rs1;
						rs2_addr_o = rs2; 				
						op1_o		= rs1_data_i;
						op2_o		= rs2_data_i;
						rd_addr_o	= rd;
						reg_wen		= 1'b1;					//write to registers?
					end
					default:begin
						rs1_addr_o = 5'b0;
						rs2_addr_o = 5'b0; 				
						op1_o		= 32'b0;
						op2_o		= 32'b0;
						rd_addr_o	= 5'b0;
						reg_wen		= 1'b0;	
					end
				endcase			
			end

//============================================ B TYPE =================================================

			`INST_TYPE_B:begin
				case(func3)

					// BNE & BEQ
					`INST_BNE, `INST_BEQ, `INST_BLT, `INST_BGE, `INST_BLTU, `INST_BGEU:begin
						rs1_addr_o  = rs1;
						rs2_addr_o  = rs2; 				
						op1_o		= rs1_data_i;
						op2_o		= rs2_data_i;
						rd_addr_o	= 5'b0;
						reg_wen		= 1'b0;							
					end

					default:begin
						rs1_addr_o = 5'b0;
						rs2_addr_o = 5'b0; 				
						op1_o		= 32'b0;
						op2_o		= 32'b0;
						rd_addr_o	= 5'b0;
						reg_wen		= 1'b0;	
					end
				endcase
			end
//============================================ J TYPE =================================================
			//JAL
			`INST_JAL:begin
				rs1_addr_o  = 5'b0;
				rs2_addr_o  = 5'b0; 				
				op1_o 		= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
				op2_o		= 32'b0;
				rd_addr_o	= rd;
				reg_wen		= 1'b1;	
			end

			`INST_JALR:begin
				rs1_addr_o  = rs1;
				rs2_addr_o  = 5'b0; 				
				op1_o 		= rs1_data_i;
				op2_o		=  {{20{imm[11]}},imm};
				rd_addr_o	= rd;
				reg_wen		= 1'b1;	
			end

//============================================ U TYPE =================================================

			`INST_LUI:begin
				rs1_addr_o  = 5'b0;
				rs2_addr_o  = 5'b0; 				
				op1_o		= {inst_i[31:12], 12'b0};
				op2_o		= 32'b0;
				rd_addr_o	= rd;
				reg_wen		= 1'b1;	
			end	

			`INST_AUIPC:begin
				rs1_addr_o  = 5'b0;
				rs2_addr_o  = 5'b0; 				
				op1_o		= {inst_i[31:12], 12'b0};
				op2_o		= inst_addr_i;
				rd_addr_o	= rd;
				reg_wen		= 1'b1;	
			end				
			//... others
			
			default:begin
					rs1_addr_o = 5'b0;
					rs2_addr_o = 5'b0; 				
					op1_o		= 32'b0;
					op2_o		= 32'b0;
					rd_addr_o	= 5'b0;
					reg_wen		= 1'b0;	
			end
		endcase
	end


endmodule