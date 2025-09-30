module booth_wallace_multiplier_seq(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire signed [31:0] A,
    input  wire signed [31:0] B,
    output reg  signed [63:0] P,
    output reg valid
);

    // Stage 0: Input registers (already in your code)
    reg signed [31:0] A_reg;
    reg signed [31:0] B_reg;

    // Stage 1: Partial Product Generation (combinational)
    wire signed [16*64-1:0] pp_flat_next;
    pp_gen u_pp (.A(A_reg), .B(B_reg), .pp_flat(pp_flat_next));
    
    // Stage 1.5: Register the partial products (NEW PIPELINE STAGE)
    reg signed [16*64-1:0] pp_flat_reg;
    
    // Stage 2: Wallace tree Reduction (combinational)
    wire signed [63:0] P_next;
    wallace_tree u_wt (.pp_flat(pp_flat_reg), .P(P_next));
    
    // Stage 3: Output register (already in your code)
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 0;
            B_reg <= 0;
            pp_flat_reg <= 0;
            P <= 0;
            valid <= 0;
        end else if (en) begin
            // Register inputs for the next cycle
            A_reg <= A;
            B_reg <= B;

            // Register partial products after one cycle
            pp_flat_reg <= pp_flat_next;
            
            // Register final product after one more cycle
            P <= P_next;
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule
