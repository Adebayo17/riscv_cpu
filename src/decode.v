module decode (
    input  wire [31:0] instr,        // Full 32-bit instruction
    output wire [6:0]  opcode,       // Opcode
    output wire [4:0]  rs1, rs2, rd, // Register addresses (Source 1, Source 2, Destination)
    output wire [2:0]  funct3,       // Function field (R/I/S-type)
    output wire [6:0]  funct7,       // Function field (R-type)
    output reg  [31:0] imm           // Immediate value (for I, S, B-type)
);

    
    localparam R_TYPE_OPCODE = 7'b0110011; 
    localparam I_TYPE_OPCODE = 7'b0010011; 
    localparam LOAD_OPCODE   = 7'b0000011; 
    localparam STORE_OPCODE  = 7'b0100011; 
    localparam BRANCH_OPCODE = 7'b1100011; 
    localparam JAL_OPCODE    = 7'b1101111; 
    localparam JALR_OPCODE   = 7'b1100111; 

    assign opcode = instr[6:0];
    
    assign rd     = (opcode == R_TYPE_OPCODE || opcode == I_TYPE_OPCODE || opcode == JAL_OPCODE) ? instr[11:7] : 5'b00000;
    
    assign funct3 = (opcode == JAL_OPCODE) ? 3'b000 : instr[14:12];
    
    assign rs1    =     (opcode == R_TYPE_OPCODE || opcode == I_TYPE_OPCODE || opcode == LOAD_OPCODE || opcode == STORE_OPCODE || opcode == BRANCH_OPCODE 
                        || opcode == JAL_OPCODE || opcode == JALR_OPCODE) ? instr[19:15] : 5'b00000;
    
    assign rs2    = (opcode == R_TYPE_OPCODE || opcode == STORE_OPCODE || opcode == BRANCH_OPCODE) ? instr[24:20] : 5'b00000;
    
    assign funct7 = (opcode == R_TYPE_OPCODE) ? instr[31:25] : 7'b0000000;


    always @(*) begin
        case (opcode)
            I_TYPE_OPCODE, LOAD_OPCODE, JALR_OPCODE: 
                imm = {{20{instr[31]}}, instr[31:20]};
            
            STORE_OPCODE:   
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            
            BRANCH_OPCODE:
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            
            JAL_OPCODE:
                imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            
            R_TYPE_OPCODE: 
                imm = 32'b0;

            default: 
                imm = 32'b0;
        endcase
    end
endmodule
