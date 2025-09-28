module booth_wallace_multiplier_seq(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire signed [31:0] A,
    input  wire signed [31:0] B,
    output reg  signed [63:0] P,
    output reg valid
);

    // Input registers
    reg signed [31:0] A_reg;
    reg signed [31:0] B_reg;

    wire signed [63:0] P_next;

    // Combinational Booth-Wallace multiplier
    booth_wallace_multiplier dut (
        .A(A_reg), // Use the registered input A
        .B(B_reg), // Use the registered input B
        .P(P_next)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_reg <= 32'd0;
            B_reg <= 32'd0;
            P <= 64'd0;
            valid <= 0;
        end else if (en) begin
            // Pipeline Stage 1: Register inputs
            A_reg <= A;
            B_reg <= B;
            
            // Pipeline Stage 2: Register output of combinational logic
            P <= P_next;
            valid <= 1;
        end else begin
            valid <= 0;
        end
    end

endmodule