module control (
    input  wire [6:0] opcode,       // Opcode field of instruction
    output reg        reg_write,    // Enable register write
    output reg        alu_src,      // ALU source select (1 for immediate, 0 for register)
    output reg        mem_write,    // Enable memory write
    output reg        mem_read,     // Enable memory read
    output reg        mem_to_reg,   // Select memory data for register write
    output reg        branch        // Branch control signal
);

    always @(*) begin
        // Default values
        reg_write  = 0;
        alu_src    = 0;
        mem_write  = 0;
        mem_read   = 0;
        mem_to_reg = 0;
        branch     = 0;

        case (opcode)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR)
                reg_write = 1;
            end
            7'b0010011: begin // I-type (ADDI, ANDI, ORI, XORI)
                reg_write = 1;
                alu_src   = 1;
            end
            7'b0000011: begin // Load (LW)
                reg_write  = 1;
                mem_read   = 1;
                alu_src    = 1;
                mem_to_reg = 1;
            end
            7'b0100011: begin // Store (SW)
                mem_write = 1;
                alu_src   = 1;
            end
            7'b1100011: begin // Branch (BEQ)
                branch = 1;
            end
            default: begin
                // Do nothing for undefined opcodes
            end
        endcase
    end

endmodule
