`timescale 1ns/1ps

module booth_wallace_multiplier_seq(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire signed [31:0] A,
    input  wire signed [31:0] B,
    output reg  signed [63:0] P,
    output reg valid
);

    //-----------------------------------------
    // Stage 0: Input registers
    //-----------------------------------------
    reg signed [31:0] A_reg, B_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 0;
            B_reg <= 0;
        end else if (en) begin
            A_reg <= A;
            B_reg <= B;
        end
    end

    //-----------------------------------------
    // Stage 1: Partial Product Generation
    //-----------------------------------------
    wire signed [16*64-1:0] pp_flat_next;
    pp_gen u_pp (.A(A_reg), .B(B_reg), .pp_flat(pp_flat_next));

    // Register partial products
    reg signed [16*64-1:0] pp_flat_r;
    always @(posedge clk or posedge rst) begin
        if (rst) pp_flat_r <= 0;
        else if (en) pp_flat_r <= pp_flat_next;
    end

    //-----------------------------------------
    // Unpack partial products
    //-----------------------------------------
    wire [63:0] pp [15:0];
    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin : unpack
            assign pp[i] = pp_flat_r[(i+1)*64-1 -: 64];
        end
    endgenerate

    //-----------------------------------------
    // Stage 2: CSA Layer 1
    //-----------------------------------------
    wire [63:0] s1_sum[4:0], s1_carry[4:0];
    CSA csa1 (pp[0],  pp[1],  pp[2],  s1_sum[0], s1_carry[0]);
    CSA csa2 (pp[3],  pp[4],  pp[5],  s1_sum[1], s1_carry[1]);
    CSA csa3 (pp[6],  pp[7],  pp[8],  s1_sum[2], s1_carry[2]);
    CSA csa4 (pp[9],  pp[10], pp[11], s1_sum[3], s1_carry[3]);
    CSA csa5 (pp[12], pp[13], pp[14], s1_sum[4], s1_carry[4]);
    wire [63:0] s1_rem1 = pp[15];

    // Register Stage 2
    reg [63:0] s1_sum_r[4:0], s1_carry_r[4:0], s1_rem1_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            integer j;
            for (j=0; j<5; j=j+1) begin
                s1_sum_r[j]   <= 0;
                s1_carry_r[j] <= 0;
            end
            s1_rem1_r <= 0;
        end else if (en) begin
            integer j;
            for (j=0; j<5; j=j+1) begin
                s1_sum_r[j]   <= s1_sum[j];
                s1_carry_r[j] <= s1_carry[j];
            end
            s1_rem1_r <= s1_rem1;
        end
    end

    //-----------------------------------------
    // Stage 3: CSA Layer 2
    //-----------------------------------------
    wire [63:0] s2_sum[2:0], s2_carry[2:0];
    CSA csa6  (s1_sum_r[0], (s1_carry_r[0]<<1), s1_sum_r[1], s2_sum[0], s2_carry[0]);
    CSA csa7  ((s1_carry_r[1]<<1), s1_sum_r[2], (s1_carry_r[2]<<1), s2_sum[1], s2_carry[1]);
    CSA csa8  (s1_sum_r[3], (s1_carry_r[3]<<1), s1_sum_r[4], s2_sum[2], s2_carry[2]);
    wire [63:0] s2_rem1 = (s1_carry_r[4]<<1);
    wire [63:0] s2_rem2 = s1_rem1_r;

    // Register Stage 3
    reg [63:0] s2_sum_r[2:0], s2_carry_r[2:0], s2_rem1_r, s2_rem2_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            integer j;
            for (j=0; j<3; j=j+1) begin
                s2_sum_r[j]   <= 0;
                s2_carry_r[j] <= 0;
            end
            s2_rem1_r <= 0;
            s2_rem2_r <= 0;
        end else if (en) begin
            integer j;
            for (j=0; j<3; j=j+1) begin
                s2_sum_r[j]   <= s2_sum[j];
                s2_carry_r[j] <= s2_carry[j];
            end
            s2_rem1_r <= s2_rem1;
            s2_rem2_r <= s2_rem2;
        end
    end

    //-----------------------------------------
    // Stage 4: CSA Layer 3
    //-----------------------------------------
    wire [63:0] s3_sum[1:0], s3_carry[1:0];
    CSA csa9  (s2_sum_r[0], (s2_carry_r[0]<<1), s2_sum_r[1], s3_sum[0], s3_carry[0]);
    CSA csa10 ((s2_carry_r[1]<<1), s2_sum_r[2], (s2_carry_r[2]<<1), s3_sum[1], s3_carry[1]);
    wire [63:0] s3_rem1 = s2_rem1_r;
    wire [63:0] s3_rem2 = s2_rem2_r;

    // Register Stage 4
    reg [63:0] s3_sum_r[1:0], s3_carry_r[1:0], s3_rem1_r, s3_rem2_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s3_sum_r[0] <= 0; s3_sum_r[1] <= 0;
            s3_carry_r[0] <= 0; s3_carry_r[1] <= 0;
            s3_rem1_r <= 0; s3_rem2_r <= 0;
        end else if (en) begin
            s3_sum_r[0] <= s3_sum[0]; s3_sum_r[1] <= s3_sum[1];
            s3_carry_r[0] <= s3_carry[0]; s3_carry_r[1] <= s3_carry[1];
            s3_rem1_r <= s3_rem1; s3_rem2_r <= s3_rem2;
        end
    end

    //-----------------------------------------
    // Stage 5: CSA Layer 4
    //-----------------------------------------
    wire [63:0] s4_sum[1:0], s4_carry[1:0];
    CSA csa11 (s3_sum_r[0], (s3_carry_r[0]<<1), s3_sum_r[1], s4_sum[0], s4_carry[0]);
    CSA csa12 ((s3_carry_r[1]<<1), s3_rem1_r, s3_rem2_r, s4_sum[1], s4_carry[1]);

    // Register Stage 5
    reg [63:0] s4_sum_r[1:0], s4_carry_r[1:0];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s4_sum_r[0] <= 0; s4_sum_r[1] <= 0;
            s4_carry_r[0] <= 0; s4_carry_r[1] <= 0;
        end else if (en) begin
            s4_sum_r[0] <= s4_sum[0]; s4_sum_r[1] <= s4_sum[1];
            s4_carry_r[0] <= s4_carry[0]; s4_carry_r[1] <= s4_carry[1];
        end
    end

    //-----------------------------------------
    // Stage 6: CSA Layer 5
    //-----------------------------------------
    wire [63:0] s5_sum, s5_carry;
    CSA csa13 (s4_sum_r[0], (s4_carry_r[0]<<1), s4_sum_r[1], s5_sum, s5_carry);
    wire [63:0] s5_rem1 = (s4_carry_r[1]<<1);

    // Register Stage 6
    reg [63:0] s5_sum_r, s5_carry_r, s5_rem1_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s5_sum_r <= 0; s5_carry_r <= 0; s5_rem1_r <= 0;
        end else if (en) begin
            s5_sum_r <= s5_sum; s5_carry_r <= s5_carry; s5_rem1_r <= s5_rem1;
        end
    end

    //-----------------------------------------
    // Stage 7: CSA Layer 6
    //-----------------------------------------
    wire [63:0] s6_sum, s6_carry;
    CSA csa14 (s5_sum_r, (s5_carry_r<<1), s5_rem1_r, s6_sum, s6_carry);

    // Register final stage
    reg [63:0] s6_sum_r, s6_carry_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s6_sum_r <= 0; s6_carry_r <= 0;
        end else if (en) begin
            s6_sum_r <= s6_sum; s6_carry_r <= s6_carry;
        end
    end

    //-----------------------------------------
    // Stage 8: Final Adder + Output
    //-----------------------------------------
    wire [63:0] P_comb = s6_sum_r + (s6_carry_r << 1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            P <= 0;
            valid <= 0;
        end else if (en) begin
            P <= P_comb;
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule
