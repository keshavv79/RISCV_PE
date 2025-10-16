`timescale 1ns/1ps

module wallace_tree (
    input  wire [16*64-1:0] pp_flat,
    output wire [63:0] P
);

    // Unpack pp_flat into individual 64-bit wires
    wire [63:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;
    wire [63:0] pp8, pp9, pp10, pp11, pp12, pp13, pp14, pp15;

    assign pp0  = pp_flat[64*1-1 : 64*0];
    assign pp1  = pp_flat[64*2-1 : 64*1];
    assign pp2  = pp_flat[64*3-1 : 64*2];
    assign pp3  = pp_flat[64*4-1 : 64*3];
    assign pp4  = pp_flat[64*5-1 : 64*4];
    assign pp5  = pp_flat[64*6-1 : 64*5];
    assign pp6  = pp_flat[64*7-1 : 64*6];
    assign pp7  = pp_flat[64*8-1 : 64*7];
    assign pp8  = pp_flat[64*9-1 : 64*8];
    assign pp9  = pp_flat[64*10-1 : 64*9];
    assign pp10 = pp_flat[64*11-1 : 64*10];
    assign pp11 = pp_flat[64*12-1 : 64*11];
    assign pp12 = pp_flat[64*13-1 : 64*12];
    assign pp13 = pp_flat[64*14-1 : 64*13];
    assign pp14 = pp_flat[64*15-1 : 64*14];
    assign pp15 = pp_flat[64*16-1 : 64*15];

    // Stage 1
    wire [63:0] s1_sum0, s1_carry0;
    wire [63:0] s1_sum1, s1_carry1;
    wire [63:0] s1_sum2, s1_carry2;
    wire [63:0] s1_sum3, s1_carry3;
    wire [63:0] s1_sum4, s1_carry4;
    wire [63:0] s1_rem1 = pp15;

    CSA csa1 (pp0,  pp1,  pp2,  s1_sum0, s1_carry0);
    CSA csa2 (pp3,  pp4,  pp5,  s1_sum1, s1_carry1);
    CSA csa3 (pp6,  pp7,  pp8,  s1_sum2, s1_carry2);
    CSA csa4 (pp9,  pp10, pp11, s1_sum3, s1_carry3);
    CSA csa5 (pp12, pp13, pp14, s1_sum4, s1_carry4);

    // Stage 2
    wire [63:0] s2_sum0, s2_carry0;
    wire [63:0] s2_sum1, s2_carry1;
    wire [63:0] s2_sum2, s2_carry2;
    wire [63:0] s2_rem1 = (s1_carry4 << 1);
    wire [63:0] s2_rem2 = s1_rem1;

    CSA csa6 (s1_sum0, (s1_carry0 << 1), s1_sum1, s2_sum0, s2_carry0);
    CSA csa7 ((s1_carry1 << 1), s1_sum2, (s1_carry2 << 1), s2_sum1, s2_carry1);
    CSA csa8 (s1_sum3, (s1_carry3 << 1), s1_sum4, s2_sum2, s2_carry2);

    // Stage 3
    wire [63:0] s3_sum0, s3_carry0;
    wire [63:0] s3_sum1, s3_carry1;
    wire [63:0] s3_rem1 = s2_rem1;
    wire [63:0] s3_rem2 = s2_rem2;

    CSA csa9  (s2_sum0, (s2_carry0 << 1), s2_sum1, s3_sum0, s3_carry0);
    CSA csa10 ((s2_carry1 << 1), s2_sum2, (s2_carry2 << 1), s3_sum1, s3_carry1);

    // Stage 4
    wire [63:0] s4_sum0, s4_carry0;
    wire [63:0] s4_sum1, s4_carry1;

    CSA csa11 (s3_sum0, (s3_carry0 << 1), s3_sum1, s4_sum0, s4_carry0);
    CSA csa12 ((s3_carry1 << 1), s3_rem1, s3_rem2, s4_sum1, s4_carry1);

    // Stage 5
    wire [63:0] s5_sum, s5_carry;
    wire [63:0] s5_rem1 = (s4_carry1 << 1);

    CSA csa13 (s4_sum0, (s4_carry0 << 1), s4_sum1, s5_sum, s5_carry);

    // Stage 6
    wire [63:0] s6_sum, s6_carry;

    CSA csa14 (s5_sum, (s5_carry << 1), s5_rem1, s6_sum, s6_carry);

    // Final product
    assign P = s6_sum + (s6_carry << 1);

endmodule

