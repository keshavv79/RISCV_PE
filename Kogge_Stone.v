`timescale 1ns/1ps
module kogge_stone #(
    parameter N = 32
)(
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] sum,
    output wire         cout
);
    // generate/propagate arrays per stage
    localparam D = $clog2(N);
    wire [N-1:0] G [0:D];
    wire [N-1:0] P [0:D];

    genvar i, j;
    // stage 0: initial generate/propagate
    generate
        for (i = 0; i < N; i = i + 1) begin : gp0
            assign G[0][i] = a[i] & b[i];
            assign P[0][i] = a[i] ^ b[i];
        end
    endgenerate

    // prefix stages
    generate
        for (i = 1; i <= D; i = i + 1) begin : prefix
            for (j = 0; j < N; j = j + 1) begin : compute
                if (j < (1 << (i-1))) begin
                    assign G[i][j] = G[i-1][j];
                    assign P[i][j] = P[i-1][j];
                end else begin
                    assign G[i][j] = G[i-1][j] | (P[i-1][j] & G[i-1][j - (1 << (i-1))]);
                    assign P[i][j] = P[i-1][j] & P[i-1][j - (1 << (i-1))];
                end
            end
        end
    endgenerate

    // compute carries and sums
    // carry into bit 0 is zero
    wire [N:0] c;
    assign c[0] = 1'b0;
    generate
        for (i = 0; i < N; i = i + 1) begin : carry_sum
            // carry into bit i+1 is G[D][i]
            assign c[i+1] = G[D][i];
            assign sum[i] = P[0][i] ^ c[i];
        end
    endgenerate

    assign cout = c[N];
endmodule


