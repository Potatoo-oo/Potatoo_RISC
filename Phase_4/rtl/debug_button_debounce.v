module debug_button_debounce(
    input wire          clk             ,
    input wire          rst             ,
    input wire          debug_button    ,
    output reg          debug           ,
    output reg          led_debug
);

    wire key_flag;
    wire key_value;

    key_debounce key_debounce_inst(
        .sys_clk        (clk            ),      // 50M clk
        .sys_rst_n      (rst            ),      // rst

        .key            (debug_button   ),      //input key
        .key_flag       (key_flag       ),      //flag for input
        .key_value      (key_value      )
    );

    always @(posedge clk) begin
        if(!rst) begin
            led_debug   <= 1'b0;
            debug       <= 1'b1;
        end
        else if(key_flag && !key_value) begin   //after debounce
            led_debug   <= ~led_debug;
            debug       <= ~debug;
        end
    end


endmodule

module key_debounce (
    input           sys_clk,                    // 50M clk
    input           sys_rst_n,                  // rst
    
    input           key,                        //input key
    output reg      key_flag,                   //flag for input
    output reg      key_value
);

    //Reg Define
    reg [31:0]  delay_cnt;
    reg         key_reg;

    // ==================================== Main ====================================

    //Delay when input change
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            key_reg     <= 1'b1;
            delay_cnt   <= 32'd0;
        end
        else begin
            key_reg     <= key;
            if(key_reg != key)                      // detect change in input 
                delay_cnt <= 32'd1000000;            // 20ms delay

            else if(key_reg == key) begin           // no change in input
                if(delay_cnt > 32'd0)               // in delay
                    delay_cnt <= delay_cnt - 1'b1;
                else
                    delay_cnt <= delay_cnt;         // delay finished
            end
        end
    end

    //Data detection
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if(!sys_rst_n) begin
            key_flag    <= 1'b0;
            key_value   <= 1'b1;
        end
        else begin
            if(delay_cnt == 32'd1) begin            // when it reaches 20ms of stable input
                key_flag    <= 1'b1;                // input detected
                key_value   <= key;                 // save data
            end
            else begin
                key_flag    <= 1'b0;
                key_value   <= key_value;
            end
        end
    end
endmodule