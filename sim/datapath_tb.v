`timescale 1ns / 1ps

module datapath_tb;

    // Inputs
    reg clk;
    reg reset_n;
    reg debug;

    // Output
    wire [31:0] instr;

    // Instantiate the datapath module
    datapath uut (
        .clk(clk),
        .reset_n(reset_n),
        .debug(debug),
        .instr(instr)
    );

    // Clock Generation
    always #5 clk = ~clk;  // 10ns clock cycle

    // Test Sequence
    initial begin
        // Initialize
        $dumpfile("wave/datapath_tb.vcd");
        $dumpvars(0, datapath_tb);

        $display("\n=============================");
        $display("🚀 Starting DATAPATH Tests...");
        $display("============================\n");
        
        clk = 0;
        reset_n = 0;
        debug = 1;

        // Reset the system
        #10 reset_n = 1;  // Deassert reset

        // Print out the fetched instructions for the first 5 cycles
        for (integer i = 0; i < 32; i = i + 1) begin
            // #10;
            $display("Cycle %0d: PC = %h | Instruction = %h", i, uut.pc, instr);
            #10;
        end

        // Wait a few more cycles to observe execution behavior
        #100;

        // End simulation
        $display("\n===========================");
        $display("✅ All tests completed.");
        $display("===========================\n");
        $finish;
    end
endmodule
