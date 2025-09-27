module tb_booth_wallace_multiplier;

    // DUT inputs/outputs
    reg  signed [31:0] A, B;
    wire signed [63:0] P;

    // Instantiate DUT
    booth_wallace_multiplier dut (
        .A(A),
        .B(B),
        .P(P)
    );

    // Golden reference
    reg signed [63:0] golden;

    integer i;

    initial begin
        $display("==============================================");
        $display("   Booth-Wallace Multiplier Testbench");
        $display("==============================================");

        // Fixed test cases first
        A = 0; B = 0; #10;
        golden = A * B;
        check_result;

        A = 32'd7; B = 32'd9; #10;
        golden = A * B;
        check_result;

        A = -32'd15; B = 32'd4; #10;
        golden = A * B;
        check_result;

        A = -32'd25; B = -32'd13; #10;
        golden = A * B;
        check_result;

        A = 32'h7FFFFFFF; B = 32'h00000002; #10;
        golden = A * B;
        check_result;

        A = 32'h80000000; B = 32'd1; #10; // most negative
        golden = A * B;
        check_result;

        // Random tests
        for (i = 0; i < 20; i = i + 1) begin
            A = $random;
            B = $random;
            #10;
            golden = A * B;
            check_result;
        end

        $display("==============================================");
        $display("   Simulation Completed");
        $display("==============================================");
        $finish;
    end

    task check_result;
        begin
            if (P !== golden) begin
                $display("ERROR: A=%0d, B=%0d => DUT=%0d, GOLDEN=%0d",
                          A, B, P, golden);
            end else begin
                $display("PASS:  A=%0d, B=%0d => P=%0d",
                          A, B, P);
            end
        end
    endtask

endmodule
