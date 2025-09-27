module pp_gen (
    input  wire signed [31:0] A,
    input  wire signed [31:0] B,
    output wire signed [16*64-1:0] pp_flat
);

    wire [33:0] B_pad = {B[31], B, 1'b0}; 
    wire signed [63:0] pp [15:0];

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : booth_stage
            booth_encoder u_booth (
                .multiplicand(A),
                .group_index(i),
                .booth_group(B_pad[2*i+2 : 2*i]), 
                .partial_product_out(pp[i])
            );
        end
    endgenerate
   
    assign pp_flat = {pp[15], pp[14], pp[13], pp[12], pp[11], pp[10], pp[9], pp[8],
                      pp[7], pp[6], pp[5], pp[4], pp[3], pp[2], pp[1], pp[0]};
endmodule
