`timescale 1ns / 1ps

module regfile_tb;

    // Inputs
    reg         clk;
    reg         write_enable;
    reg  [4:0]  read_addr_1;
    reg  [4:0]  read_addr_2;
    reg  [4:0]  write_addr;
    reg  [31:0] write_data;

    // Outputs
    wire [31:0] read_data_1;
    wire [31:0] read_data_2;

    // Instantiate the regfile module
    regfile uut (
        .clk(clk),
        .write_enable(write_enable),
        .read_addr_1(read_addr_1),
        .read_addr_2(read_addr_2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Testbench logic
    initial begin
        // Initialize inputs
        clk = 0;
        write_enable = 0;
        read_addr_1 = 0;
        read_addr_2 = 0;
        write_addr = 0;
        write_data = 0;

        // Open a file to log results
        $dumpfile("wave/regfile_tb.vcd");
        $dumpvars(0, regfile_tb);

        // Test 1: Write to register x1 and read back
        #10;
        write_enable = 1;
        write_addr = 5'b00001; // x1
        write_data = 32'h12345678;
        #10;
        write_enable = 0;
        read_addr_1 = 5'b00001; // Read from x1
        #10;
        $display("Test 1: Write 0x12345678 to x1, Read Data 1 = 0x%h", read_data_1);
        if (read_data_1 !== 32'h12345678) $display("ERROR: Test 1 failed!");

        // Test 2: Write to register x2 and read back
        #10;
        write_enable = 1;
        write_addr = 5'b00010; // x2
        write_data = 32'hABCDEF01;
        #10;
        write_enable = 0;
        read_addr_2 = 5'b00010; // Read from x2
        #10;
        $display("Test 2: Write 0xABCDEF01 to x2, Read Data 2 = 0x%h", read_data_2);
        if (read_data_2 !== 32'hABCDEF01) $display("ERROR: Test 2 failed!");

        // Test 3: Write to register x0 (should remain zero)
        #10;
        write_enable = 1;
        write_addr = 5'b00000; // x0
        write_data = 32'hDEADBEEF;
        #10;
        write_enable = 0;
        read_addr_1 = 5'b00000; // Read from x0
        #10;
        $display("Test 3: Write 0xDEADBEEF to x0, Read Data 1 = 0x%h", read_data_1);
        if (read_data_1 !== 32'h00000000) $display("ERROR: Test 3 failed!");

        // Test 4: Simultaneous read and write
        #10;
        write_enable = 1;
        write_addr = 5'b00011; // x3
        write_data = 32'hCAFEBABE;
        read_addr_1 = 5'b00011; // Read from x3
        #10;
        write_enable = 0;
        #10;
        $display("Test 4: Write 0xCAFEBABE to x3, Read Data 1 = 0x%h", read_data_1);
        if (read_data_1 !== 32'hCAFEBABE) $display("ERROR: Test 4 failed!");

        // Test 5: Read from two different registers simultaneously
        #10;
        read_addr_1 = 5'b00001; // Read from x1
        read_addr_2 = 5'b00010; // Read from x2
        #10;
        $display("Test 5: Read Data 1 = 0x%h (x1), Read Data 2 = 0x%h (x2)", read_data_1, read_data_2);
        if (read_data_1 !== 32'h12345678 || read_data_2 !== 32'hABCDEF01) $display("ERROR: Test 5 failed!");

        // End simulation
        $display("All tests completed.");
        $finish;
    end

endmodule