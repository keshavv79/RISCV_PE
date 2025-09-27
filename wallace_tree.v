module wallace_tree (
    input  wire [16*64-1:0] pp_flat,  // 16 partial products, 64-bit each
    output wire [63:0]      final_sum,
    output wire [63:0]      final_carry
);

    // Unpack partial products
    wire [63:0] pp [15:0];
    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin : unpack
            assign pp[i] = pp_flat[(i+1)*64-1 -: 64];
        end
    endgenerate

    // ------------------------
    // Stage 1: reduce 16 → 11
    // ------------------------
    wire [63:0] s1_sum [4:0], s1_carry [4:0];
    CSA csa1 (pp[0], pp[1], pp[2], s1_sum[0], s1_carry[0]);
    CSA csa2 (pp[3], pp[4], pp[5], s1_sum[1], s1_carry[1]);
    CSA csa3 (pp[6], pp[7], pp[8], s1_sum[2], s1_carry[2]);
    CSA csa4 (pp[9], pp[10], pp[11], s1_sum[3], s1_carry[3]);
    CSA csa5 (pp[12], pp[13], pp[14], s1_sum[4], s1_carry[4]);
    wire [63:0] rem1 = pp[15];

    // Total outputs = 5 sums + 5 carries + rem1 = 11 rows

    // ------------------------
    // Stage 2: reduce 11 → 7
    // ------------------------
    wire [63:0] s2_sum [2:0], s2_carry [2:0];
    CSA csa6 (s1_sum[0], s1_carry[0], s1_sum[1], s2_sum[0], s2_carry[0]);
    CSA csa7 (s1_carry[1], s1_sum[2], s1_carry[2], s2_sum[1], s2_carry[1]);
    CSA csa8 (s1_sum[3], s1_carry[3], s1_sum[4], s2_sum[2], s2_carry[2]);
    // leftovers: s1_carry[4], rem1
    // total 7 rows

    // ------------------------
    // Stage 3: reduce 7 → 5
    // ------------------------
    wire [63:0] s3_sum [1:0], s3_carry [1:0];
    CSA csa9  (s2_sum[0], s2_carry[0], s2_sum[1], s3_sum[0], s3_carry[0]);
    CSA csa10 (s2_carry[1], s2_sum[2], s2_carry[2], s3_sum[1], s3_carry[1]);
    // leftovers: s1_carry[4], rem1
    // total 5 rows

    // ------------------------
    // Stage 4: reduce 5 → 3
    // ------------------------
    wire [63:0] s4_sum, s4_carry;
    CSA csa11 (s3_sum[0], s3_carry[0], s3_sum[1], s4_sum, s4_carry);
    // leftovers: s3_carry[1], s1_carry[4], rem1
    // total 3 rows

    // ------------------------
    // Stage 5: reduce 3 → 2
    // ------------------------
    wire [63:0] s5_sum, s5_carry;
    CSA csa12 (s4_sum, s4_carry, s3_carry[1], s5_sum, s5_carry);
    // leftovers: s1_carry[4], rem1
    // total 2 rows

    // ------------------------
    // Final two rows
    // ------------------------
    assign final_sum   = s5_sum   ^ s5_carry ^ s1_carry[4] ^ rem1;
    assign final_carry = (s5_sum & s5_carry) | (s5_sum & s1_carry[4]) |
                         (s5_carry & s1_carry[4]) | rem1; // OR optimized adder stage

endmodule
