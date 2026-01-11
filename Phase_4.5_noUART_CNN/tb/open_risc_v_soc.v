module open_risc_v_soc(
	input wire			clk				,
	input wire			rst				,
	input wire			uart_rxd		,
	input wire			debug_button	,
	output wire			led_debug		,
	output wire			led2			,	
	output wire[6:0]	x3_1			,	
	output wire[6:0]	x3_0			,	
	output wire			x26				,	
	output wire			x27				,
	output wire[6:0]	addr_0			,	
	output wire[6:0]	addr_1			,
	output wire[6:0]	clk_0_decode	,	
	output wire[6:0]	clk_1_decode

);

	//open_risc_v to rom
	wire[31:0]open_risc_v_inst_addr_o;

	//rom to open_risc_v
	wire[31:0]rom_inst_o;

	//open_risc_v to ram
	wire		open_risc_v_mem_wr_req_o;
	wire[3:0]	open_risc_v_mem_wr_sel_o;
	wire[31:0]	open_risc_v_mem_wr_addr_o;
	wire[31:0]	open_risc_v_mem_wr_data_o;

	wire		open_risc_v_mem_rd_req_o;
	wire[31:0]	open_risc_v_mem_rd_addr_o;

	//ram to open_risc_v
	wire[31:0]	ram_rd_data_o;

	// open_risc_v to 7_segment_decoder
	wire[31:0]	open_risc_v_7_segment;

	//bus_decoder to ???
	wire		ram_sel;
	wire		cnn_sel;
	wire		gpio_sel;

	open_risc_v open_risc_v_inst(
		.clk			(clk					),
		.rst			(rst					),
		.inst_i			(rom_inst_o				),  
		.inst_addr_o	(open_risc_v_inst_addr_o),

		//read mem
		.mem_rd_req_o	(open_risc_v_mem_rd_req_o),
		.mem_rd_addr_o	(open_risc_v_mem_rd_addr_o),
		.mem_rd_data_i	(ram_rd_data_o			),

		//write mem
		.mem_wr_req_o	(open_risc_v_mem_wr_req_o),
		.mem_wr_sel_o	(open_risc_v_mem_wr_sel_o),
		.mem_wr_addr_o	(open_risc_v_mem_wr_addr_o),
		.mem_wr_data_o	(open_risc_v_mem_wr_data_o),

		//output to soc
		.x3_out			(open_risc_v_7_segment)	,						//to be sent to 7-segment decoder
		.x26_out		(x26				)	,
		.x27_out		(x27)				
	);

	ram ram_inst(
	    .clk		(clk						),
	    .rst		(rst						),
	    .wen		(open_risc_v_mem_wr_sel_o	),
	    .w_addr_i	(open_risc_v_mem_wr_addr_o	),
	    .w_data_i	(open_risc_v_mem_wr_data_o	),
		
	    .ren		(open_risc_v_mem_rd_req_o	),
	    .r_addr_i	(open_risc_v_mem_rd_addr_o	),
		.ram_en		(ram_sel					),
	    .r_data_o	(ram_rd_data_o				)
	);	

	rom rom_inst (
	    .clk     	(clk					),
	    .rst     	(rst					),
	
	    .w_en    	(1'b0					),
	    .w_addr_i	(32'b0					),
	    .w_data_i	(32'b0					),
	
	    .r_en    	(1'b1					),
	    .r_addr_i	(open_risc_v_inst_addr_o),
	    .r_data_o	(rom_inst_o				) 
	);

	seven_seg_decoder seven_seg_decoder_inst (
    	.clk			(clk),
    	.rst			(rst),
    	.input0			(open_risc_v_7_segment),
		.addr_i			(open_risc_v_inst_addr_o),
		.inst_i			(rom_inst_o),

    	//LSB
    	.output_0		(x3_0),
		.output_addr_0	(addr_0),
		.clk_0			(clk_0_decode),

    	//MSB
    	.output_1		(x3_1),
		.output_addr_1	(addr_1),
		.clk_1			(clk_1_decode)

	);

	bus_decoder bus_decoder_inst(
    	.w_addr		(open_risc_v_mem_wr_addr_o),
		.r_addr		(open_risc_v_mem_rd_addr_o),
    	.rd_req		(open_risc_v_mem_rd_req_o),
    	.wr_req		(open_risc_v_mem_wr_req_o),

    	.ram_sel	(ram_sel),
    	.cnn_sel	(cnn_sel),
    	.gpio_sel	(gpio_sel)
	);

	cnn_accel cnn_accel_inst(
    	.clk		(clk),
    	.rst		(rst),
    	.cnn_en		(cnn_sel),                 //cnn_sel

    	.w_en		(open_risc_v_mem_wr_req_o),
    	.r_en		(open_risc_v_mem_rd_req_o),
    	.w_addr		(open_risc_v_mem_wr_addr_o),
		.r_addr		(open_risc_v_mem_rd_addr_o),
    	.wdata		(open_risc_v_mem_wr_data_o),

    	.rdata		(ram_rd_data_o),
		.done		()
	);

endmodule