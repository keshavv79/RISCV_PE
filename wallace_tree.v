module wallace_tree(
    input signed [64:0] pp [15:0], // 16 partial products from pp_gen
    output signed [64:0] final_sum,
    output signed [64:0] final_carry
);

    // Wires for each level of the tree
    wire signed [64:0] L1_S [4:0];
    wire signed [64:0] L1_C [4:0];
    wire signed [64:0] L2_S [2:0];
    wire signed [64:0] L2_C [2:0];
    wire signed [64:0] L3_S [1:0];
    wire signed [64:0] L3_C [1:0];
    wire signed [64:0] L4_S [1:0];
    wire signed [64:0] L4_C [1:0];
    wire signed [64:0] L5_S [0:0];
    wire signed [64:0] L5_C [0:0];

    // ----- Level 1: Reduce 16 partial products to 11 -----
    CSA csa1_0(.A(pp[0]), .B(pp[1]), .D(pp[2]), .PS(L1_S[0]), .PC(L1_C[0]));
    CSA csa1_1(.A(pp[3]), .B(pp[4]), .D(pp[5]), .PS(L1_S[1]), .PC(L1_C[1]));
    CSA csa1_2(.A(pp[6]), .B(pp[7]), .D(pp[8]), .PS(L1_S[2]), .PC(L1_C[2]));
    CSA csa1_3(.A(pp[9]), .B(pp[10]), .D(pp[11]), .PS(L1_S[3]), .PC(L1_C[3]));
    CSA csa1_4(.A(pp[12]), .B(pp[13]), .D(pp[14]), .PS(L1_S[4]), .PC(L1_C[4]));
    // pp[15] is passed through
    
    // ----- Level 2: Reduce 11 rows to 8 -----
    CSA csa2_0(.A(L1_S[0]), .B(L1_C[0]), .D(L1_S[1]), .PS(L2_S[0]), .PC(L2_C[0]));
    CSA csa2_1(.A(L1_C[1]), .B(L1_S[2]), .D(L1_C[2]), .PS(L2_S[1]), .PC(L2_C[1]));
    CSA csa2_2(.A(L1_S[3]), .B(L1_C[3]), .D(L1_S[4]), .PS(L2_S[2]), .PC(L2_C[2]));
    // L1_C[4] and pp[15] are passed through
    
    // ----- Level 3: Reduce 8 rows to 6 -----
    CSA csa3_0(.A(L2_S[0]), .B(L2_C[0]), .D(L2_S[1]), .PS(L3_S[0]), .PC(L3_C[0]));
    CSA csa3_1(.A(L2_C[1]), .B(L2_S[2]), .D(L2_C[2]), .PS(L3_S[1]), .PC(L3_C[1]));
    // L1_C[4] and pp[15] are passed through
    
    // ----- Level 4: Reduce 6 rows to 4 -----
    CSA csa4_0(.A(L3_S[0]), .B(L3_C[0]), .D(L3_S[1]), .PS(L4_S[0]), .PC(L4_C[0]));
    CSA csa4_1(.A(L3_C[1]), .B(L1_C[4]), .D(pp[15]), .PS(L4_S[1]), .PC(L4_C[1]));
    
    // ----- Level 5: Reduce 4 rows to 3 -----
    CSA csa5_0(.A(L4_S[0]), .B(L4_C[0]), .D(L4_S[1]), .PS(L5_S[0]), .PC(L5_C[0]));
    // L4_C[1] is passed through
    
    // ----- Level 6: Reduce 3 rows to 2 -----
    CSA csa6_0(.A(L5_S[0]), .B(L5_C[0]), .D(L4_C[1]), .PS(final_sum), .PC(final_carry));

endmodule