module CSA #(parameter N=64)(
    input wire [N-1:0] A, B, D,
    output wire [N-1:0] PS, PC
);
    genvar i;
    generate
        for(i=0; i<N; i=i+1) begin : fa_gen
            FullAdder fa(
                .a(A[i]), .b(B[i]), .cin(D[i]),
                .sum(PS[i]), .cout(PC[i])
            );
        end
    endgenerate
endmodule
