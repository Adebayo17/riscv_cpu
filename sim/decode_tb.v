`timescale 1ns / 1ps
module decode_tb;
    reg  [31:0] instr;
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm;

    decode uut (
        .instr(instr),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm)
    );

    initial begin
        // Test R-type instruction: ADD x5, x10, x15 -> 0b0000000 01111 01010 000 00101 0110011
        instr = 32'b000000001111010100000001010110011; #10;
        $display("R-type: opcode=%b, rd=%d, rs1=%d, rs2=%d, funct3=%b, funct7=%b", opcode, rd, rs1, rs2, funct3, funct7);

        // Test I-type instruction: ADDI x5, x10, 20 -> 0b00000000010101010000000100010011
        instr = 32'b00000000010101010000000100010011; #10;
        $display("I-type: opcode=%b, rd=%d, rs1=%d, imm=%d", opcode, rd, rs1, imm);

        $finish;
    end
endmodule
