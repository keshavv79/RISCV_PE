`timescale 1ns/1ps

module Wallace_16bit_TB;

    reg clk;
    reg rst;
    reg en;
    reg signed [15:0] A, B;
    wire signed [31:0] P;
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
        $dumpfile("Wallace_16bit_TB.vcd");
        $dumpvars(0, Wallace_16bit_TB);

        rst = 1; en = 0; A = 0; B = 0;
        #20 rst = 0; en = 1;

        // Fixed test vectors
        A = 16'sd1234; B = 16'sd5678; #20;
        A = -16'sd1000; B = 16'sd2000; #20;
        A = 16'sd3000; B = -16'sd4000; #20;
        A = 16'sd32767; B = 16'sd32767; #20;

        // Random tests
        for (i = 0; i < 10; i = i + 1) begin
            A = ($random % 65536) - 32768;
            B = ($random % 65536) - 32768;
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

