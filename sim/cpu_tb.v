`timescale 1ns / 1ps
module cpu_tb;
    
    reg clk, reset_n, debug;

    integer alu_results, expected_results, mismatches;
    reg [3:0] alu_ctrl;
    reg [31:0] a, b, expected, computed;

    cpu uut (
        .clk(clk),
        .reset_n(reset_n),
        .debug(debug)
    );

    // Clock Generation
    always #5 clk = ~clk;  

    initial begin
        $dumpfile("wave/dump.vcd");     // Create waveform file
        $dumpvars(0, cpu_tb);           // Dump all signals
    end

    initial begin
        clk   = 0;
        reset_n = 0;
        debug = 1'b1;
        #20 reset_n = 1;

        #200;  // Run simulation for some time
        $finish;
    end

    // initial begin
    //     mismatches = 0;
    //     #1000;  // Wait for execution to complete

    //     alu_results = $fopen("sim_out/alu_results.log", "r");
    //     expected_results = $fopen("sim/expected_results.mem", "r");

    //     if (alu_results == 0 || expected_results == 0) begin
    //         $display("❌ ERROR: Unable to open result files!");
    //         $finish;
    //     end

    //     $display("\n================ ALU RESULT VERIFICATION ================");

    //     while (!$feof(alu_results) && !$feof(expected_results)) begin
    //         $fscanf(alu_results, "%h %h %h %h\n", alu_ctrl, a, b, computed);
    //         $fscanf(expected_results, "%h %h %h %h\n", alu_ctrl, a, b, expected);

    //         if (computed !== expected) begin
    //             mismatches = mismatches + 1;
    //             $display("❌ MISMATCH: Instruction=%h | A=%h | B=%h | Computed=%h | Expected=%h", 
    //                      alu_ctrl, a, b, computed, expected);
    //         end
    //     end

    //     if (mismatches == 0) begin
    //         $display("✅ ALU TEST PASSED! All results are correct.");
    //     end else begin
    //         $display("❌ ALU TEST FAILED! %d errors detected.", mismatches);
    //     end

    //     $display("=========================================================");

    //     $fclose(alu_results);
    //     $fclose(expected_results);
    //     $finish;
    // end
endmodule
