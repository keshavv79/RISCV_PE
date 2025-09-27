module booth_encoder #(
    parameter N_BITS = 32
) (
    input  signed [N_BITS-1:0] multiplicand,
    input  [4:0] group_index,
    input  [2:0] booth_group,
    output reg signed [63:0] partial_product_out   // 64 bits for 32x32
);

    reg signed [33:0] unshifted_pp; // one extra bit for sign

    always @(*) begin
        case (booth_group)
            3'b000, 3'b111: unshifted_pp = 0;
            3'b001, 3'b010: unshifted_pp = $signed(multiplicand);         // +A
            3'b011:         unshifted_pp = $signed(multiplicand) <<< 1;   // +2A
            3'b100:         unshifted_pp = -($signed(multiplicand) <<< 1);// -2A
            3'b101, 3'b110: unshifted_pp = -$signed(multiplicand);        // -A
            default:        unshifted_pp = 0;
        endcase

        // Shift left to position the partial product
        partial_product_out = $signed(unshifted_pp) <<< (2 * group_index);
    end
endmodule
