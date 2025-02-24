module control (
    input  wire [6:0] opcode,       // Opcode field of instruction
    output reg        reg_write,    // Enable register write
    output reg        alu_src,      // ALU source select (1 for immediate, 0 for register)
    output reg        mem_write,    // Enable memory write
    output reg        mem_read,     // Enable memory read
    output reg        mem_to_reg,   // Select memory data for register write
    output reg        branch,       // Branch control signal
    output reg        jump          // Jump control signal
);

    // === PARAMETERS ===
    localparam R_TYPE_OPCODE = 7'b0110011;  // R-type (ADD, SUB, AND, OR, XOR, MUL, DIV, REM)
    localparam I_TYPE_OPCODE = 7'b0010011;  // I-type (ADDI, ANDI, ORI, XORI)
    localparam LOAD_OPCODE   = 7'b0000011;  // Load (LW)
    localparam STORE_OPCODE  = 7'b0100011;  // Store (SW)
    localparam BRANCH_OPCODE = 7'b1100011;  // Branch (BEQ, BNE, BLT, BGE)
    localparam JAL_OPCODE    = 7'b1101111;  // JAL (Jump and Link)
    localparam JALR_OPCODE   = 7'b1100111;  // JALR (Jump and Link Register)
    
    always @(*) begin
        // Default values
        reg_write  = 0;
        alu_src    = 0;
        mem_write  = 0;
        mem_read   = 0;
        mem_to_reg = 0;
        branch     = 0;
        jump       = 0;

        case (opcode)
            R_TYPE_OPCODE: begin 
                reg_write = 1;
            end

            I_TYPE_OPCODE: begin 
                reg_write = 1;
                alu_src   = 1;
            end

            LOAD_OPCODE: begin 
                reg_write  = 1;
                mem_read   = 1;
                alu_src    = 1;
                mem_to_reg = 1;
            end

            STORE_OPCODE: begin 
                mem_write = 1;
                alu_src   = 1;
            end

            BRANCH_OPCODE: begin 
                branch = 1;
            end

            JAL_OPCODE: begin 
                reg_write = 1;
                jump      = 1;
            end

            JALR_OPCODE: begin 
                reg_write = 1;
                jump      = 1;
                alu_src   = 1; 
            end
            
            default: begin
                // Do nothing for undefined opcodes
            end
        endcase
    end
endmodule
