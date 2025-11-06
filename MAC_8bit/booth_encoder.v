module booth_encoder #(
    parameter N_BITS = 16
) (
    input  signed [N_BITS-1:0] multiplicand,
    input  [3:0] group_index,
    input  [2:0] booth_group,
    output reg signed [(2*N_BITS)-1:0] partial_product_out
);

    reg signed [(2*N_BITS)-1:0] unshifted_pp;

    always @(*) begin
        case (booth_group)
            3'b000, 3'b111: unshifted_pp = 0;
            3'b001, 3'b010: unshifted_pp = {{N_BITS{multiplicand[N_BITS-1]}}, multiplicand};
            3'b011:         unshifted_pp = {{(N_BITS-1){multiplicand[N_BITS-1]}}, multiplicand, 1'b0};
            3'b100:         unshifted_pp = -{{(N_BITS-1){multiplicand[N_BITS-1]}}, multiplicand, 1'b0};
            3'b101, 3'b110: unshifted_pp = -{{N_BITS{multiplicand[N_BITS-1]}}, multiplicand};
            default:        unshifted_pp = 0;
        endcase

        // Shift left by 2×group_index
        partial_product_out = (unshifted_pp << (2 * group_index));
    end

endmodule

