// module cnn_accel(
//     input wire          clk,
//     input wire          rst,
//     input wire          cnn_en,                 //cnn_sel

//     input wire          w_en,
//     input wire          r_en,
//     input wire[31:0]    w_addr,
//     input wire[31:0]    r_addr,
//     input wire[31:0]    wdata,

//     output reg[31:0]    rdata,
//     output reg          done
// );

//     // Address decode Range
//     wire[11:0] local_w_addr = w_addr[11:0];               //4KB window
//     wire[11:0] local_r_addr = r_addr[11:0]; 

//     // CNN registers / memories
//     reg [7:0]       image[0:24];                // 5x5 image
//     reg [7:0]       kernel[0:8];                // 3x3 kernel
//     reg [15:0]      result[0:8];                //3x3 output map
    
//     // Flag
//     reg start;


//     integer i, j, m, n, sum;

//     // MAIN -- STORE DATA
//     always @(posedge clk) begin
//         if(!rst)begin
//             start   <= 1'b0;
//             done    <= 1'b0;
//         end
//         else if (cnn_en && w_en) begin
//             case(local_w_addr)
//                 12'h000: start <= 1'b1;        // CTRL register
//                 12'h004: image[wdata[31:16]]   <= wdata[7:0];   // data in index upper half, value in low 8 bits, feed in values of each pixel 1 by 1
//                 12'h008: kernel[wdata[31:16]]  <= wdata[7:0];   //kernel
//                 default:begin
//                     start <= start;
//                     // image[0:24] <= image [0:24];
//                     // kernel[0:8] <= kernel[0:8];
//                 end
//             endcase
//         end 
//     end 

//     // CONVOLUTION
//     always @(posedge clk)begin
//         if (!rst) begin
//             done <= 1'b0;
//         end
//         else if (start) begin

//             //perform 3x3 convolution over 5x5 image
//             for( i = 0 ; i < 3 ; i = i + 1 )begin
//                 for( j = 0 ; j < 3 ; j = j + 1 )begin
//                     sum = 0;

//                     for( m = 0 ; m < 3 ; m = m + 1 )begin
//                         for( n = 0 ; n < 3 ; n = n + 1 ) begin
//                             sum = sum + image[(i + m) * 5 + (j + n)] * kernel [m * 3 + n];          //accumulator
//                             // 1D array index = row * total column + column - kernel
//                             // +m and +n is because of deal with 5x5 and 3x3, kernel next row, img next row
//                         end
//                     end

//                     result[i*3 + j] <= sum[15:0];
//                 end
//             end

//             done    <= 1'b1;
//             start   <= 1'b0;                    // auto clear
//         end
//     end

//     // READ OPERATION
//     always @(*)begin
//         if (cnn_en && r_en)begin 
//             case(local_r_addr)
//                 12'h000: rdata = {30'b0, done, start};  //CTRL register
//                 12'h080: rdata = {16'b0, result[0]};
//                 12'h084: rdata = {16'b0, result[1]};
//                 12'h088: rdata = {16'b0, result[2]};
//                 12'h08C: rdata = {16'b0, result[3]};
//                 12'h090: rdata = {16'b0, result[4]};
//                 12'h094: rdata = {16'b0, result[5]};
//                 12'h098: rdata = {16'b0, result[6]};
//                 12'h09C: rdata = {16'b0, result[7]};
//                 12'h0A0: rdata = {16'b0, result[8]};
//                 default: rdata = 32'b0;
//             endcase
//         end
//         else begin
//             rdata = 32'b0;                              // Default not driving bus
//         end
//     end


// endmodule

// module cnn_accel(
//     input wire          clk,
//     input wire          rst,
//     input wire          cnn_en,                 //cnn_sel

//     input wire          w_en,
//     input wire          r_en,
//     input wire[31:0]    w_addr,
//     input wire[31:0]    r_addr,
//     input wire[31:0]    wdata,

//     output reg[31:0]    rdata,
//     output reg          done
// );

//     // Address decode Range
//     wire[11:0] local_w_addr = w_addr[11:0];               //4KB window
//     wire[11:0] local_r_addr = r_addr[11:0]; 

//     // CNN registers / memories
//     reg [7:0]       image[0:24];                // 5x5 image
//     reg [7:0]       kernel[0:8];                // 3x3 kernel
//     reg [15:0]      result[0:8];                // 3x3 output map
    
//     // Control signals
//     reg start;
//     reg data_ready;  // Flag to indicate all data loaded

//     // State machine
//     localparam IDLE       = 3'd0;
//     localparam ENTER      = 3'd1;
//     localparam COMPUTE    = 3'd2;
//     localparam DONE_STATE = 3'd3;

//     reg [2:0] state, next_state;

//     // Counter for which output pixel we're computing (0-8)
//     reg [3:0] pixel_idx;
//     reg [3:0] next_pixel_idx;
    
//     // Temporary registers for parallel MAC operations
//     reg [15:0] mac_result[0:8];  // 9 parallel accumulators
//     integer k;

//     // MAIN -- STORE DATA
//     always @(posedge clk) begin
//         if(!rst) begin
//             start <= 1'b0;
//             data_ready <= 1'b0;
//         end
//         else if (cnn_en && w_en) begin
//             case(local_w_addr)
//                 12'h000: begin
//                     start <= 1'b1;
//                     data_ready <= 1'b0;  // Reset data_ready when starting
//                 end
//                 12'h004: image[wdata[31:16]]   <= wdata[7:0];
//                 12'h008: kernel[wdata[31:16]]  <= wdata[7:0];
//                 12'h00C: data_ready <= 1'b1;   // Signal that data is ready
//                 default: start <= start;
//             endcase
//         end 
//         else if (state == DONE_STATE) begin
//             start <= 1'b0;  // Auto clear when done
//         end
//     end 

//     // STATE REGISTER
//     always @(posedge clk) begin
//         if (!rst) begin
//             state <= IDLE;
//         end
//         else begin
//             state <= next_state;
//         end
//     end

//     // PIXEL INDEX COUNTER
//     always @(posedge clk) begin
//         if (!rst) begin
//             pixel_idx <= 4'd0;
//         end
//         else begin
//             pixel_idx <= next_pixel_idx;
//         end
//     end

//     // PARALLEL MAC COMPUTATION
//     // For each output pixel, compute all 9 MACs in one cycle
//     always @(posedge clk) begin
//         if (!rst) begin
//             for (k = 0; k < 9; k = k + 1) begin
//                 mac_result[k] <= 16'd0;
//             end
//         end
//         else if (state == COMPUTE) begin
//             // Compute current output pixel (pixel_idx tells us which one)
//             // pixel_idx = out_row * 3 + out_col
//             // Extract out_row and out_col from pixel_idx
            
//             // Do all 9 kernel multiplications in parallel for this output pixel
//             mac_result[0] <= image[(pixel_idx/3 + 0)*5 + (pixel_idx%3 + 0)] * kernel[0*3 + 0];
//             mac_result[1] <= image[(pixel_idx/3 + 0)*5 + (pixel_idx%3 + 1)] * kernel[0*3 + 1];
//             mac_result[2] <= image[(pixel_idx/3 + 0)*5 + (pixel_idx%3 + 2)] * kernel[0*3 + 2];
//             mac_result[3] <= image[(pixel_idx/3 + 1)*5 + (pixel_idx%3 + 0)] * kernel[1*3 + 0];
//             mac_result[4] <= image[(pixel_idx/3 + 1)*5 + (pixel_idx%3 + 1)] * kernel[1*3 + 1];
//             mac_result[5] <= image[(pixel_idx/3 + 1)*5 + (pixel_idx%3 + 2)] * kernel[1*3 + 2];
//             mac_result[6] <= image[(pixel_idx/3 + 2)*5 + (pixel_idx%3 + 0)] * kernel[2*3 + 0];
//             mac_result[7] <= image[(pixel_idx/3 + 2)*5 + (pixel_idx%3 + 1)] * kernel[2*3 + 1];
//             mac_result[8] <= image[(pixel_idx/3 + 2)*5 + (pixel_idx%3 + 2)] * kernel[2*3 + 2];
//         end
//     end

//     // ACCUMULATE AND STORE RESULT
//     // One cycle after MAC, accumulate and store
//     always @(posedge clk) begin
//         if (!rst) begin
//             result[0] <= 16'd0;
//             result[1] <= 16'd0;
//             result[2] <= 16'd0;
//             result[3] <= 16'd0;
//             result[4] <= 16'd0;
//             result[5] <= 16'd0;
//             result[6] <= 16'd0;
//             result[7] <= 16'd0;
//             result[8] <= 16'd0;
//         end
//         else if (state == COMPUTE && pixel_idx < 4'd9) begin
//             // Sum all 9 MAC results and store
//             result[pixel_idx] <= mac_result[0] + mac_result[1] + mac_result[2] +
//                                  mac_result[3] + mac_result[4] + mac_result[5] +
//                                  mac_result[6] + mac_result[7] + mac_result[8];
//         end
//     end

//     // NEXT STATE LOGIC
//     always @(*) begin
//         // Defaults
//         next_state = state;
//         next_pixel_idx = pixel_idx;
//         done = 1'b0;

//         case(state)
//             IDLE: begin
//                 if (start) begin
//                     next_state = ENTER;
//                     next_pixel_idx = 4'd0;
//                 end
//             end
            
