module uart_debug(
    input wire              clk         ,
    input wire              debug         ,
    input wire              uart_rxd    ,
    output wire             ce          ,
    output wire             wen         ,
    output wire [31:0]      addr_o      ,
    output wire [31:0]      data_o

);

    wire       uart_recv_uart_done;
    wire[7:0]  uart_recv_uart_data;

    uart_recv uart_recv_inst(
        .sys_clk     (clk                   ),
        .sys_rst_n   (debug                 ),
        .uart_rxd    (uart_rxd              ),
        .uart_done   (uart_recv_uart_done   ),
        .uart_data   (uart_recv_uart_data   )
    );

    write2rom write2rom_inst(
        .clk                (clk                ),
        .debug              (debug              ),
        .rec_one_pocket     (uart_recv_uart_done),
        .rec_data           (uart_recv_uart_data),    
        .ce                 (ce                 ),
        .wen                (wen                ),
        .addr_o             (addr_o             ),
        .data_o             (data_o             )    
    );
endmodule

module write2rom(
    input wire              clk             ,
    input wire              debug           ,
    input wire              rec_one_pocket  ,
    input wire [7:0]        rec_data        ,    
    output reg              ce              ,
    output reg              wen             ,
    output reg [31:0]       addr_o          ,
    output reg [31:0]       data_o
);

    reg[2:0] cnt;

    //debug is active high
    always@(posedge clk)begin

        if(!debug)begin
            ce      <= 1'b0;                                    // chip enable
            wen     <= 1'b0;                                    // write enable
            cnt     <= 3'b0;                                    // counter
            addr_o  <= 32'b0;
            data_o  <= 32'b0;
        end
        else if (rec_one_pocket && cnt == 3'd3)begin            // word is done (32 bits)
            ce      <= 1'b1;
            wen     <= 1'b1;
            cnt     <= 3'b0;
            addr_o  <= addr_o + 1'd1;
            data_o  <= {data_o[23:0], rec_data};                // push LSB to front
        end
        else if(rec_one_pocket)begin                            // store byte per byte
            ce      <= 1'b0;
            wen     <= 1'b0;
            cnt     <= cnt + 1'b1;
            addr_o  <= addr_o; //+ 1'd1;                          // chatgpt say don't increment
            data_o  <= {data_o[23:0], rec_data};                //push LSB to front         
        end
    end
endmodule

module uart_recv(
    input               sys_clk     ,
    input               sys_rst_n   ,
    input               uart_rxd    ,
    output reg          uart_done   ,
    output reg [7:0]    uart_data

);

// Parameter Define
parameter   CLK_FREQ = 50000000;                    // system clock frequency
parameter   UART_BPS = 115200;                      // baud rate
localparam  BPS_CNT = CLK_FREQ / UART_BPS;          // Each UART bit last for 434 ticks

// Reg Define
reg         uart_rxd_d0;
reg         uart_rxd_d1;
reg [15:0]  clk_cnt;                                // system clock counter
reg         rx_flag;                                // receive flag
reg [3:0]   rx_cnt;                                 // receive coutner
reg [7:0]   rxdata;

// Wire Define
wire        start_flag;

// =================================== Main ===================================

assign start_flag = uart_rxd_d1 & (~uart_rxd_d0);   // detect start bit


// Delay UART receive by two clock cycle
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)begin
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;
    end
    else begin
        uart_rxd_d0  <= uart_rxd;
        uart_rxd_d1 <= uart_rxd_d0;
    end
end

// Flag Control 
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) 
        rx_flag <= 1'b0;
    else begin
        if(start_flag)
            rx_flag <= 1'b1;                        //undergoing receive
        else if((rx_cnt == 4'd9) && (clk_cnt == BPS_CNT/2))
            rx_flag <= 1'b0;                        //receive done
        else 
            rx_flag <= rx_flag;
    end
end

// Tick Counter
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        clk_cnt <= 16'd0;
    else if(rx_flag) begin
        if(clk_cnt < BPS_CNT - 1)                   // 434 ticks, 1 bit
            clk_cnt <= clk_cnt + 1'b1;
        else
            clk_cnt <= 16'd0;
    end
    else
        clk_cnt <= 16'd0;
end

// RX Bit Received Counter
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        rx_cnt <= 4'd0;
    else if (rx_flag) begin
        if( clk_cnt == BPS_CNT - 1 )                //434 Tick is up
            rx_cnt <= rx_cnt + 1'b1;
        else
            rx_cnt <= rx_cnt;
    end
    else
        rx_cnt <= 4'd0;
end

// UART Receive Data Bit
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        rxdata <= 8'd0;
    else if(rx_flag)
        if(clk_cnt == BPS_CNT/2) begin                    //data is best taken from the middle of the total ticks
            case(rx_cnt)
            4'd1 : rxdata[0] <= uart_rxd_d1;              //LSB
            4'd2 : rxdata[1] <= uart_rxd_d1;
            4'd3 : rxdata[2] <= uart_rxd_d1;
            4'd4 : rxdata[3] <= uart_rxd_d1;
            4'd5 : rxdata[4] <= uart_rxd_d1;
            4'd6 : rxdata[5] <= uart_rxd_d1;
            4'd7 : rxdata[6] <= uart_rxd_d1;
            4'd8 : rxdata[7] <= uart_rxd_d1;
            default:;
            endcase
        end
        else
            rxdata <= rxdata;
    else
        rxdata <= 8'd0;

end

//Final Stage
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin
        uart_data <= 8'd0;
        uart_done <= 1'd0;
    end
    else if(rx_cnt == 4'd9) begin
        uart_data <= rxdata;
        uart_done <= 1'b1;
    end
    else begin
        uart_data <= 8'd0;
        uart_done <= 1'b0;
    end
end

endmodule