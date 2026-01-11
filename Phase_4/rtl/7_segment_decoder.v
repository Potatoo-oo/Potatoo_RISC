module seven_seg_decoder (
    input wire          clk,
    input wire          rst,
    input wire[31:0]    input0,
    input wire[31:0]    addr_i,
    input wire[31:0]    inst_i,

    //LSB
    output reg [6:0]    output_0,
    output reg [6:0]    output_addr_0,
    output reg [6:0]    clk_0,
    //MSB
    output reg [6:0]    output_1,
    output reg [6:0]    output_addr_1,
    output reg [6:0]    clk_1

);

    wire [6:0]  decimal_value;
    wire [3:0]  ones;
    wire [3:0]  tens;

    assign decimal_value    = input0 % 100;
    assign ones             = decimal_value % 10;
    assign tens             = decimal_value / 10;

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            output_0 <= 7'b1111111;
            output_1 <= 7'b1111111;
        end
        else begin   
            case(ones)
                4'd0: output_0      <= 7'b1000000;        // digit 0
                4'd1: output_0      <= 7'b1111001;        // digit 1
                4'd2: output_0      <= 7'b0100100;        // digit 2
                4'd3: output_0      <= 7'b0110000;        // digit 3
                4'd4: output_0      <= 7'b0011001;        // digit 4
                4'd5: output_0      <= 7'b0010010;        // digit 5
                4'd6: output_0      <= 7'b0000010;        // digit 6
                4'd7: output_0      <= 7'b1111000;        // digit 7
                4'd8: output_0      <= 7'b0000000;        // digit 8
                4'd9: output_0      <= 7'b0011000;        // digit 9
                default: output_0   <= 7'b1111111;        // nothing output
            endcase
            case(tens)
                4'd0: output_1      <= 7'b1000000;        // digit 0
                4'd1: output_1      <= 7'b1111001;        // digit 1
                4'd2: output_1      <= 7'b0100100;        // digit 2
                4'd3: output_1      <= 7'b0110000;        // digit 3
                4'd4: output_1      <= 7'b0011001;        // digit 4
                4'd5: output_1      <= 7'b0010010;        // digit 5
                4'd6: output_1      <= 7'b0000010;        // digit 6
                4'd7: output_1      <= 7'b1111000;        // digit 7
                4'd8: output_1      <= 7'b0000000;        // digit 8
                4'd9: output_1      <= 7'b0011000;        // digit 9
                default: output_1   <= 7'b1111111;        // nothing output
            endcase
        end

    end
    // // address counter
    // wire [6:0]  decimal_value_addr;
    // wire [3:0]  ones_addr;
    // wire [3:0]  tens_addr;

    // assign decimal_value_addr   = addr_i % 100;
    // assign ones_addr            = decimal_value_addr % 10;
    // assign tens_addr            = decimal_value_addr / 10;

    // always @(posedge clk or negedge rst) begin
    //     if(!rst) begin
    //         output_addr_0 <= 7'b1111111;
    //         output_addr_1 <= 7'b1111111;
    //     end
    //     else begin   
    //         case(ones_addr)
    //             4'd0: output_addr_0      <= 7'b1000000;        // digit 0
    //             4'd1: output_addr_0      <= 7'b1111001;        // digit 1
    //             4'd2: output_addr_0      <= 7'b0100100;        // digit 2
    //             4'd3: output_addr_0      <= 7'b0110000;        // digit 3
    //             4'd4: output_addr_0      <= 7'b0011001;        // digit 4
    //             4'd5: output_addr_0      <= 7'b0010010;        // digit 5
    //             4'd6: output_addr_0      <= 7'b0000010;        // digit 6
    //             4'd7: output_addr_0      <= 7'b1111000;        // digit 7
    //             4'd8: output_addr_0      <= 7'b0000000;        // digit 8
    //             4'd9: output_addr_0      <= 7'b0011000;        // digit 9
    //             default: output_addr_0   <= 7'b1111111;        // nothing output
    //         endcase
    //         case(tens_addr)
    //             4'd0: output_addr_1      <= 7'b1000000;        // digit 0
    //             4'd1: output_addr_1      <= 7'b1111001;        // digit 1
    //             4'd2: output_addr_1      <= 7'b0100100;        // digit 2
    //             4'd3: output_addr_1      <= 7'b0110000;        // digit 3
    //             4'd4: output_addr_1      <= 7'b0011001;        // digit 4
    //             4'd5: output_addr_1      <= 7'b0010010;        // digit 5
    //             4'd6: output_addr_1      <= 7'b0000010;        // digit 6
    //             4'd7: output_addr_1      <= 7'b1111000;        // digit 7
    //             4'd8: output_addr_1      <= 7'b0000000;        // digit 8
    //             4'd9: output_addr_1      <= 7'b0011000;        // digit 9
    //             default: output_addr_1   <= 7'b1111111;        // nothing output
    //         endcase
    //     end

    // end

    // instruction

    wire [3:0]  hex0;
    wire [3:0]  hex1;

    assign hex0            = inst_i[3:0];
    assign hex1            = inst_i[7:4];

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            output_addr_0 <= 7'b1111111;
            output_addr_1 <= 7'b1111111;
        end
        else begin   
            case(hex0)
                4'h0: output_addr_0 <= 7'b1000000;              // 0
                4'h1: output_addr_0 <= 7'b1111001;              // 1
                4'h2: output_addr_0 <= 7'b0100100;              // 2
                4'h3: output_addr_0 <= 7'b0110000;              // 3
                4'h4: output_addr_0 <= 7'b0011001;              // 4
                4'h5: output_addr_0 <= 7'b0010010;              // 5
                4'h6: output_addr_0 <= 7'b0000010;              // 6
                4'h7: output_addr_0 <= 7'b1111000;              // 7
                4'h8: output_addr_0 <= 7'b0000000;              // 8
                4'h9: output_addr_0 <= 7'b0011000;              // 9
                4'hA: output_addr_0 <= 7'b0001000;              // A
                4'hB: output_addr_0 <= 7'b0000011;              // b
                4'hC: output_addr_0 <= 7'b1000110;              // C
                4'hD: output_addr_0 <= 7'b0100001;              // d
                4'hE: output_addr_0 <= 7'b0000110;              // E
                4'hF: output_addr_0 <= 7'b0001110;              // F
                default: output_addr_0 <= 7'b1111111;           // nothing output
            endcase
            case(hex1)
                4'h0: output_addr_1 <= 7'b1000000;              // 0
                4'h1: output_addr_1 <= 7'b1111001;              // 1
                4'h2: output_addr_1 <= 7'b0100100;              // 2
                4'h3: output_addr_1 <= 7'b0110000;              // 3
                4'h4: output_addr_1 <= 7'b0011001;              // 4
                4'h5: output_addr_1 <= 7'b0010010;              // 5
                4'h6: output_addr_1 <= 7'b0000010;              // 6
                4'h7: output_addr_1 <= 7'b1111000;              // 7
                4'h8: output_addr_1 <= 7'b0000000;              // 8
                4'h9: output_addr_1 <= 7'b0011000;              // 9
                4'hA: output_addr_1 <= 7'b0001000;              // A
                4'hB: output_addr_1 <= 7'b0000011;              // b
                4'hC: output_addr_1 <= 7'b1000110;              // C
                4'hD: output_addr_1 <= 7'b0100001;              // d
                4'hE: output_addr_1 <= 7'b0000110;              // E
                4'hF: output_addr_1 <= 7'b0001110;              // F
                default: output_addr_1 <= 7'b1111111;           // nothing output
            endcase
        end

    end

    //clk counter
    reg [6:0]  decimal_value_cnt;
    reg [3:0]  ones_cnt;
    reg [3:0]  tens_cnt;
    

   

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            clk_0               <= 7'b1111111;
            clk_1               <= 7'b1111111;
            decimal_value_cnt   <= 6'b0;
        end
        else begin
            //increment counter
            if(decimal_value_cnt == 99)
                decimal_value_cnt <= 0;
            else
                decimal_value_cnt <= decimal_value_cnt +1;

            ones_cnt <= decimal_value_cnt % 10;
            tens_cnt <= decimal_value_cnt / 10;

            case(ones_cnt)
                4'd0: clk_0      <= 7'b1000000;        // digit 0
                4'd1: clk_0      <= 7'b1111001;        // digit 1
                4'd2: clk_0      <= 7'b0100100;        // digit 2
                4'd3: clk_0      <= 7'b0110000;        // digit 3
                4'd4: clk_0      <= 7'b0011001;        // digit 4
                4'd5: clk_0      <= 7'b0010010;        // digit 5
                4'd6: clk_0      <= 7'b0000010;        // digit 6
                4'd7: clk_0      <= 7'b1111000;        // digit 7
                4'd8: clk_0      <= 7'b0000000;        // digit 8
                4'd9: clk_0      <= 7'b0011000;        // digit 9
                default: clk_0   <= 7'b1111111;        // nothing output
            endcase
            case(tens_cnt)
                4'd0: clk_1      <= 7'b1000000;        // digit 0
                4'd1: clk_1      <= 7'b1111001;        // digit 1
                4'd2: clk_1      <= 7'b0100100;        // digit 2
                4'd3: clk_1      <= 7'b0110000;        // digit 3
                4'd4: clk_1      <= 7'b0011001;        // digit 4
                4'd5: clk_1      <= 7'b0010010;        // digit 5
                4'd6: clk_1      <= 7'b0000010;        // digit 6
                4'd7: clk_1      <= 7'b1111000;        // digit 7
                4'd8: clk_1      <= 7'b0000000;        // digit 8
                4'd9: clk_1      <= 7'b0011000;        // digit 9
                default: clk_1   <= 7'b1111111;        // nothing output
            endcase
        end

    end

endmodule