module CSA #(parameter N=32)(
    input  wire [N-1:0] A,
    input  wire [N-1:0] B,
    input  wire [N-1:0] D,
    output wire [N-1:0] PS,
    output wire [N-1:0] PC
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : fa_gen
            FullAdder fa_inst (
                .a   (A[i]),
                .b   (B[i]),
                .cin (D[i]),
                .sum (PS[i]),
                .cout(PC[i])
            );
        end
    endgenerate
endmodule

