`timescale 1ns/1ps

module booth_wallace_multiplier_seq(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire signed [7:0] A,
    input  wire signed [7:0] B,
    output reg  signed [15:0] P,
    output reg valid
);

    //-----------------------------------------
    // Stage 0: Input Registers
    //-----------------------------------------
    reg signed [7:0] A_reg, B_reg;
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
    // Stage 1: Partial Product Generation (16-bit each)
    //-----------------------------------------
    wire signed [4*16-1:0] pp_flat_next;
    pp_gen u_pp (.A(A_reg), .B(B_reg), .pp_flat(pp_flat_next));

    reg signed [4*16-1:0] pp_flat_r;
    always @(posedge clk or posedge rst) begin
        if (rst) pp_flat_r <= 0;
        else pp_flat_r <= pp_flat_next;
    end

    wire [15:0] pp [3:0];
    genvar i;
    generate
        for (i=0; i<4; i=i+1) begin : unpack
            assign pp[i] = pp_flat_r[(i+1)*16-1 -: 16];
        end
    endgenerate     
    //-----------------------------------------
    // Stage 2: CSA Layer 1 (4 -> 3)  -- 1 CSA
    //-----------------------------------------
    wire [15:0] s1_sum, s1_carry;
    CSA #(16) csa1 (pp[0], pp[1], pp[2], s1_sum, s1_carry);
    wire [15:0] s1_rem = pp[3];

    reg [15:0] s1_sum_r, s1_carry_r, s1_rem_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s1_sum_r <= 0; s1_carry_r <= 0; s1_rem_r <= 0;
        end else begin
            s1_sum_r <= s1_sum; s1_carry_r <= s1_carry; s1_rem_r <= s1_rem;
        end
    end

    //-----------------------------------------
    // Stage 3: CSA Layer 2 (3 -> 2)  -- 1 CSA
    //-----------------------------------------
    wire [15:0] s2_sum, s2_carry;
    CSA #(16) csa2 (s1_sum_r, (s1_carry_r << 1), s1_rem_r, s2_sum, s2_carry);

    reg [15:0] s2_sum_r, s2_carry_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s2_sum_r <= 0; s2_carry_r <= 0;
        end else begin
            s2_sum_r <= s2_sum; s2_carry_r <= s2_carry;
        end
    end

    //-----------------------------------------
    // Stage 4: Final Addition + Output
    //-----------------------------------------
    wire [15:0] P_comb = s2_sum_r + (s2_carry_r << 1);

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

