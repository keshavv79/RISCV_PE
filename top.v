module booth_wallace_multiplier (
    input  wire signed [31:0] A,
    input  wire signed [31:0] B,
    output wire signed [63:0] P
);

    wire signed [16*64-1:0] pp_flat;
    pp_gen pp_stage (
        .A(A),
        .B(B),
        .pp_flat(pp_flat)
    );

    wallace_tree wt_stage (
        .pp_flat(pp_flat),
        .P(P)
    );

endmodule
