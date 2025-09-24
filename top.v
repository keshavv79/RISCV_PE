module booth_wallace_multiplier(
    input signed [31:0] multiplicand,
    input signed [31:0] multiplier,
    output signed [63:0] product
);

    wire signed [64:0] partial_products [15:0];
    wire signed [64:0] final_sum_vector;
    wire signed [64:0] final_carry_vector;


    pp_gen pp_gen_inst (
        .A(multiplicand),
        .B(multiplier),
        .pp(partial_products)
    );
    wallace_tree wallace_tree_inst (
        .pp(partial_products),
        .final_sum(final_sum_vector),
        .final_carry(final_carry_vector)
    );
        wire signed [64:0] final_carry_shifted;
    assign final_carry_shifted = final_carry_vector << 1;
    wire [64:0] final_product_untruncated;

    assign final_product_untruncated = final_sum_vector + final_carry_shifted;

    assign product = final_product_untruncated[63:0];
endmodule    