//             ENTER: begin
//                 // Wait for all data to be loaded
//                 if (data_ready) begin
//                     next_state = COMPUTE;
//                     next_pixel_idx = 4'd0;
//                 end
//             end
                
//             COMPUTE: begin
//                 // Process one output pixel per cycle
//                 if (pixel_idx < 4'd8) begin
//                     next_pixel_idx = pixel_idx + 1'd1;
//                 end
//                 else begin
//                     // Finished all 9 output pixels
//                     next_state = DONE_STATE;
//                     next_pixel_idx = 4'd0;
//                 end
//             end

//             DONE_STATE: begin
//                 done = 1'b1;
//                 next_state = IDLE;
//                 next_pixel_idx = 4'd0;
//             end

//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // READ OPERATION
//     always @(*) begin
//         if (cnn_en && r_en) begin 
//             case(local_r_addr)
//                 12'h000: rdata = {29'b0, data_ready, done, start};  // CTRL register
//                 12'h080: rdata = {16'b0, result[0]};
//                 12'h084: rdata = {16'b0, result[1]};
//                 12'h088: rdata = {16'b0, result[2]};
//                 12'h08C: rdata = {16'b0, result[3]};
//                 12'h090: rdata = {16'b0, result[4]};
//                 12'h094: rdata = {16'b0, result[5]};
//                 12'h098: rdata = {16'b0, result[6]};
//                 12'h09C: rdata = {16'b0, result[7]};
//                 12'h0A0: rdata = {16'b0, result[8]};
//                 default: rdata = 32'b0;
//             endcase
//         end
//         else begin
//             rdata = 32'b0;
//         end
//     end

// endmodule

