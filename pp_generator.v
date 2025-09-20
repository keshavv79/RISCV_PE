module pp_gen (
    input signed [31:0] A,
    input signed [31:0] B,
    output wire signed [64:0] pp [15:0]
);
    wire signed [31:0] multiplicand = A;
    wire signed [32:0] multiplier_padded = {B, 1'b0};
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : encoder_gen
            BoothEncoder #(32) encoder_inst (
                .multiplicand(multiplicand),
                .group_index(i),
                .booth_group(multiplier_padded[2*i+2 : 2*i]),
                .partial_product_out(pp[i])
            );
        end
    endgenerate

endmodule