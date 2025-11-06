`timescale 1ns/1ps

module booth_wallace_multiplier_seq(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire signed [15:0] A,
    input  wire signed [15:0] B,
    output reg  signed [31:0] P,
    output reg valid
);

    //-----------------------------------------
    // Stage 0: Input Registers
    //-----------------------------------------
    reg signed [15:0] A_reg, B_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 0;
            B_reg <= 0;
        end else begin
            A_reg <= A;
            B_reg <= B;
        end
    end

    //-----------------------------------------
    // Stage 1: Partial Product Generation (32-bit each)
    //-----------------------------------------
    wire signed [8*32-1:0] pp_flat_next;
    pp_gen u_pp (.A(A_reg), .B(B_reg), .pp_flat(pp_flat_next));

    reg signed [8*32-1:0] pp_flat_r;
    always @(posedge clk or posedge rst) begin
        if (rst) pp_flat_r <= 0;
        else pp_flat_r <= pp_flat_next;
    end

    wire [31:0] pp [7:0];
    genvar i;
    generate
        for (i=0; i<8; i=i+1) begin : unpack
            assign pp[i] = pp_flat_r[(i+1)*32-1 -: 32];
        end
    endgenerate

    //-----------------------------------------
    // Stage 2: CSA Layer 1 (8 -> 6)  -- 2 CSAs
    //-----------------------------------------
    wire [31:0] s1_sum[1:0], s1_carry[1:0];
    CSA #(32) csa1 (pp[0], pp[1], pp[2], s1_sum[0], s1_carry[0]);
    CSA #(32) csa2 (pp[3], pp[4], pp[5], s1_sum[1], s1_carry[1]);
    wire [31:0] s1_rem1 = pp[6];
    wire [31:0] s1_rem2 = pp[7];

    reg [31:0] s1_sum_r[1:0], s1_carry_r[1:0], s1_rem1_r, s1_rem2_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_sum_r[0] <= 0; s1_sum_r[1] <= 0;
            s1_carry_r[0] <= 0; s1_carry_r[1] <= 0;
            s1_rem1_r <= 0; s1_rem2_r <= 0;
        end else begin
            s1_sum_r[0] <= s1_sum[0]; s1_sum_r[1] <= s1_sum[1];
            s1_carry_r[0] <= s1_carry[0]; s1_carry_r[1] <= s1_carry[1];
            s1_rem1_r <= s1_rem1; s1_rem2_r <= s1_rem2;
        end
    end

    //-----------------------------------------
    // Stage 3: CSA Layer 2 (6 -> 4)  -- 2 CSAs
    //-----------------------------------------
    wire [31:0] s2_sum[1:0], s2_carry[1:0];
    CSA #(32) csa3 (s1_sum_r[0], (s1_carry_r[0] << 1), s1_sum_r[1], s2_sum[0], s2_carry[0]);
    CSA #(32) csa4 ((s1_carry_r[1] << 1), s1_rem1_r, s1_rem2_r, s2_sum[1], s2_carry[1]);

    reg [31:0] s2_sum_r[1:0], s2_carry_r[1:0];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s2_sum_r[0] <= 0; s2_sum_r[1] <= 0;
            s2_carry_r[0] <= 0; s2_carry_r[1] <= 0;
        end else begin
            s2_sum_r[0] <= s2_sum[0]; s2_sum_r[1] <= s2_sum[1];
            s2_carry_r[0] <= s2_carry[0]; s2_carry_r[1] <= s2_carry[1];
        end
    end

    //-----------------------------------------
    // Stage 4: CSA Layer 3 (4 -> 3)  -- 1 CSA
    //-----------------------------------------
    wire [31:0] s3_sum, s3_carry;
    CSA #(32) csa5 (s2_sum_r[0], (s2_carry_r[0] << 1), s2_sum_r[1], s3_sum, s3_carry);
    wire [31:0] s3_rem = (s2_carry_r[1] << 1);

    reg [31:0] s3_sum_r, s3_carry_r, s3_rem_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s3_sum_r <= 0; s3_carry_r <= 0; s3_rem_r <= 0;
        end else begin
            s3_sum_r <= s3_sum; s3_carry_r <= s3_carry; s3_rem_r <= s3_rem;
        end
    end

    //-----------------------------------------
    // Stage 5: CSA Layer 4 (3 -> 2)  -- 1 CSA
    //-----------------------------------------
    wire [31:0] s4_sum, s4_carry;
    CSA #(32) csa6 (s3_sum_r, (s3_carry_r << 1), s3_rem_r, s4_sum, s4_carry);

    reg [31:0] s4_sum_r, s4_carry_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s4_sum_r <= 0; s4_carry_r <= 0;
        end else begin
            s4_sum_r <= s4_sum; s4_carry_r <= s4_carry;
        end
    end

    //-----------------------------------------
    // Stage 6: Final Addition + Output
    //-----------------------------------------
    wire [31:0] P_comb = s4_sum_r + (s4_carry_r << 1);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            P <= 0;
            valid <= 0;
        end else begin
            P <= P_comb;
            valid <= 1;
        end
    end

endmodule

