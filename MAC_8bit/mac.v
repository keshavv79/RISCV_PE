`timescale 1ns/1ps

module top(
    input clk,
    input rst,
    input en,
    input wire finalize,
    input wire signed [7:0] a,
    input wire signed [7:0] b,
    output reg signed [15:0] out,
    output reg out_valid,
    output reg  signed [15:0] product_out
);
    wire signed [15:0] product;
    wire mult_valid;

    booth_wallace_multiplier_seq multiplier(
        .clk(clk),
        .en(en),
        .rst(rst),
        .A(a),
        .B(b),
        .P(product),
        .valid(mult_valid)
    );

    reg signed [15:0] acc_reg;
    wire signed [15:0] sum;
    wire cout;

    kogge_stone #(.N(16)) adder(
        .a(acc_reg),
        .b(product),
        .sum(sum),
        .cout(cout)
    );

     always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_reg  <= 0;
            out  <= 0;
            out_valid <= 0;
        end else begin
            if (mult_valid) begin
                acc_reg <= sum;
            end

            if (finalize) begin
                out <= acc_reg;
                out_valid <= 1;
            end else begin
                out_valid <= 0;
            end
        end
    end
    
    always @(posedge clk) begin
        if (mult_valid)
            product_out <= product;
    end
endmodule