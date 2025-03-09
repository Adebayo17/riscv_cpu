module alu (
    input  wire [31:0] a,                   // Operand A
    input  wire [31:0] b,                   // Operand B
    input  wire [3:0]  alu_ctrl,            // ALU Control Signal
    output reg  [31:0] result,              // ALU Output
    output wire        zero,                // Zero flag (1 if result==0)
    output reg         alu_ready
);

    always @(*) begin
        alu_ready = 0;
        case (alu_ctrl)
            4'b0000:    result = a + b;                                         // ADD 
            4'b0001:    result = $signed(a) - $signed(b);                       // SUB 
            4'b0010:    result = a & b;                                         // AND 
            4'b0011:    result = a | b;                                         // OR 
            4'b0100:    result = a ^ b;                                         // XOR 
            4'b0101:    result = a << b;                                        // SLL (Shift Left Logical)
            4'b0110:    result = a >> b;                                        // SRL (Shift Right Logical)
            4'b0111:    result = $signed(a) >>> b;                              // SRA (Shift Right Arithmetic)
            default:    result = 32'b0;                                         // Default case 
        endcase
        alu_ready = 1;
    end

    assign zero = (result == 32'b0) ? 1 : 0;                                    // Set zero flag
endmodule
