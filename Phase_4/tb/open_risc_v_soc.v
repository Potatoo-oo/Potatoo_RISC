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

	// open_risc_v to rom
	wire[31:0]open_risc_v_inst_addr_o;

	// rom to open_risc_v
	wire[31:0]rom_inst_o;

	// open_risc_v to ram
	wire		open_risc_v_mem_wr_req_o;
	wire[3:0]	open_risc_v_mem_wr_sel_o;
	wire[31:0]	open_risc_v_mem_wr_addr_o;
	wire[31:0]	open_risc_v_mem_wr_data_o;

	wire		open_risc_v_mem_rd_req_o;
	wire[31:0]	open_risc_v_mem_rd_addr_o;

	// ram to open_risc_v
	wire[31:0]	ram_rd_data_o;

	// uart_debug to rom
	wire		uart_debug_ce;
	wire		uart_debug_wen;
	wire[31:0]	uart_debug_addr_o;
	wire[31:0]	uart_debug_data_o;

	// debug_button_debounce to debug
	wire		debug;

	// open_risc_v to 7_segment_decoder
	wire[31:0]		open_risc_v_7_segment;

	debug_button_debounce debug_button_debounce_inst(
    	.clk            (clk			),
    	.rst            (rst			),
    	.debug_button   (debug_button	),
    	.debug          (debug			),
    	.led_debug		(led_debug		)
	);

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

	//Memory Mapping
	assign led2 = open_risc_v_mem_wr_data_o[2];


	ram ram_inst(
	    .clk		(clk						),
	    .rst		(rst						),
	    .wen		(open_risc_v_mem_wr_sel_o	),
	    .w_addr_i	(open_risc_v_mem_wr_addr_o	),
	    .w_data_i	(open_risc_v_mem_wr_data_o	),
	    .ren		(open_risc_v_mem_rd_req_o	),
	    .r_addr_i	(open_risc_v_mem_rd_addr_o	),
	    .r_data_o	(ram_rd_data_o				)
	);	

	rom rom_inst (
	    .clk     	(clk					),
	    .rst     	(debug					),
	
	    .w_en    	(uart_debug_wen			),
	    .w_addr_i	(uart_debug_addr_o		),
	    .w_data_i	(uart_debug_data_o		),
	
	    .r_en    	(1'b1					),
	    .r_addr_i	(open_risc_v_inst_addr_o),
	    .r_data_o	(rom_inst_o				) 
	);

	uart_debug uart_debug_inst(
    	.clk        (clk				),
    	.debug      (debug				),
    	.uart_rxd   (uart_rxd			),
    	.ce         (uart_debug_ce		),
    	.wen        (uart_debug_wen		),
    	.addr_o     (uart_debug_addr_o	),
    	.data_o		(uart_debug_data_o	)
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
endmodule