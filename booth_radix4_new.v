module booth_radix4_multiplier_32bit (
    input  signed [31:0] multiplicand,
    input  signed [31:0] multiplier,
    input  clk,
    input  rst,
    input  start,
    output reg signed [63:0] product,
    output reg done
);

    reg [1:0] state;
    reg signed [63:0] pp;
    reg signed [63:0] final_sum;
    reg signed [31:0] A;
    reg signed [32:0] B;   // multiplier with extra LSB
    reg [4:0] count;       // 16 iterations for 32-bit radix-4
    reg [4:0] index;

    parameter IDLE  = 2'd0,
              GROUP = 2'd1,
              ALU   = 2'd2,
              DONE  = 2'd3;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            A         <= 0;
            B         <= 0;
            final_sum <= 0;
            state     <= IDLE;
            count     <= 0;
            done      <= 0;
            product   <= 0;
            index     <= 1;
        end else begin
            case(state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        A         <= multiplicand;
                        B         <= {multiplier, 1'b0};
                        final_sum <= 0;
                        product   <= 0;
                        count     <= 0;
                        index     <= 1;
                        state     <= GROUP;
                    end
                end

                GROUP: begin
                    case({B[index+1], B[index], B[index-1]})
                        3'b000, 3'b111: pp <= 64'sd0;
                        3'b001, 3'b010: pp <= {{32{A[31]}}, A};       // +A
                        3'b011:         pp <= {{31{A[31]}}, A, 1'b0}; // +2*A
                        3'b100:         pp <= -{{31{A[31]}}, A, 1'b0}; // -2*A
                        3'b101, 3'b110: pp <= -{{32{A[31]}}, A};      // -A
                        default:        pp <= 64'sd0;
                    endcase
                    state <= ALU;
                end

                ALU: begin
                    pp <= pp <<< (2*count);  // shift according to group
                    final_sum <= final_sum + pp;
                    B <= B >>> 2;            // arithmetic shift
                    count <= count + 1;
                    if (count == 15)         // 16 groups for 32-bit input
                        state <= DONE;
                    else
                        state <= GROUP;
                end

                DONE: begin
                    product <= final_sum;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
