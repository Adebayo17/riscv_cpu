module decode (
    input  wire [31:0] instr,        // Full 32-bit instruction
    output wire [6:0]  opcode,       // Opcode
    output wire [4:0]  rs1, rs2, rd, // Register addresses
    output wire [2:0]  funct3,       // Function field (R/I/S-type)
    output wire [6:0]  funct7,       // Function field (R-type)
    output wire [31:0] imm           // Immediate value (for I, S, B-type)
);

assign opcode = instr[6:0];
assign rd     = instr[11:7];
assign funct3 = instr[14:12];
assign rs1    = instr[19:15];
assign rs2    = instr[24:20];
assign funct7 = instr[31:25];

// Immediate extraction for I-type (sign-extended)
assign imm = {{20{instr[31]}}, instr[31:20]};

endmodule
