module booth_radix4_multiplier_8bit (
    input signed [31:0] multiplicand, // 8-bit signed A
    input signed [31:0] multiplier,  // 8-bit signed multiplier
    input clk,                      // Clock input
    input rst,                      // Reset input
    input start,                    // Start signal
    output reg signed [63:0] product, // 16-bit signed product
    output reg done                 // Done signal
);
 reg [1:0] state;
// reg [1:0] next_state;
 reg signed [64:0] pp;
 reg signed [64:0]final_sum;
 reg signed [31:0] A;
 reg signed [32:0] B;
 reg [3:0] count;
// reg [2:0] group_bits;
//always @(*) begin  // Assuming a start signal for new multiplication
//        A <= multiplicand;
//        B <= {multiplier, 1'b0};
//end
 reg index;
 parameter IDLE=0,GROUP=1,ALU=2,DONE=3;
 always@(posedge clk or negedge rst) begin
    if(!rst) begin
        A<=0;
        B<=0;
        final_sum<=0;
        state<=IDLE;
        count<=4'd0;
        done<=0;
        product<=0;
        index<=1;
    end
    else begin
        if(state==IDLE) begin
            //count<=count+1;
            done <= 0;
            if (start) begin
                        A <= multiplicand;
                        B <= {multiplier, 1'b0};
                        final_sum <= 0;
                        product<=0;
                        count <= 0;
                        state <= GROUP;
            end
        end
        else if(state==GROUP) begin
              $display({B[index+1],B[index],B[index-1]});
              $display(A);
              $display(B[8:1]);
             case({B[index+1],B[index],B[index-1]}) 
              
               3'b000: pp = 32'sd0;
               3'b001: pp = A;
               3'b010: pp = A;
               3'b011: pp = {A[30:0], 1'b0}; // 2*A
               3'b100: pp = -{A[30:0], 1'b0}; // -2*A
               3'b101: pp = -A;
               3'b110: pp = -A;
               3'b111: pp = 32'sd0;
               default: pp = 32'sd0;
             endcase
             state<=ALU;
        end
        else if(state==ALU) begin
            count=count+1;
          $display(pp);
         // if(pp!=0) begin
            pp=pp<<<2*(count-1);
//            end
          $display(pp);
            B=B>>>2;
            final_sum<=final_sum+pp;
            if(count==15)state<=DONE;
            else state<=GROUP;
        end
        else begin
            product<=final_sum[63:0];
            done<=1'b1;
            state<=IDLE;
        end    
    end
 end
endmodule
