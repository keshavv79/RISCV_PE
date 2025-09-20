module BoothEncoder #(
    parameter N_BITS = 32
) (
    input signed [N_BITS-1:0] multiplicand,
    input [4:0] group_index,
    input [2:0] booth_group,
    output reg signed [2*N_BITS:0] partial_product_out
);
    reg signed [N_BITS:0] unshifted_pp;
    always @(*) begin
        case(booth_group)
            3'b000: unshifted_pp = 0;
            3'b001: unshifted_pp = {{1{multiplicand[N_BITS-1]}}, multiplicand};
            3'b010: unshifted_pp = {{1{multiplicand[N_BITS-1]}}, multiplicand};
            3'b011: unshifted_pp = {multiplicand, 1'b0};
            3'b100: unshifted_pp = -{multiplicand, 1'b0};
            3'b101: unshifted_pp = -{{1{multiplicand[N_BITS-1]}}, multiplicand};
            3'b110: unshifted_pp = -{{1{multiplicand[N_BITS-1]}}, multiplicand};
            3'b111: unshifted_pp = 0;
            default: unshifted_pp = 0;
        endcase
        partial_product_out = unshifted_pp << (2 * group_index);
    end

endmodule