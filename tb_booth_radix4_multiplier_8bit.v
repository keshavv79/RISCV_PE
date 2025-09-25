`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2025 07:00:55 PM
// Design Name: 
// Module Name: tb_booth_radix4_multiplier_8bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_booth_radix4_multiplier_8bit;

  reg signed [31:0] multiplicand;
  reg signed [31:0] multiplier;
    reg clk, rst, start;
    wire signed [63:0] product;
    wire done;

    // To access internal debug signals from DUT, temporarily make them 'output' wires in DUT
    // Or simulate using $monitor/$display as shown below

    booth_radix4_multiplier_8bit uut (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .clk(clk),
        .rst(rst),
        .start(start),
        .product(product),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Debug monitor
    initial begin
        $display("Time\tclk\trst\tstart\tstate\tcount\tmult\tmcand\tproduct\tdone");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%d\t%d\t%d\t%d\t%b",
            $time, clk, rst, start, uut.state, uut.count,
            multiplier, multiplicand, product, done
        );
    end

    // Test sequence
    initial begin
        rst = 1;
        start = 0;
        multiplicand = 0;
        multiplier = 0;
        #20;

        rst = 0;
        #10;
        rst = 1;
        #20;

        // Test case 1: 3 * 5 = 15
        multiplicand = 32'sd10000;
        multiplier = -32'sd829742;
        start = 1; #10; start = 0;
        wait(done);
        #100;
        $display("3 * 5 = %d, Product = %d", 3*5, product);

        // Test case 2: 7 * -7 = -49
        multiplicand = 32'sd7;
        multiplier = -32'sd7;
        start = 1; #10; start = 0;
        wait(done);
        #10;
        $display("7 * -7 = %d, Product = %d", 7*(-7), product);

        // Test case 3: -5 * -9 = 45
      multiplicand = -32'sd5;
      multiplier = -32'sd9;
        start = 1; #10; start = 0;
        wait(done);
        #10;
        $display("-5 * -9 = %d, Product = %d", (-5)*(-9), product);

        // Test case 4: 0 * 11 = 0
        multiplicand = 32'sd0;
        multiplier = 32'sd11;
        start = 1; #10; start = 0;
        wait(done);
        #10;
        $display("0 * 11 = %d, Product = %d", 0*11, product);

        // Test case 5: -8 * 4 = -32
        multiplicand = -32'sd8;
        multiplier = 32'sd4;
        start = 1; #10; start = 0;
        wait(done);
        #10;
        $display("-8 * 4 = %d, Product = %d", -8*4, product);

        $display("Simulation complete");
        $stop;
    end

endmodule
