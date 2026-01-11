module tb_cnn_accel;

    reg clk;
    reg rst;
    reg cnn_en;
    reg w_en;
    reg r_en;
    reg [31:0] w_addr;
    reg [31:0] r_addr;
    reg [31:0] wdata;
    wire [31:0] rdata;

    // Instantiate CNN accelerator
    cnn_accel uut (
        .clk(clk),
        .rst(rst),
        .cnn_en(cnn_en),
        .w_en(w_en),
        .r_en(r_en),
        .w_addr(w_addr),
        .r_addr(r_addr),
        .wdata(wdata),
        .rdata(rdata),
        .done()
    );

    // Clock generation
    always #100 clk = ~clk;

    reg[15:0] i_loop;
    reg[7:0] value;

    
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        cnn_en = 0;
        w_en = 0;
        r_en = 0;
        w_addr = 0;
        r_addr = 0;
        wdata = 0;
        value = 1;

        // Reset pulse
        #100; rst = 1; cnn_en = 1; w_en = 1;
        #100; rst = 1;

        // ============================================
        // Write image data (5x5)
        // ============================================
        $display("Writing Image Data (5x5)...");
        for (i_loop = 0; i_loop < 25; i_loop = i_loop + 1) begin
            @(posedge clk);
            w_en   = 1;
            w_addr = 12'h004;                // Image write address
            wdata  = {i_loop[15:0], 8'b0,  value[7:0]};   // upper 16 bits = index, lower 8 bits = value
            value  = value + 1;
        end
        @(posedge clk);
        w_en = 0;
        value = 1;

        // ============================================
        // Write kernel data (3x3)
        // ============================================
        $display("Writing Kernel Data (3x3)...");
        for (i_loop= 0; i_loop< 9; i_loop= i_loop+ 1) begin
            @(posedge clk);
            w_en   = 1;
            w_addr = 12'h008;                // Kernel write address
            wdata  = {i_loop[15:0], 8'b0, value[7:0]};  // upper 16 bits = index, lower 8 bits = value
            value  = value + 1;
        end
        @(posedge clk);
        w_en = 0;
        value =1;

        // ============================================
        // Start convolution
        // ============================================
        $display("Starting CNN Convolution...");
        @(posedge clk);
        w_en   = 1;
        w_addr = 12'h00C;                    // Start register
        wdata  = 32'h1;
        @(posedge clk);
        w_en   = 0;

        // ============================================
        // Wait for completion
        // ============================================
        $display("Waiting for CNN to complete...");
        wait(uut.done == 1);
        @(posedge clk);

        // ============================================
        // Read results
        // ============================================
        $display("Reading CNN Results...");
        for (i_loop= 0; i_loop< 9; i_loop= i_loop+ 1) begin
            @(posedge clk);
            r_en  = 1;
            r_addr = 12'h080 + (i_loop* 4);
            #1 $display("result[%0d] = %d", i_loop, rdata[15:0]);
        end

        $display("=== CNN Test Completed ===");
        $stop;
    end

endmodule
