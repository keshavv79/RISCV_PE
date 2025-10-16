module booth_encoder #(
    parameter N_BITS = 32
) (
    input  signed [N_BITS-1:0] multiplicand,
    input  [3:0] group_index,
    input  [2:0] booth_group,
    output reg signed [63:0] partial_product_out
);

    reg signed [63:0] unshifted_pp;

    always @(*) begin
        case (booth_group)
            3'b000, 3'b111: unshifted_pp = 64'd0;
            3'b001, 3'b010: unshifted_pp = {{32{multiplicand[31]}}, multiplicand};
            3'b011:         unshifted_pp = {{31{multiplicand[31]}}, multiplicand, 1'b0};
            3'b100:         unshifted_pp = -{{31{multiplicand[31]}}, multiplicand, 1'b0};
            3'b101, 3'b110: unshifted_pp = -{{32{multiplicand[31]}}, multiplicand};
            default:        unshifted_pp = 64'd0;
        endcase
        partial_product_out = (unshifted_pp << (2 * group_index));
    end
endmodule
