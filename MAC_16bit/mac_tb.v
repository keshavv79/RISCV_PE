`timescale 1ns/1ps

module top_tb;

    // Signals
    reg clk;
    reg rst;
    reg en;
    reg finalize;
    reg signed [15:0] a, b;
    wire signed [31:0] out;
    wire out_valid;
    wire signed [31:0] product_out;

    // Instantiate the DUT (Device Under Test)
    top uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .finalize(finalize),
        .a(a),
        .b(b),
        .out(out),
        .out_valid(out_valid),
        .product_out(product_out)
    );

    // Clock generation: 100 MHz (period = 10 ns)
    always #5 clk = ~clk;

    // Task to apply input
    task apply_input;
        input signed [15:0] a_in;
        input signed [15:0] b_in;
        begin
            @(posedge clk);
            en = 1;
            a = a_in;
            b = b_in;
        end
    endtask

    // Task to stop input
    task stop_input;
        begin
            @(posedge clk);
            en = 0;
            a = 0;
            b = 0;
        end
    endtask

    // Test sequence
    initial begin
        // VCD dump for GTKWave
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Initialize
        clk = 0;
        rst = 1;
        en = 0;
        finalize = 0;
        a = 0;
        b = 0;

        // Reset for a few cycles
        #2;
        rst = 0;

        // Apply multiple inputs (back-to-back)
        apply_input(10, 5);   // product = 50
        apply_input(6, 7);    // product = 42
        apply_input(3, 4);    // product = 12
        stop_input();

        // Wait for pipeline latency (assume ~8 cycles)
        repeat (8) @(posedge clk);

        // Finalize accumulation
        @(posedge clk);
        finalize = 1;
        @(posedge clk);
        finalize = 0;

        // Wait until out_valid goes high
        wait(out_valid);
        $display("Final accumulated result = %d", out);

        // Small delay to see final waveform
        #20;
        $finish;
    end

    // Display intermediate products and accumulation
    always @(posedge clk) begin
        if (out_valid)
            $display("[%0t ns] >>> Final accumulated output = %d <<<", $time, out);
    end

endmodule
