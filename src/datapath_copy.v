module datapath (
    input  wire clk,                // Clock and reset signals
    input  wire reset,              // Clock and reset signals
    input  wire debug,
    output wire [31:0] instr        // Instruction output (for debugging)
);

    // === PROGRAM COUNTER ===
    reg  [31:0] pc, next_pc;

    // === PIPELINE REGISTERS ===
    reg [31:0] IF_ID_instr, IF_ID_pc;
    reg [31:0] ID_EX_reg_data1, ID_EX_reg_data2, ID_EX_imm;
    reg [4:0]  ID_EX_rd;
    reg [3:0]  ID_EX_alu_ctrl;
    reg        ID_EX_alu_ready;
    reg        ID_EX_mem_read, ID_EX_mem_write, ID_EX_reg_write, ID_EX_mem_to_reg;
    reg [31:0] EX_MEM_alu_result, EX_MEM_reg_data2;
    reg [4:0]  EX_MEM_rd;
    reg        EX_MEM_mem_read, EX_MEM_mem_write, EX_MEM_reg_write, EX_MEM_mem_to_reg;
    reg [31:0] MEM_WB_mem_data, MEM_WB_alu_result;
    reg [4:0]  MEM_WB_rd;
    reg        MEM_WB_reg_write, MEM_WB_mem_to_reg;
    
    // === CONTROL SIGNALS ===
    wire [6:0]  opcode;
    wire [4:0]  rs1, rs2, rd;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;
    wire        reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch, jump;
    reg  [3:0]  alu_ctrl;
    wire [31:0] reg_data1, reg_data2, alu_result, mem_data;
    wire        alu_valid, alu_ready, enable;

    integer cycle = 0;

    // === INSTRUCTION FETCH (IF) ===
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;
            cycle <= 0;
        end else begin
            pc <= next_pc;
            cycle <= cycle + 1;
        end
    end 

    // === IF/ID PIPELINE REGISTER ===
    always @(posedge clk) begin
        IF_ID_instr <= instr;
        IF_ID_pc <= pc;
    end

    // === INSTRUCTION MEMORY (FETCH) ===
    memory mem_unit (
        .clk(clk),
        .reset(reset),

        // Instruction Fetch
        .pc(pc),                        // Pass PC for instruction fetch
        .instr_out(instr),              // Fetch instruction

        // Data Memory Read/Write
        .mem_write(EX_MEM_mem_write),
        .mem_read(EX_MEM_mem_read),
        .data_addr(EX_MEM_alu_result),  // Address for data memory
        .write_data(EX_MEM_reg_data2),  // Data to be stored
        .read_data(mem_data),           // Loaded data from memory

        .debug(debug)
    );

    // === INSTRUCTION DECODE (ID) ===
    decode decoder (
        .instr(IF_ID_instr),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm)
    );

    // === ALU CONTROL SIGNAL ===
    always @(*) begin
        case ({funct7, funct3})
            10'b0000000000: alu_ctrl = 4'b0000; // ADD
            10'b0100000000: alu_ctrl = 4'b0001; // SUB
            10'b0000000100: alu_ctrl = 4'b0100; // XOR
            10'b0000000110: alu_ctrl = 4'b0011; // OR
            10'b0000000111: alu_ctrl = 4'b0010; // AND
            10'b0000000001: alu_ctrl = 4'b0101; // SLL
            10'b0000000101: alu_ctrl = 4'b0110; // SRL
            10'b0100000101: alu_ctrl = 4'b0111; // SRA
            10'b0000001000: alu_ctrl = 4'b1000; // MUL
            10'b0000001100: alu_ctrl = 4'b1001; // DIV
            10'b0000001101: alu_ctrl = 4'b1011; // DIVU
            10'b0000001110: alu_ctrl = 4'b1010; // REM
            10'b0000001111: alu_ctrl = 4'b1100; // REMU
            default: begin
                if (debug) $display("⚠️ ERROR: Unknown ALU Operation funct3=%b funct7=%b", funct3, funct7);
                alu_ctrl = 4'b0000; // Default to ADD
            end
        endcase
    end


    control ctrl_unit (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump)
    );

    regfile registers (
        .clk(clk),
        .we(MEM_WB_reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(MEM_WB_rd),
        .wd(MEM_WB_mem_to_reg ? MEM_WB_mem_data : MEM_WB_alu_result),
        .rd1(reg_data1),
        .rd2(reg_data2)
    );

    // === ID/EX PIPELINE REGISTER ===
    always @(posedge clk) begin
        ID_EX_reg_data1     <= reg_data1;
        ID_EX_reg_data2     <= reg_data2;
        ID_EX_imm           <= imm;
        ID_EX_rd            <= rd;
        ID_EX_alu_ctrl      <= alu_ctrl;
        ID_EX_mem_read      <= mem_read;
        ID_EX_mem_write     <= mem_write;
        ID_EX_reg_write     <= reg_write;
        ID_EX_mem_to_reg    <= mem_to_reg;
        ID_EX_alu_ready     <= 1'b1;
    end

    // === EXECUTION (EX) ===
    alu alu_unit (
        .clk(clk),
        .enable(ID_EX_alu_ready),
        .a(ID_EX_reg_data1),
        .b(alu_src ? ID_EX_imm : ID_EX_reg_data2),
        .alu_ctrl(ID_EX_alu_ctrl),
        .result(alu_result),
        .zero(),
        .alu_ready(alu_ready)
    );

    // === EX/MEM PIPELINE REGISTER ===
    always @(posedge clk) begin
        EX_MEM_alu_result   <= alu_result;
        EX_MEM_reg_data2    <= ID_EX_reg_data2;
        EX_MEM_rd           <= ID_EX_rd;
        EX_MEM_mem_read     <= ID_EX_mem_read;
        EX_MEM_mem_write    <= ID_EX_mem_write;
        EX_MEM_reg_write    <= ID_EX_reg_write;
        EX_MEM_mem_to_reg   <= ID_EX_mem_to_reg;
    end

    // === MEM/WB PIPELINE REGISTER ===
    always @(posedge clk) begin
        MEM_WB_mem_data     <= mem_data;
        MEM_WB_alu_result   <= EX_MEM_alu_result;
        MEM_WB_rd           <= EX_MEM_rd;
        MEM_WB_reg_write    <= EX_MEM_reg_write;
        MEM_WB_mem_to_reg   <= EX_MEM_mem_to_reg;
    end

    // === WRITE BACK (WB) ===
    always @(posedge clk) begin
        if (MEM_WB_reg_write) begin
            registers.registers[MEM_WB_rd] <= MEM_WB_mem_to_reg ? MEM_WB_mem_data : MEM_WB_alu_result;
        end
    end


    // === PC Update Logic (Handles Jumps and Branches) ===
    always @(*) begin
        if (jump) begin
            case (opcode)
                7'b1101111: next_pc = pc + imm;                 // JAL (Jump and Link)
                7'b1100111: next_pc = (reg_data1 + imm) & ~1;   // JALR (Jump and Link Register)
                default:    next_pc = pc + 4;                   // Default case
            endcase
        end 
        else if (branch) begin
            case (funct3)
                3'b000: next_pc = (alu_result == 0)  ? pc + imm : pc + 4; // BEQ (Branch if Equal)
                3'b001: next_pc = (alu_result != 0)  ? pc + imm : pc + 4; // BNE (Branch if Not Equal)
                3'b100: next_pc = ($signed(reg_data1) <  $signed(reg_data2)) ? pc + imm : pc + 4; // BLT
                3'b101: next_pc = ($signed(reg_data1) >= $signed(reg_data2)) ? pc + imm : pc + 4; // BGE
                default: next_pc = pc + 4; // Default to sequential execution
            endcase
        end 
        else begin
            next_pc = pc + 4; // Default sequential execution
        end
    end

    reg [31:0] expected_result_mem [0:31];  // Memory to hold expected ALU results
    reg [31:0] expected_result;             // Current expected ALU result
    integer    instr_index;                 // Index for expected results
    integer    i;
    reg [31:0] result_queue [0:10];

    // === Load expected ALU results from file ===
    initial begin
        $readmemh("sim/expected_results.mem", expected_result_mem);
        for (i = 0; i < 10; i = i + 1) result_queue[i] = 32'h00000000;
    end

    always @(posedge clk) begin
        instr_index = (pc >> 2);  // Convert PC to instruction index
        expected_result <= expected_result_mem[instr_index];
    end

    // === Pipeline Shift Register (Tracks ALU Output Timing) ===
    always @(posedge clk) begin
        for (i = 9; i > 0; i = i - 1) begin
            result_queue[i] <= result_queue[i - 1];  // Shift results down
        end
        result_queue[0] <= alu_result;  // Store new ALU result
    end
    
    // === DEBUG PRINT PROCESS ===
    always @(posedge clk) begin
        if (debug) begin
            // $display("🔍 PC Update: Current PC=%h → Next PC=%h", pc, next_pc);

            // $display("\n================ Cycle: %0d ================", cycle);
            // $display("PC: %h | Instruction: %h", pc, instr);
            
            // // Print Register Writes
            // if (MEM_WB_reg_write) begin
            //     $display("✅ Register Write: x%0d = %h", MEM_WB_rd, registers.registers[MEM_WB_rd]);
            // end

            // // Print ALU Operations
            // // $display("🔍 ALU: Ctrl=%b | A=%h | B=%h | Result=%h", ID_EX_alu_ctrl, ID_EX_reg_data1, ID_EX_reg_data2, alu_result);
            // $display("🔍 ALU: Ctrl=%b | A=%h | B=%h | Result=%h", alu_unit.alu_ctrl, alu_unit.a, alu_unit.b, alu_unit.result);

            // // Print Memory Access
            // if (EX_MEM_mem_write) begin
            //     $display("📝 Memory Write: Addr %h = %h", EX_MEM_alu_result, EX_MEM_reg_data2);
            // end
            // if (EX_MEM_mem_read) begin
            //     $display("📖 Memory Read: Addr %h -> %h", EX_MEM_alu_result, mem_data);
            // end
            // $display("=============================================\n");


            $display("\n================================== Cycle: %0d ==================================", cycle);
            $display("PC: %h | Instruction: %h", pc, instr);
            $display("🔍 PC Update: Current PC=%h → Next PC=%h", pc, next_pc);
            
            // === FETCH STAGE ===
            $display("\n==== FETCH ====");
            $display("Fetched Instruction: %h", IF_ID_instr);

            // === DECODE STAGE ===
            $display("\n==== DECODE ====");
            $display("Decoded Instruction: %h", ID_EX_rd);
            $display("Opcode: %b | Funct3: %b | Funct7: %b", opcode, funct3, funct7);
            $display("Source Registers: rs1 = x%0d (%h), rs2 = x%0d (%h)", rs1, reg_data1, rs2, reg_data2);
            $display("Destination Register: x%0d", rd);
            $display("Immediate Value: %h", imm);

            // === EXECUTION STAGE ===
            $display("\n==== EXECUTE ====");
            $display("ALU Operation: Ctrl=%b | A=%h | B=%h | Result=%h", ID_EX_alu_ctrl, ID_EX_reg_data1, (alu_src ? ID_EX_imm : ID_EX_reg_data2), alu_result);
            //$display("ALU Operation: Ctrl=%b | A=%h | B=%h | Result=%h", alu_unit.alu_ctrl, alu_unit.a, alu_unit.b, alu_unit.result);

            // Compare ALU result at the correct pipeline stage
            // if (cycle >= 4) begin  // Adjust this delay based on the pipeline stages
            //     if (result_queue[4] !== expected_result[cycle - 4]) begin
            //         $display("❌ ALU Mismatch: Expected %h, Got %h", expected_result[cycle - 4], result_queue[4]);
            //     end else begin
            //         $display("✅ ALU Calculation Correct!");
            //     end
            // end

            // ALU Result Comparison
            if (alu_ready) begin
                if (alu_result !== expected_result) begin
                    $display("❌ ALU Mismatch: Expected %h, Got %h", expected_result, alu_result);
                end else begin
                    $display("✅ ALU Calculation Correct!");
                end
            end

            // === MEMORY STAGE ===
            $display("\n==== MEMORY ====");
            if (EX_MEM_mem_write) begin
                $display("📝 Memory Write: Addr %h = %h", EX_MEM_alu_result, EX_MEM_reg_data2);
            end
            if (EX_MEM_mem_read) begin
                $display("📖 Memory Read: Addr %h -> %h", EX_MEM_alu_result, mem_data);
            end

            // === WRITEBACK STAGE ===
            $display("\n==== WRITEBACK ====");
            if (MEM_WB_reg_write) begin
                $display("✅ Register Write: x%0d = %h", MEM_WB_rd, registers.registers[MEM_WB_rd]);
            end

            $display("=================================================================================\n");
        end
    end
endmodule
