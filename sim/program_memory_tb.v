`timescale 1ns / 1ps

module program_memory_tb;

    // Testbench signals
    reg        debug;
    reg [31:0] pc;
    wire [31:0] instr_out;

    // Instantiate the program_memory module
    program_memory uut (
        .debug(debug),
        .pc(pc),
        .instr_out(instr_out)
    );

    // Testbench logic
    initial begin
        debug = 1;  // Enable debug messages
        
        // Open VCD file for waveform dumping
        $dumpfile("wave/program_memory_tb.vcd");
        $dumpvars(0, program_memory_tb);

        $display("\n==================================");
        $display("🚀 Starting PROGRAM MEMORY Tests...");
        $display("==================================\n");


        // === Test 1: Read Instructions Sequentially ===
        pc = 32'h00000000;
        #10;
        $display("Test 1: Fetch instruction at PC = %h", pc);
        $display("  Instruction = %h", instr_out);

        pc = 32'h00000004;
        #10;
        $display("Test 1: Fetch instruction at PC = %h", pc);
        $display("  Instruction = %h", instr_out);

        pc = 32'h00000008;
        #10;
        $display("Test 1: Fetch instruction at PC = %h", pc);
        $display("  Instruction = %h", instr_out);

        // === Test 2: Read Beyond Program Size ===
        pc = 32'h00000080; // Address out of expected range
        #10;
        $display("Test 2: Fetch out-of-bound instruction at PC = %h", pc);
        $display("  Instruction = %h (Expected: 00000000 if memory is 0-initialized)", instr_out);

        // === Test 3: Read Random Addresses ===
        pc = 32'h0000000C;
        #10;
        $display("Test 3: Fetch instruction at PC = %h", pc);
        $display("  Instruction = %h", instr_out);

        pc = 32'h00000010;
        #10;
        $display("Test 3: Fetch instruction at PC = %h", pc);
        $display("  Instruction = %h", instr_out);

        // End simulation
        $display("\n===========================");
        $display("✅ All tests completed.");
        $display("===========================\n");
        $finish;
    end
endmodule
