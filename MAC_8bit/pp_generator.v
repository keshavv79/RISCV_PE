module pp_gen (
    input  wire signed [7:0] A,
    input  wire signed [7:0] B,
    output wire signed [4*16-1:0] pp_flat   // 4 partial products × 16 bits each
);

    wire [9:0] B_pad = {B[7], B, 1'b0};  // 8-bit B padded for Booth
    wire signed [15:0] pp [3:0];           // 4 partial products

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : booth_stage
            booth_encoder #(.N_BITS(8)) u_booth (
                .multiplicand(A),
                .group_index(i[1:0]),
                .booth_group(B_pad[2*i+2 : 2*i]),
                .partial_product_out(pp[i])
            );
        end
    endgenerate

    assign pp_flat = {pp[3], pp[2], pp[1], pp[0]};
endmodule

