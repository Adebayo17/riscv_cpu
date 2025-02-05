module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire  zero               // Zero flag (1 if result==0)
);
    always @(*) begin
        case (alu_ctrl)
            4'b0000:    result = a + b; // ADD 
            4'b0001:    result = a - b; // SUB 
            4'b0010:    result = a & b; // AND 
            4'b0011:    result = a | b; // OR 
            4'b0100:    result = a ^ b; // XOR 
            default:    result = 32'b0; // Default case 
        endcase
    end

    assign zero = (result == 32'b0) ? 1 : 0;    // Set zero flag
endmodule