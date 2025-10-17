`timescale 1ns/1ps

module Wallace_8bit_TB;

    reg clk;
    reg rst;
    reg en;
    reg signed [7:0] A, B;
    wire signed [15:0] P;
    wire valid;

    booth_wallace_multiplier_seq uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .A(A),
        .B(B),
        .P(P),
        .valid(valid)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    integer i; // loop variable declared here

    initial begin
        $dumpfile("Wallace_8bit_TB.vcd");
        $dumpvars(0, Wallace_8bit_TB);

        rst = 1; en = 0; A = 0; B = 0;
        #20 rst = 0; en = 1;

        // Fixed test vectors
        A = 8'sd50;  B = 8'sd20;   #20;   // 50 * 20 = 1000
        A = -8'sd10; B = 8'sd12;   #20;   // -10 * 12 = -120
        A = 8'sd100; B = -8'sd5;   #20;   // 100 * -5 = -500
        A = -8'sd128; B = -8'sd1;  #20;   // -128 * -1 = 128
        A = 8'sd127; B = 8'sd127;  #20;   // 127 * 127 = 16129

        // Random tests
         for (i = 0; i < 10; i = i + 1) begin
            A = $random % 256;   // range 0 to 255
            B = $random % 256;
            // convert to signed 8-bit range (-128 to 127)
            if (A > 127) A = A - 256;
            if (B > 127) B = B - 256;
            #20;
        end

        #50;
        $display("Simulation finished");
        $finish;
    end

    initial begin
        $monitor("Time=%0t | A=%d B=%d | P=%d valid=%b", $time, A, B, P, valid);
    end

endmodule

