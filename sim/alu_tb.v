`timescale 1ns / 1ps

module alu_tb;

    // Inputs
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctrl;

    // Outputs
    wire [31:0] result;
    wire        zero;
    wire        alu_ready;

    // Instantiate the ALU module
    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero),
        .alu_ready(alu_ready)
    );

    // Testbench logic
    initial begin
        // Open a file to log results
        $dumpfile("wave/alu_tb.vcd");
        $dumpvars(0, alu_tb);

        $display("\n===========================");
        $display("🚀 Starting ALU Tests...");
        $display("===========================\n");

        // Test 1: ADD operation (positive + positive)
        a = 32'h00000005;
        b = 32'h00000003;
        alu_ctrl = 4'b0000; // ADD
        #10;
        $display("Test 1: ADD (positive + positive)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000008 || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 1 failed!");
        else
            $display("✅ PASS");

        // Test 2: ADD operation (negative + negative)
        a = 32'hFFFFFFFC; // -4
        b = 32'hFFFFFFFE; // -2
        alu_ctrl = 4'b0000; // ADD
        #10;
        $display("\nTest 2: ADD (negative + negative)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'hFFFFFFFA || zero !== 0 || alu_ready !== 1) // -6
            $display("❌ ERROR: Test 2 failed!");
        else
            $display("✅ PASS");

        // Test 3: ADD operation (negative + positive)
        a = 32'hFFFFFFFC; // -4
        b = 32'h00000003; // 3
        alu_ctrl = 4'b0000; // ADD
        #10;
        $display("\nTest 3: ADD (negative + positive)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'hFFFFFFFF || zero !== 0 || alu_ready !== 1) // -1
            $display("❌ ERROR: Test 3 failed!");
        else
            $display("✅ PASS");

        // Test 4: SUB operation (positive - positive)
        a = 32'h00000005;
        b = 32'h00000003;
        alu_ctrl = 4'b0001; // SUB
        #10;
        $display("\nTest 4: SUB (positive - positive)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000002 || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 4 failed!");
        else
            $display("✅ PASS");

        // Test 5: SUB operation (negative - negative)
        a = 32'hFFFFFFFC; // -4
        b = 32'hFFFFFFFE; // -2
        alu_ctrl = 4'b0001; // SUB
        #10;
        $display("\nTest 5: SUB (negative - negative)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'hFFFFFFFE || zero !== 0 || alu_ready !== 1) // -2
            $display("❌ ERROR: Test 5 failed!");
        else
            $display("✅ PASS");

        // Test 6: SUB operation (negative - positive)
        a = 32'hFFFFFFFC; // -4
        b = 32'h00000003; // 3
        alu_ctrl = 4'b0001; // SUB
        #10;
        $display("\nTest 6: SUB (negative - positive)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'hFFFFFFF9 || zero !== 0 || alu_ready !== 1) // -7
            $display("❌ ERROR: Test 6 failed!");
        else
            $display("✅ PASS");

        // Test 7: AND operation
        a = 32'h0000000F;
        b = 32'h0000000A;
        alu_ctrl = 4'b0010; // AND
        #10;
        $display("\nTest 7: AND");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h0000000A || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 7 failed!");
        else
            $display("✅ PASS");

        // Test 8: OR operation
        a = 32'h0000000F;
        b = 32'h0000000A;
        alu_ctrl = 4'b0011; // OR
        #10;
        $display("\nTest 8: OR");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h0000000F || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 8 failed!");
        else
            $display("✅ PASS");

        // Test 9: XOR operation
        a = 32'h0000000F;
        b = 32'h0000000A;
        alu_ctrl = 4'b0100; // XOR
        #10;
        $display("\nTest 9: XOR");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000005 || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 9 failed!");
        else
            $display("✅ PASS");

        // Test 10: SLL operation
        a = 32'h0000000F;
        b = 32'h00000002;
        alu_ctrl = 4'b0101; // SLL
        #10;
        $display("\nTest 10: SLL");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h0000003C || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 10 failed!");
        else
            $display("✅ PASS");

        // Test 11: SRL operation
        a = 32'h0000000F;
        b = 32'h00000002;
        alu_ctrl = 4'b0110; // SRL
        #10;
        $display("\nTest 11: SRL");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000003 || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 11 failed!");
        else
            $display("✅ PASS");

        // Test 12: SRA operation (negative >> positive)
        a = 32'hF000000F;
        b = 32'h00000002;
        alu_ctrl = 4'b0111; // SRA
        #10;
        $display("\nTest 12: SRA");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'hFC000003 || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 12 failed!");
        else
            $display("✅ PASS");

        // Test 13: MUL operation (positive * positive)
        a = 32'h00000005;
        b = 32'h00000003;
        alu_ctrl = 4'b1000; // MUL
        #10;
        $display("\nTest 13: MUL (positive * positive)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h0000000F || zero !== 0 || alu_ready !== 1)
            $display("❌ ERROR: Test 13 failed!");
        else
            $display("✅ PASS");
        
        // Test 14: MUL operation (negative * negative)
        a = 32'hFFFFFFFC; // -4
        b = 32'hFFFFFFFE; // -2
        alu_ctrl = 4'b1000; // MUL
        #10;
        $display("\nTest 14: MUL (negative * negative)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000008 || zero !== 0 || alu_ready !== 1) // 8
            $display("❌ ERROR: Test 14 failed!");
        else
            $display("✅ PASS");

        // Test 15: MUL operation (negative * positive)
        a = 32'hFFFFFFFC; // -4
        b = 32'h00000003; // 3
        alu_ctrl = 4'b1000; // MUL
        #10;
        $display("\nTest 15: MUL (negative * positive)");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'hFFFFFFF4 || zero !== 0 || alu_ready !== 1) // -12
            $display("❌ ERROR: Test 15 failed!");
        else
            $display("✅ PASS");


        // Test 16: Zero flag test
        a = 32'h00000000;
        b = 32'h00000000;
        alu_ctrl = 4'b0000; // ADD
        #10;
        $display("\nTest 16: Zero Flag Test");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000000 || zero !== 1 || alu_ready !== 1)
            $display("❌ ERROR: Test 16 failed!");
        else
            $display("✅ PASS");
        
        // Test 17: Incorrect ALU operation
        a = 32'h00000005;
        b = 32'h00000005;
        alu_ctrl = 4'b1111; // Incorrect operation
        #10;
        $display("\nTest 17: Incorrect ALU operation");
        $display("  a = %h, b = %h, alu_ctrl = %b, result = %h, zero = %b, alu_ready = %b",
                 a, b, alu_ctrl, result, zero, alu_ready);
        if (result !== 32'h00000000 || zero !== 1 || alu_ready !== 1)
            $display("❌ ERROR: Test 17 failed!");
        else
            $display("✅ PASS");

        // End simulation
        $display("\n===========================");
        $display("✅ All tests completed.");
        $display("===========================\n");
        $finish;
    end

endmodule