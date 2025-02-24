`timescale 1ns / 1ps

module data_memory_tb;

    // Inputs
    reg        clk;
    reg        reset_n;
    reg        debug;
    reg        mem_write;
    reg        mem_read;
    reg [31:0] data_addr;
    reg [31:0] write_data;

    // Outputs
    wire [31:0] read_data;

    // Instantiate the data_memory module
    data_memory uut (
        .clk(clk),
        .reset_n(reset_n),
        .debug(debug),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .data_addr(data_addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    // Clock Generation
    always #5 clk = ~clk;  // 10 ns clock period

    initial begin
        // === Initialize Test ===
        $dumpfile("wave/data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);

        $display("\n===============================");
        $display("🚀 Starting DATA MEMORY Tests...");
        $display("===============================\n");

        clk       = 0;
        reset_n   = 0;  // Assert reset (clears memory)
        debug     = 1;  // Enable debug output
        mem_write = 0;
        mem_read  = 0;
        data_addr = 0;
        write_data = 0;

        // === Test 1: Reset Memory ===
        #10;
        $display("\nTest 1: Reset Memory");
        reset_n = 1;  // Release reset
        #10;

        // === Test 2: Write and Read from Memory ===
        $display("\nTest 2: Write and Read from Memory");
        // Write 0xAAAA5555 at address 0x00000008
        data_addr  = 32'h00000008;
        write_data = 32'hAAAA5555;
        mem_write  = 1;
        #10;
        mem_write  = 0;

        // Read back from address 0x00000008
        mem_read = 1;
        #10;
        if (read_data !== 32'hAAAA5555)
            $display("❌ ERROR: Memory Read Mismatch! Expected: 0xAAAA5555, Got: %h", read_data);
        else
            $display("✅ PASS: Memory Read Correct! Addr: %h -> Data: %h", data_addr, read_data);
        mem_read = 0;

        // === Test 3: Write Another Value and Read ===
        $display("\nTest 3: Write Another Value and Read");
        // Write 0x12345678 at address 0x00000010
        data_addr  = 32'h00000010;
        write_data = 32'h12345678;
        mem_write  = 1;
        #10;
        mem_write  = 0;

        // Read back from address 0x00000010
        mem_read = 1;
        #10;
        if (read_data !== 32'h12345678)
            $display("❌ ERROR: Memory Read Mismatch! Expected: 0x12345678, Got: %h", read_data);
        else
            $display("✅ PASS: Memory Read Correct! Addr: %h -> Data: %h", data_addr, read_data);
        mem_read = 0;

        // === Test 4: Read from Uninitialized Memory ===
        $display("\nTest 4: Read from Uninitialized Memory");
        data_addr = 32'h00000020; // Unused address
        mem_read  = 1;
        #10;
        if (read_data !== 32'h00000000)
            $display("❌ ERROR: Expected Uninitialized Memory to be 0, Got: %h", read_data);
        else
            $display("✅ PASS: Uninitialized Memory Read is Zero.");
        mem_read = 0;

        // === Test 5: Reset Memory and Check ===
        $display("\nTest 5: Reset Memory and Check");
        reset_n = 0;
        #10;
        reset_n = 1;
        #10;

        // Read back from address 0x00000008 (should be cleared)
        data_addr = 32'h00000008;
        mem_read  = 1;
        #10;
        if (read_data !== 32'h00000000)
            $display("❌ ERROR: Reset Failed! Addr %h -> Expected 0, Got: %h", data_addr, read_data);
        else
            $display("✅ PASS: Memory Reset Successful!");
        mem_read = 0;

        // End simulation
        $display("\n===========================");
        $display("✅ All tests completed.");
        $display("===========================\n");
        $finish;
    end
endmodule
