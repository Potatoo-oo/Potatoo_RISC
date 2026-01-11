module ram(
    input wire          clk,
    input wire          rst,
    input wire [3:0]    wen,
    input wire [32-1:0] w_addr_i,
    input wire [32-1:0] w_data_i,
    input wire          ren,
    input wire [32-1:0] r_addr_i,
    input wire          ram_en,

    output wire [32-1:0] r_data_o
);

    wire[11:0] w_addr = w_addr_i[13:2];
    wire[11:0] r_addr = r_addr_i[13:2];

    wire ren_fin = ren && ram_en;
    wire wen_fin [3:0];

    assign wen_fin [3]= wen[3] && ram_en; 
    assign wen_fin [2]= wen[2] && ram_en; 
    assign wen_fin [1]= wen[1] && ram_en; 
    assign wen_fin [0]= wen[0] && ram_en; 


// ============================== RAM 0 =================================
   dual_ram #(
        .DW         (8     ),    
        .AW         (12    ),
        .MEM_NUM    (4096  ),
        .INIT_FILE  (""    )
    )
    ram_byte0
    (       
        .clk      (clk              ),
        .rst      (rst              ),

        .w_en     (wen_fin[0]       ),
        .w_addr_i (w_addr           ),
        .w_data_i (w_data_i[7:0]    ),

        .r_en     (ren_fin          ),
        .r_addr_i (r_addr           ),
        .r_data_o (r_data_o[7:0]    )       
    );

// ============================== RAM 1 =================================
   dual_ram #(
        .DW         (8     ),    
        .AW         (12    ),
        .MEM_NUM    (4096  ),
        .INIT_FILE  ("")        
    )
    ram_byte1
    (       
        .clk      (clk              ),
        .rst      (rst              ),

        .w_en     (wen_fin[1]       ),
        .w_addr_i (w_addr           ),
        .w_data_i (w_data_i[15:8]   ),

        .r_en     (ren_fin          ),
        .r_addr_i (r_addr           ),
        .r_data_o (r_data_o[15:8]   )       
    );

// ============================== RAM 2 =================================
   dual_ram #(
        .DW         (8     ),    
        .AW         (12    ),
        .MEM_NUM    (4096  ),
        .INIT_FILE  ("")        
    )
    ram_byte2
    (       
        .clk      (clk              ),
        .rst      (rst              ),

        .w_en     (wen_fin[2]       ),
        .w_addr_i (w_addr           ),
        .w_data_i (w_data_i[23:16]  ),

        .r_en     (ren_fin          ),
        .r_addr_i (r_addr           ),
        .r_data_o (r_data_o[23:16]  )       
    );

// ============================== RAM 3 =================================
   dual_ram #(
        .DW         (8     ),    
        .AW         (12    ),
        .MEM_NUM    (4096  ),
        .INIT_FILE  ("")
    )
    ram_byte3
    (       
        .clk      (clk              ),
        .rst      (rst              ),

        .w_en     (wen_fin[3]       ),
        .w_addr_i (w_addr           ),
        .w_data_i (w_data_i[31:24]  ),

        .r_en     (ren_fin          ),
        .r_addr_i (r_addr           ),
        .r_data_o (r_data_o[31:24]  )       
    );  
endmodule