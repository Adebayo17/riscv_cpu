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

    // Immediate extraction for I-type (sign-extended)
    // assign imm = (opcode == I_TYPE_OPCODE) ? {{20{instr[31]}}, instr[31:20]} : 32'b0;
    // assign imm = {{20{instr[31]}}, instr[31:20]};

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



// module decode (
//     input  wire [31:0] instr,        // Full 32-bit instruction
//     output wire [6:0]  opcode,       // Opcode
//     output wire [4:0]  rs1, rs2, rd, // Register addresses (Source 1, Source 2, Destination)
//     output wire [2:0]  funct3,       // Function field (R/I/S-type)
//     output wire [6:0]  funct7,       // Function field (R-type)
//     output wire [31:0] imm,          // Immediate value (for I, S, B-type)
//     output wire        is_mul,       // Detect multiplication
//     output wire        is_div,       // Detect division
//     output wire        is_rem,       // Detect remainder
//     output wire        is_divu,      // Detect division unsigned 
//     output wire        is_remu       // Detect remainder unsigned
// );

//     assign opcode = instr[6:0];
//     assign rd     = instr[11:7];
//     assign funct3 = instr[14:12];
//     assign rs1    = instr[19:15];
//     assign rs2    = instr[24:20];
//     assign funct7 = instr[31:25];

//     // Immediate extraction for I-type (sign-extended)
//     assign imm = {{20{instr[31]}}, instr[31:20]};

//     // Detect multiplication, division, and remainder
//     assign is_mul  = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000001);
//     assign is_div  = (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000001);
//     assign is_rem  = (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000001);
//     assign is_divu = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000001);
//     assign is_remu = (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000001);
// endmodule
