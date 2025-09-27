module booth_wallace_multiplier (
    input  wire signed [31:0] A,
    input  wire signed [31:0] B,
    output wire signed [63:0] P
);

    // --------------------
    // Step 1: Partial Products
    // --------------------
    wire signed [16*64-1:0] pp_flat;
    pp_gen pp_stage (
        .A(A),
        .B(B),
        .pp_flat(pp_flat)
    );

    // --------------------
    // Step 2: Wallace Tree Reduction
    // --------------------
    wire [63:0] final_sum, final_carry;
    wallace_tree wt_stage (
        .pp_flat(pp_flat),
        .final_sum(final_sum),
        .final_carry(final_carry)
    );

    // --------------------
    // Step 3: Final CPA
    // --------------------
    // Carry must be shifted left by 1!
assign P = final_sum + (final_carry << 1) + (s1_carry[4] << 1) + rem1;


endmodule
