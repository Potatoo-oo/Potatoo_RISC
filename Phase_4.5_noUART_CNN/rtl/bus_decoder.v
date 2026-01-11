module bus_decoder(
    input wire [31:0]   w_addr,
    input wire [31:0]   r_addr,
    input wire          rd_req,
    input wire          wr_req,

    output wire         ram_sel,
    output wire         cnn_sel,
    output wire         gpio_sel
);

    wire[31:0] target_addr = wr_req? w_addr : rd_req? r_addr : 32'h0; 

    assign ram_sel  = ((target_addr < 32'hA000_0000) && (rd_req || wr_req));
    assign cnn_sel  = ((target_addr >= 32'hC000_0000) && (target_addr < 32'hC000_1000));        //C000_0000 to C000_1000
    assign gpio_sel = ((target_addr >= 32'hF000_0000) && (target_addr < 32'hF000_1000));        //F000_0000 to F000_1000


endmodule