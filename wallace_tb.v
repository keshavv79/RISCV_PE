`timescale 1ns / 1ps

module tb_booth_wallace_seq;

    reg clk;
    reg rst;
    reg en;
    reg signed [31:0] A;
    reg signed [31:0] B;
    wire signed [63:0] P;
    wire valid;

    // Instantiate the sequential Booth-Wallace multiplier
    booth_wallace_multiplier_seq dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .A(A),
        .B(B),
        .P(P),
        .valid(valid)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // Test vectors
    initial begin
        // Initialize signals
        rst = 1;
        en  = 0;
        A = 0;
        B = 0;

        // Wait 2 clock cycles
        #12;
        rst = 0;

        // Test 1
        @(posedge clk);
        en = 1;
        A = 15;
        B = -4;

        @(posedge clk);
        en = 0;

        // Wait for output to register
        @(posedge clk);
        $display("Test 1: A=%d, B=%d => P=%d, valid=%b", A, B, P, valid);

        // Test 2
        @(posedge clk);
        en = 1;
        A = -25;
        B = -13;

        @(posedge clk);
        en = 0;
        @(posedge clk);
        $display("Test 2: A=%d, B=%d => P=%d, valid=%b", A, B, P, valid);

        // Test 3
        @(posedge clk);
        en = 1;
        A = 2147483647;
        B = 2;

        @(posedge clk);
        en = 0;
        @(posedge clk);
        $display("Test 3: A=%d, B=%d => P=%d, valid=%b", A, B, P, valid);

        // Test 4
        @(posedge clk);
        en = 1;
        A = -2147483648;
        B = 1;

        @(posedge clk);
        en = 0;
        @(posedge clk);
        $display("Test 4: A=%d, B=%d => P=%d, valid=%b", A, B, P, valid);

        $stop;
    end

endmodule
