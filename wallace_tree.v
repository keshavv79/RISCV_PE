`timescale 1ns/1ps

module wallace_tree (
    input  wire [16*64-1:0] pp_flat,
    output wire [63:0] P
);

    wire [63:0] pp [15:0];
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : unpack
            assign pp[i] = pp_flat[(i+1)*64-1 -: 64];
        end
    endgenerate

    wire [63:0] s1_sum [4:0], s1_carry [4:0];
    CSA csa1 (pp[0],  pp[1],  pp[2],  s1_sum[0], s1_carry[0]);
    CSA csa2 (pp[3],  pp[4],  pp[5],  s1_sum[1], s1_carry[1]);
    CSA csa3 (pp[6],  pp[7],  pp[8],  s1_sum[2], s1_carry[2]);
    CSA csa4 (pp[9],  pp[10], pp[11], s1_sum[3], s1_carry[3]);
    CSA csa5 (pp[12], pp[13], pp[14], s1_sum[4], s1_carry[4]);
    wire [63:0] s1_rem1 = pp[15];

    wire [63:0] s2_sum [2:0], s2_carry [2:0];
    CSA csa6  (s1_sum[0], (s1_carry[0] << 1), s1_sum[1], s2_sum[0], s2_carry[0]);
    CSA csa7  ((s1_carry[1] << 1), s1_sum[2], (s1_carry[2] << 1), s2_sum[1], s2_carry[1]);
    CSA csa8  (s1_sum[3], (s1_carry[3] << 1), s1_sum[4], s2_sum[2], s2_carry[2]);
    wire [63:0] s2_rem1 = (s1_carry[4] << 1);
    wire [63:0] s2_rem2 = s1_rem1;

    wire [63:0] s3_sum [1:0], s3_carry [1:0];
    CSA csa9  (s2_sum[0], (s2_carry[0] << 1), s2_sum[1], s3_sum[0], s3_carry[0]);
    CSA csa10 ((s2_carry[1] << 1), s2_sum[2], (s2_carry[2] << 1), s3_sum[1], s3_carry[1]);
    wire [63:0] s3_rem1 = s2_rem1;
    wire [63:0] s3_rem2 = s2_rem2;

    wire [63:0] s4_sum [1:0], s4_carry [1:0];
    CSA csa11 (s3_sum[0], (s3_carry[0] << 1), s3_sum[1], s4_sum[0], s4_carry[0]);
    CSA csa12 ((s3_carry[1] << 1), s3_rem1, s3_rem2, s4_sum[1], s4_carry[1]);

    wire [63:0] s5_sum, s5_carry;
    CSA csa13 (s4_sum[0], (s4_carry[0] << 1), s4_sum[1], s5_sum, s5_carry);
    wire [63:0] s5_rem1 = (s4_carry[1] << 1);

    wire [63:0] s6_sum, s6_carry;
    CSA csa14 (s5_sum, (s5_carry << 1), s5_rem1, s6_sum, s6_carry);

    assign P = s6_sum + (s6_carry << 1);

endmodule