module cnn_accel(
    input wire          clk,
    input wire          rst,
    input wire          cnn_en,                 //cnn_sel

    input wire          w_en,
    input wire          r_en,
    input wire[31:0]    w_addr,
    input wire[31:0]    r_addr,
    input wire[31:0]    wdata,

    output reg[31:0]    rdata,
    output reg          done
);

    // Address decode Range
    wire[11:0] local_w_addr = w_addr[11:0];               //4KB window
    wire[11:0] local_r_addr = r_addr[11:0]; 

    // CNN registers / memories
    reg [7:0]       image[0:24];                // 5x5 image
    reg [7:0]       kernel[0:8];                // 3x3 kernel
    reg [15:0]      result[0:8];                // 3x3 output map

    // Auto-incrementing counters for loading data
    reg [4:0] image_counter;   // 0-24 for image
    reg [3:0] kernel_counter;  // 0-8 for kernel
    
    // Control signals
    reg start;
    reg data_ready;  // Flag to indicate all data loaded

    // State machine
    localparam IDLE       = 3'd0;
    localparam ENTER      = 3'd1;
    localparam COMPUTE    = 3'd2;
    localparam DONE_STATE = 3'd3;

    reg [2:0] state, next_state;

    // Counter for which output pixel we're computing (0-8)
    reg [3:0] pixel_idx;
    reg [3:0] next_pixel_idx;
    reg [3:0] pixel_idx_delayed;  // One cycle delayed for storing results
    
    // Temporary registers for parallel MAC operations
    reg [15:0] mac_result[0:8];  // 9 parallel accumulators
    integer k;

    // MAIN -- STORE DATA
    always @(posedge clk) begin
        if(!rst) begin
            start <= 1'b0;
            data_ready <= 1'b0;
            image_counter <= 5'd0;
            kernel_counter <= 4'd0;
        end
        else if (cnn_en && w_en) begin
            case(local_w_addr)
                12'h000: begin
                    start <= 1'b1;
                    data_ready <= 1'b0;  // Reset data_ready when starting
                    // Reset counters when starting new operation
                    image_counter <= 5'd0;
                    kernel_counter <= 4'd0;
                end
                12'h004: begin
                   image[image_counter] <= wdata[7:0];
                    if (image_counter < 5'd24)
                        image_counter <= image_counter + 1'd1;
                end
                12'h008: begin
                    kernel[kernel_counter]  <= wdata[7:0];
                    if (kernel_counter < 4'd8)
                        kernel_counter <= kernel_counter + 1'd1;
                end
                12'h00C: data_ready <= 1'b1;   // Signal that data is ready
                default: start <= start;
            endcase
        end 
        else if (state == DONE_STATE) begin
            start <= 1'b0;  // Auto clear when done
        end
    end 

    // STATE REGISTER
    always @(posedge clk) begin
        if (!rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // PIXEL INDEX COUNTER
    always @(posedge clk) begin
        if (!rst) begin
            pixel_idx <= 4'd0;
            pixel_idx_delayed <= 4'd0;
        end
        else begin
            pixel_idx <= next_pixel_idx;
            pixel_idx_delayed <= pixel_idx;  // Delay by one cycle
        end
    end

    // PARALLEL MAC COMPUTATION
    // For each output pixel, compute all 9 MACs in one cycle
    always @(posedge clk) begin
        if (!rst) begin
            for (k = 0; k < 9; k = k + 1) begin
                mac_result[k] <= 16'd0;
            end
        end
        else if (state == COMPUTE) begin
            // Compute current output pixel (pixel_idx tells us which one)
            // pixel_idx = out_row * 3 + out_col
            // Extract out_row and out_col from pixel_idx
            
            // Do all 9 kernel multiplications in parallel for this output pixel
            mac_result[0] <= image[(pixel_idx/3 + 0)*5 + (pixel_idx%3 + 0)] * kernel[0*3 + 0];
            mac_result[1] <= image[(pixel_idx/3 + 0)*5 + (pixel_idx%3 + 1)] * kernel[0*3 + 1];
            mac_result[2] <= image[(pixel_idx/3 + 0)*5 + (pixel_idx%3 + 2)] * kernel[0*3 + 2];
            mac_result[3] <= image[(pixel_idx/3 + 1)*5 + (pixel_idx%3 + 0)] * kernel[1*3 + 0];
            mac_result[4] <= image[(pixel_idx/3 + 1)*5 + (pixel_idx%3 + 1)] * kernel[1*3 + 1];
            mac_result[5] <= image[(pixel_idx/3 + 1)*5 + (pixel_idx%3 + 2)] * kernel[1*3 + 2];
            mac_result[6] <= image[(pixel_idx/3 + 2)*5 + (pixel_idx%3 + 0)] * kernel[2*3 + 0];
            mac_result[7] <= image[(pixel_idx/3 + 2)*5 + (pixel_idx%3 + 1)] * kernel[2*3 + 1];
            mac_result[8] <= image[(pixel_idx/3 + 2)*5 + (pixel_idx%3 + 2)] * kernel[2*3 + 2];
        end
    end

    // ACCUMULATE AND STORE RESULT
    // One cycle after MAC, accumulate and store
    always @(posedge clk) begin
        if (!rst) begin
            result[0] <= 16'd0;
            result[1] <= 16'd0;
            result[2] <= 16'd0;
            result[3] <= 16'd0;
            result[4] <= 16'd0;
            result[5] <= 16'd0;
            result[6] <= 16'd0;
            result[7] <= 16'd0;
            result[8] <= 16'd0;
        end
        else if (state == COMPUTE && pixel_idx_delayed < 4'd9) begin
            // Sum all 9 MAC results and store using delayed index
            result[pixel_idx_delayed] <= mac_result[0] + mac_result[1] + mac_result[2] +
                                         mac_result[3] + mac_result[4] + mac_result[5] +
                                         mac_result[6] + mac_result[7] + mac_result[8];
        end
    end

    // NEXT STATE LOGIC
    always @(*) begin
        // Defaults
        next_state = state;
        next_pixel_idx = pixel_idx;
        done = 1'b0;

        case(state)
            IDLE: begin
                if (start) begin
                    next_state = ENTER;
                    next_pixel_idx = 4'd0;
                end
            end
            
            ENTER: begin
                // Wait for all data to be loaded
                if (data_ready) begin
                    next_state = COMPUTE;
                    next_pixel_idx = 4'd0;
                end
            end
                
            COMPUTE: begin
                // Process one output pixel per cycle
                if (pixel_idx < 4'd9) begin
                    next_pixel_idx = pixel_idx + 1'd1;
                end
                else begin
                    // Finished all 9 output pixels
                    next_state = DONE_STATE;
                    next_pixel_idx = 4'd0;
                end
            end

            DONE_STATE: begin
                done = 1'b1;
                next_state = IDLE;
                next_pixel_idx = 4'd0;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // READ OPERATION
    always @(*) begin
        if (cnn_en && r_en) begin 
            case(local_r_addr)
                12'h000: rdata = {29'b0, data_ready, done, start};  // CTRL register
                12'h080: rdata = {16'b0, result[0]};
                12'h084: rdata = {16'b0, result[1]};
                12'h088: rdata = {16'b0, result[2]};
                12'h08C: rdata = {16'b0, result[3]};
                12'h090: rdata = {16'b0, result[4]};
                12'h094: rdata = {16'b0, result[5]};
                12'h098: rdata = {16'b0, result[6]};
                12'h09C: rdata = {16'b0, result[7]};
                12'h0A0: rdata = {16'b0, result[8]};
                default: rdata = 32'b0;
            endcase
        end
        else begin
            rdata = 32'b0;
        end
    end

endmodule