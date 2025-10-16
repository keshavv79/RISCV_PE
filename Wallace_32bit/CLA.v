`timescale 1ns/1ps

// ====================================================
// 64-bit Carry Lookahead Adder
// ====================================================
module carry_lookahead_adder #(
    parameter WIDTH = 64   // must be multiple of 4
)(
    input  [WIDTH-1:0] A,
    input  [WIDTH-1:0] B,
    output [WIDTH:0]   Sum  // 64-bit result + carry-out
);
    localparam N_BLOCKS = WIDTH / 4;

    wire [N_BLOCKS:0] C;               // block carries
    wire [N_BLOCKS-1:0] G_block, P_block;
    wire [WIDTH-1:0] Sum_internal;

    assign C[0] = 1'b0;  // No external carry-in

    genvar i;
    generate
        for (i=0; i<N_BLOCKS; i=i+1) begin : cla_blocks
            cla_4bit u_cla4 (
                .A(A[i*4 +: 4]),
                .B(B[i*4 +: 4]),
                .Cin(C[i]),
                .Sum(Sum_internal[i*4 +: 4]),
                .Cout(),           // not used directly
                .PG(G_block[i]),   // block propagate
                .GG(P_block[i])    // block generate
            );

            // Carry lookahead between 4-bit blocks
            assign C[i+1] = G_block[i] | (P_block[i] & C[i]);
        end
    endgenerate

    assign Sum = {C[N_BLOCKS], Sum_internal};  // MSB is carry-out

endmodule

// ====================================================
// 4-bit CLA block
// ====================================================
module cla_4bit (
    input  [3:0] A, B,
    input        Cin,
    output [3:0] Sum,
    output       Cout,
    output       PG,  // block propagate
    output       GG   // block generate
);
    wire [3:0] P, G;   // bit propagate & generate
    wire [3:1] C;      // internal carries

    assign P = A ^ B;
    assign G = A & B;

    // Carry lookahead equations
    assign C[1] = G[0] | (P[0] & Cin);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);

    // Sum bits
    assign Sum[0] = P[0] ^ Cin;
    assign Sum[1] = P[1] ^ C[1];
    assign Sum[2] = P[2] ^ C[2];
    assign Sum[3] = P[3] ^ C[3];

    // Carry-out
    assign Cout = G[3] | (P[3] & C[3]);

    // Block propagate and generate
    assign PG = &P;                         // all bits propagate
    assign GG = G[3] | (P[3] & G[2])       // generate for 4-bit block
                   | (P[3] & P[2] & G[1])
                   | (P[3] & P[2] & P[1] & G[0]);
endmodule

