module pp_gen (
    input  wire signed [15:0] A,
    input  wire signed [15:0] B,
    output wire signed [8*32-1:0] pp_flat   // 8 partial products × 32 bits each
);

    wire [17:0] B_pad = {B[15], B, 1'b0};  // 16-bit B padded for Booth
    wire signed [31:0] pp [7:0];           // 8 partial products

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : booth_stage
            booth_encoder #(.N_BITS(16)) u_booth (
                .multiplicand(A),
                .group_index(i[2:0]),
                .booth_group(B_pad[2*i+2 : 2*i]),
                .partial_product_out(pp[i])
            );
        end
    endgenerate

    assign pp_flat = {pp[7], pp[6], pp[5], pp[4], pp[3], pp[2], pp[1], pp[0]};
endmodule

