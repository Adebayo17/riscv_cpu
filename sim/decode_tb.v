`timescale 1ns / 1ps

module decode_tb;

    // Inputs
    reg  [31:0] instr;

    // Outputs
    wire [6:0]  opcode;
    wire [4:0]  rs1, rs2, rd;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;

    // Instantiate the decode module
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

    // Testbench logic
    initial begin
        // Open a file to log results
        $dumpfile("wave/decode_tb.vcd");
        $dumpvars(0, decode_tb);

        $display("\n===========================");
        $display("🚀 Starting Decode Tests...");
        $display("===========================\n");

        // Test 1: R-type instruction (ADD)
        instr = 32'b0000000_00010_00001_000_00101_0110011; // ADD x5, x1, x2
        #10;
        $display("Test 1: R-type (ADD)");
        $display("  Opcode = %b, rs1 = %b, rs2 = %b, rd = %b, funct3 = %b, funct7 = %b, imm = %h",
                 opcode, rs1, rs2, rd, funct3, funct7, imm);
        if (opcode !== 7'b0110011 || rs1 !== 5'b00001 || rs2 !== 5'b00010 || rd !== 5'b00101 || funct3 !== 3'b000 || funct7 !== 7'b0000000 || imm !== 32'b0)
            $display("❌ ERROR: Test 1 failed!");
        else
            $display("✅ PASS");

        // Test 2: I-type instruction (ADDI)
        instr = 32'b111111111111_00001_000_00101_0010011; // ADDI x5, x1, -1
        #10;
        $display("\nTest 2: I-type (ADDI)");
        $display("  Opcode = %b, rs1 = %b, rs2 = %b, rd = %b, funct3 = %b, funct7 = %b, imm = %h",
                 opcode, rs1, rs2, rd, funct3, funct7, imm);
        if (opcode !== 7'b0010011 || rs1 !== 5'b00001 || rs2 !== 5'b00000 || rd !== 5'b00101 || funct3 !== 3'b000 || imm !== 32'hFFFFFFFF)
            $display("❌ ERROR: Test 2 failed!");
        else
            $display("✅ PASS");

        // Test 3: S-type instruction (SW)
        instr = 32'b1111111_00010_00001_010_11100_0100011; // SW x2, -4(x1)
        #10;
        $display("\nTest 3: S-type (SW)");
        $display("  Opcode = %b, rs1 = %b, rs2 = %b, rd = %b, funct3 = %b, funct7 = %b, imm = %h",
                 opcode, rs1, rs2, rd, funct3, funct7, imm);
        if (opcode !== 7'b0100011 || rs1 !== 5'b00001 || rs2 !== 5'b00010 || rd !== 5'b00000 || funct3 !== 3'b010 || imm !== 32'hFFFFFFFC)
            $display("❌ ERROR: Test 3 failed!");
        else
            $display("✅ PASS");

        // Test 4: B-type instruction (BEQ)
        instr = 32'b1111111_00010_00001_000_11001_1100011; // BEQ x1, x2, -8    1_111111_00010_00001_001_1100_1_1100011
        #10;
        $display("\nTest 4: B-type (BEQ)");
        $display("  Opcode = %b, rs1 = %b, rs2 = %b, rd = %b, funct3 = %b, funct7 = %b, imm = %h",
                 opcode, rs1, rs2, rd, funct3, funct7, imm);
        if (opcode !== 7'b1100011 || rs1 !== 5'b00001 || rs2 !== 5'b00010 || rd !== 5'b00000 || funct3 !== 3'b000 || imm !== 32'hFFFFFFF8)  // (32'hFFFFFFF8)
            $display("❌ ERROR: Test 4 failed!");
        else
            $display("✅ PASS");

        // Test 5: J-type instruction (JAL)
        instr = 32'b1_1111111110_1_11111111_00101_1101111; // JAL x5, -4    // 32'b1_1111111000_0_11111111_00101_1101111
        #10;
        $display("\nTest 5: J-type (JAL)");
        $display("  Opcode = %b, rs1 = %b, rs2 = %b, rd = %b, funct3 = %b, funct7 = %b, imm = %h",
                 opcode, rs1, rs2, rd, funct3, funct7, imm);
        if (opcode !== 7'b1101111 || rd !== 5'b00101 || imm !== 32'hFFFFFFFC)   // (32'hFFFFFFFC)
            $display("❌ ERROR: Test 5 failed!");
        else
            $display("✅ PASS");

        // Test 6: Invalid opcode
        instr = 32'b0000000_00010_00001_000_00101_1111111; // Invalid opcode
        #10;
        $display("\nTest 6: Invalid opcode");
        $display("  Opcode = %b, rs1 = %b, rs2 = %b, rd = %b, funct3 = %b, funct7 = %b, imm = %h",
                 opcode, rs1, rs2, rd, funct3, funct7, imm);
        if (opcode !== 7'b1111111 || rs1 !== 5'b00000 || rs2 !== 5'b00000 || rd !== 5'b00000 || funct3 !== 3'b000 || funct7 !== 7'b0000000 || imm !== 32'b0)
            $display("❌ ERROR: Test 6 failed!");
        else
            $display("✅ PASS");


        // End simulation
        $display("\n===========================");
        $display("✅ All tests completed.");
        $display("===========================\n");
        $finish;
    end

endmodule