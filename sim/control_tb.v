`timescale 1ns / 1ps

module control_tb;

    // Inputs
    reg  [6:0] opcode;

    // Outputs
    wire       reg_write;
    wire       alu_src;
    wire       mem_write;
    wire       mem_read;
    wire       mem_to_reg;
    wire       branch;
    wire       jump;

    // Instantiate the control module
    control uut (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump)
    );

    // Testbench logic
    initial begin
        // Open a file to log results
        $dumpfile("wave/control_tb.vcd");
        $dumpvars(0, control_tb);

        $display("\n===========================");
        $display("🚀 Starting Control Tests...");
        $display("===========================\n");

        // Test 1: R-type instruction (ADD)
        opcode = 7'b0110011; // R-type
        #10;
        $display("Test 1: R-type (ADD)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 1 || alu_src !== 0 || mem_write !== 0 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 0 || jump !== 0)
            $display("❌ ERROR: Test 1 failed!");
        else
            $display("✅ PASS");

        // Test 2: I-type instruction (ADDI)
        opcode = 7'b0010011; // I-type
        #10;
        $display("\nTest 2: I-type (ADDI)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 1 || alu_src !== 1 || mem_write !== 0 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 0 || jump !== 0)
            $display("❌ ERROR: Test 2 failed!");
        else
            $display("✅ PASS");

        // Test 3: Load instruction (LW)
        opcode = 7'b0000011; // Load
        #10;
        $display("\nTest 3: Load (LW)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 1 || alu_src !== 1 || mem_write !== 0 || mem_read !== 1 || mem_to_reg !== 1 || branch !== 0 || jump !== 0)
            $display("❌ ERROR: Test 3 failed!");
        else
            $display("✅ PASS");

        // Test 4: Store instruction (SW)
        opcode = 7'b0100011; // Store
        #10;
        $display("\nTest 4: Store (SW)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 0 || alu_src !== 1 || mem_write !== 1 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 0 || jump !== 0)
            $display("❌ ERROR: Test 4 failed!");
        else
            $display("✅ PASS");

        // Test 5: Branch instruction (BEQ)
        opcode = 7'b1100011; // Branch
        #10;
        $display("\nTest 5: Branch (BEQ)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 0 || alu_src !== 0 || mem_write !== 0 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 1 || jump !== 0)
            $display("❌ ERROR: Test 5 failed!");
        else
            $display("✅ PASS");

        // Test 6: Jump instruction (JAL)
        opcode = 7'b1101111; // JAL
        #10;
        $display("\nTest 6: Jump (JAL)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 1 || alu_src !== 0 || mem_write !== 0 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 0 || jump !== 1)
            $display("❌ ERROR: Test 6 failed!");
        else
            $display("✅ PASS");

        // Test 7: Jump and Link Register instruction (JALR)
        opcode = 7'b1100111; // JALR
        #10;
        $display("\nTest 7: Jump and Link Register (JALR)");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 1 || alu_src !== 1 || mem_write !== 0 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 0 || jump !== 1)
            $display("❌ ERROR: Test 7 failed!");
        else
            $display("✅ PASS");

        // Test 8: Invalid opcode
        opcode = 7'b1111111; // Invalid
        #10;
        $display("\nTest 8: Invalid opcode");
        $display("  Opcode = %b, reg_write = %b, alu_src = %b, mem_write = %b, mem_read = %b, mem_to_reg = %b, branch = %b, jump = %b",
                 opcode, reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump);
        if (reg_write !== 0 || alu_src !== 0 || mem_write !== 0 || mem_read !== 0 || mem_to_reg !== 0 || branch !== 0 || jump !== 0)
            $display("❌ ERROR: Test 8 failed!");
        else
            $display("✅ PASS");

        // End simulation
        $display("\n===========================");
        $display("✅ All tests completed.");
        $display("===========================\n");
        $finish;
    end

endmodule