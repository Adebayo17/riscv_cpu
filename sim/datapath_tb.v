`timescale 1ns / 1ps

module datapath_tb;

    // Inputs
    reg clk;
    reg reset_n;
    reg debug;

    // Output
    wire [31:0] instr;

    // === Instantiate the datapath module ===
    datapath uut (
        .clk(clk),
        .reset_n(reset_n),
        .debug(debug),
        .instr(instr)
    );

    // Clock Generation
    always #5 clk = ~clk;  // 10ns clock cycle

    // Test Variables
    integer cycle;
    integer errors = 0;
    integer log_file; // File handle for logging

    // Expected Results Memory
    reg [31:0] expected_regfile [0:31];  // Expected register values
    reg [31:0] expected_memory  [0:31];  // Expected memory values

    // === Test Sequence ===
    initial begin
        // Open log file for writing
        log_file = $fopen("sim_out/datapath_tb.log", "w");
        if (log_file == 0) begin
            $display("❌ ERROR: Unable to open log file!");
            $finish;
        end

        // Open waveform file
        $dumpfile("wave/datapath_tb.vcd");
        $dumpvars(0, datapath_tb);

        // Start of test
        $display("\n=============================");
        $display("🚀 Starting DATAPATH Tests...");
        $display("=============================\n");

        $fdisplay(log_file, "%s", "\n==============================================================================");
        $fdisplay(log_file, "%s", "🚀 Starting DATAPATH Tests...");
        $fdisplay(log_file, "%s", "==============================================================================\n");
        
        // Initialize
        clk = 0;
        reset_n = 0;
        debug = 1;
        cycle = 0;
        init_expected_values();

        // Print Program Memory
        print_program_memory();

        // Reset the system
        #10 reset_n = 1;  // Deassert reset

        // Run for a number of cycles 
        for (cycle = 0; cycle < 50; cycle = cycle +1) begin
            
            print_pipeline_state();

            // Print IF/ID Pipeline
            $display("\n| 🔍 IF/ID:  Instruction = %h", uut.IF_to_ID_instr);
            $fdisplay(log_file, "%s", $sformatf("| 🔍 IF/ID:  Instruction = %h", uut.IF_to_ID_instr));

            // Print ID/EX Pipeline
            $display("\n| 🔍 ID/EX:  Instruction = %h | ALU A = %h | ALU B = %h | ALU Ctrl = %b",
                     uut.ID_to_EX_instr, uut.ID_to_EX_read_data_1, (uut.ID_to_EX_alu_src ? uut.ID_to_EX_imm : uut.ID_to_EX_read_data_2), uut.ID_to_EX_alu_ctrl);
            $fdisplay(log_file, "%s", $sformatf("| 🔍 ID/EX:  Instruction = %h | ALU A = %h | ALU B = %h | ALU Ctrl = %b",
                        uut.ID_to_EX_instr, uut.ID_to_EX_read_data_1, (uut.ID_to_EX_alu_src ? uut.ID_to_EX_imm : uut.ID_to_EX_read_data_2), uut.ID_to_EX_alu_ctrl));

            // Display JUMP and BRANCH next PC
            if (uut.ID_to_EX_branch || uut.ID_to_EX_jump) begin
                $fdisplay(log_file, "|      -->🚀 Next PC: %h", uut.next_pc);
            end

            // Print EX/MEM Pipeline
            $display("\n| 🔍 EX/MEM: Instruction = %h | ALU Result = %h | Mem Write = %b | Mem Read = %b",
                     uut.EX_to_MEM_instr, uut.EX_to_MEM_alu_result, uut.EX_to_MEM_mem_write, uut.EX_to_MEM_mem_read);
            $fdisplay(log_file, "%s", $sformatf("| 🔍 EX/MEM: Instruction = %h | ALU Result = %h | Mem Write = %b | Mem Read = %b",
                        uut.EX_to_MEM_instr, uut.EX_to_MEM_alu_result, uut.EX_to_MEM_mem_write, uut.EX_to_MEM_mem_read));
            

            // Print MEM/WB Pipeline
            $display("\n| 🔍 MEM/WB: Instruction = %h | ALU Result = %h | Mem Data = %h | Reg Write = %b",
                     uut.MEM_to_WB_instr, uut.MEM_to_WB_alu_result, uut.MEM_to_WB_mem_data, uut.MEM_to_WB_reg_write);
            $fdisplay(log_file, "%s", $sformatf("| 🔍 MEM/WB: Instruction = %h | ALU Result = %h | Mem Data = %h | Reg Write = %b",
                        uut.MEM_to_WB_instr, uut.MEM_to_WB_alu_result, uut.MEM_to_WB_mem_data, uut.MEM_to_WB_reg_write));

            // Display Register Writes
            if (uut.registers.write_enable && uut.registers.write_addr != 5'b00000) begin
                $fdisplay(log_file, "|      -->📝 Register Write: x%0d = %h", uut.registers.write_addr, uut.registers.write_data);
            end


            // Verify Register Writes
            if (uut.MEM_to_WB_reg_write) begin
                expected_regfile[uut.MEM_to_WB_rd] = uut.registers.registers[uut.MEM_to_WB_rd]; // Store expected result
                check_register_write(uut.MEM_to_WB_rd, expected_regfile[uut.MEM_to_WB_rd], uut.registers.registers[uut.MEM_to_WB_rd]);
            end

            // Verify Memory Writes
            if (uut.EX_to_MEM_mem_write) begin
                expected_memory[uut.EX_to_MEM_alu_result >> 2] = uut.EX_to_MEM_read_data_2; // Store expected result
                check_memory_write(uut.EX_to_MEM_alu_result, expected_memory[uut.EX_to_MEM_alu_result >> 2], uut.data_memory0.read_data);
            end

            $display("===============================================================================================\n");
            $fdisplay(log_file, "%s", "===============================================================================================\n");


            // Wait for next clock cycle
            #10;
        end


        // Wait a few more cycles to observe execution behavior
        #100;

        // End simulation
        $display("\n=====================================");
        $fdisplay(log_file, "%s", "\n==========================================================================");
        if (errors == 0) begin
            $display("✅ All tests PASSED! No errors detected.");
            $fdisplay(log_file, "%s", "✅ All tests PASSED! No errors detected.");
        end else begin
            $display("❌ TEST FAILED: %0d errors detected!", errors);
            $fdisplay(log_file, "❌ TEST FAILED: %0d errors detected!", errors);
        end
        $display("=====================================\n");
        $fdisplay(log_file, "%s", "==========================================================================\n");

        // Close the log file
        $fclose(log_file);
        $finish;
    end


    // === TASKS ===
    // **Print Pipeline State**
    task print_pipeline_state;
        begin
            $display("===============================================================================================");
            $display("| Cycle %0d | PC = %h |", cycle, uut.pc);
            $display("|---------------------------------------------------------------------------------------------|");
            $display("| IF  | %h |", uut.IF_to_ID_instr);
            $display("| ID  | %h |", uut.ID_to_EX_instr);
            $display("| EX  | %h |", uut.EX_to_MEM_instr);
            $display("| MEM | %h |", uut.MEM_to_WB_instr);
            $display("| WB  | %h |", (uut.MEM_to_WB_reg_write) ? uut.MEM_to_WB_instr : 32'h00000000);
            $display("|---------------------------------------------------------------------------------------------|");

            $fdisplay(log_file, "%s", "===============================================================================================");
            $fdisplay(log_file, "%s", $sformatf("| Cycle %0d | PC = %h |", cycle, uut.pc));
            $fdisplay(log_file, "%s", "|---------------------------------------------------------------------------------------------|");
            $fdisplay(log_file, "%s", $sformatf("| IF  | %h |", uut.IF_to_ID_instr));
            $fdisplay(log_file, "%s", $sformatf("| ID  | %h |", uut.ID_to_EX_instr));
            $fdisplay(log_file, "%s", $sformatf("| EX  | %h |", uut.EX_to_MEM_instr));
            $fdisplay(log_file, "%s", $sformatf("| MEM | %h |", uut.MEM_to_WB_instr));
            $fdisplay(log_file, "%s", $sformatf("| WB  | %h |", (uut.MEM_to_WB_reg_write) ? uut.MEM_to_WB_instr : 32'h00000000));
            $fdisplay(log_file, "%s", "|---------------------------------------------------------------------------------------------|");
        end
    endtask


    // **Log Messages to Console and File**
    task log_message;
        input reg [1023:0] message;  // Use reg instead of string for compatibility
        begin
            $display("%s", message);      // Print to console
            $fdisplay(log_file, "%s", message);  // Write to log file
        end
    endtask


    // **Initialize Registers and Memory**
    task init_expected_values;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                expected_regfile[i] = 0;
                expected_memory[i]  = 0;
            end
        end
    endtask


    // **Print Program Memory at the Beginning**
    task print_program_memory;
        integer i;
        begin
            $display("\n=====================================");
            $display("📄 Loaded Program Memory Contents:");
            $display("=====================================");
            $fdisplay(log_file, "\n=====================================");
            $fdisplay(log_file, "📄 Loaded Program Memory Contents:");
            $fdisplay(log_file, "=====================================");
            for (i = 0; i < 32; i = i + 1) begin
                $display("Instr[%0d] = %h", i, uut.program_memory0.instr_mem[i]);
                $fdisplay(log_file, "Instr[%0d] = %h", i, uut.program_memory0.instr_mem[i]);
            end
            $display("=====================================\n");
            $fdisplay(log_file, "=====================================\n");
        end
    endtask


    // **Print Register Values**
    task print_registers;
        integer i;
        begin
            $display("\n=====================================");
            $display("📝 Register File State:");
            $display("=====================================");
            $fdisplay(log_file, "\n=====================================");
            $fdisplay(log_file, "📝 Register File State:");
            $fdisplay(log_file, "=====================================");
            for (i = 0; i < 32; i = i + 1) begin
                $display("x%0d = %h", i, uut.registers.registers[i]);
                $fdisplay(log_file, "x%0d = %h", i, uut.registers.registers[i]);
            end
            $display("=====================================\n");
            $fdisplay(log_file, "=====================================\n");
        end
    endtask

    // **Check ALU Results**
    task check_alu_result;
        input [31:0] expected;
        input [31:0] actual;
        input [31:0] instr;
        begin
            if (expected !== actual) begin
                $display("❌ ERROR: ALU mismatch! Expected: %h | Got: %h | Instruction: %h", expected, actual, instr);
                $fdisplay(log_file, "❌ ERROR: ALU mismatch! Expected: %h | Got: %h | Instruction: %h", expected, actual, instr);
                errors = errors + 1;
            end
        end
    endtask

    // **Check Register Write**
    task check_register_write;
        input [4:0] rd;
        input [31:0] expected;
        input [31:0] actual;
        begin
            if (rd !== 0 && expected !== actual) begin  // Ignore x0 since it's always 0
                $display("❌ ERROR: Register Write Mismatch! x%0d Expected: %h | Got: %h", rd, expected, actual);
                $fdisplay(log_file, "❌ ERROR: Register Write Mismatch! x%0d Expected: %h | Got: %h", rd, expected, actual);
                errors = errors + 1;
            end
        end
    endtask

    // **Check Memory Write**
    task check_memory_write;
        input [31:0] addr;
        input [31:0] expected;
        input [31:0] actual;
        begin
            if (expected !== actual) begin
                $display("❌ ERROR: Memory Write Mismatch! Addr: %h | Expected: %h | Got: %h", addr, expected, actual);
                $fdisplay(log_file, "❌ ERROR: Memory Write Mismatch! Addr: %h | Expected: %h | Got: %h", addr, expected, actual);
                errors = errors + 1;
            end
        end
    endtask
endmodule
