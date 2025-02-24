module program_memory (
    input  wire        debug,         // Debug enable
    input  wire [31:0] pc,            // PC address for instruction fetch
    output wire [31:0] instr_out      // Instruction output
);

    // === MEMORY ARRAY === 
    reg [31:0] instr_mem [0:31];      // Instruction Memory (ROM)


    // === INSTRUCTION MEMORY INITIALIZATION ===
    initial begin
        // Explicitly initialize all memory locations to zero
        for (integer i = 0; i < 32; i = i + 1) begin
            instr_mem[i] = 32'b0;
        end

        // Load Instructions from program.mem
        $readmemh("sim/program.mem", instr_mem);        

        if (!debug) begin
            $display("---------------------------------");
            $display("✅ Instruction Memory Loaded:");
            for (integer i = 0; i < 32; i = i + 1) begin
                $display("instr_mem[%0d] = %h", i, instr_mem[i]);
            end
            $display("---------------------------------");
            $display("");
        end
    end


    // === INSTRUCTION FETCH (ROM) ===
    assign instr_out = (pc >> 2 < 32) ? instr_mem[pc >> 2] : 32'b0; // Fetch instruction from memory

    // === Debugging ===
    always @(*) begin
        // $display("🔍 (program_memory) Fetching Instruction at PC = %h -> instr_mem[%0d] = %h", pc, pc >> 2, instr_out);
    end
endmodule


