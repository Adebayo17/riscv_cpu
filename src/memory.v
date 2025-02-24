module memory (
    input  wire        clk,
    input  wire        reset,         // Reset memory to zero (clears data memory)

    // Instruction Memory Read Port
    input  wire [31:0] pc,            // PC address for instruction fetch
    output wire [31:0] instr_out,     // Instruction output

    // Data Memory Read/Write Ports
    input  wire        mem_write,     // Memory Write Enable
    input  wire        mem_read,      // Memory Read Enable
    input  wire [31:0] data_addr,     // Memory Address
    input  wire [31:0] write_data,    // Data to Write
    output reg  [31:0] read_data,     // Data Read from Memory

    input  wire        debug          // Debug enable
);

    // === MEMORY ARRAYS === 
    reg [31:0] data_mem  [0:31];  // Data Memory (RAM)
    reg [31:0] instr_mem [0:31];  // Instruction Memory (ROM)

    // === INSTRUCTION MEMORY INITIALIZATION ===
    initial begin
        $readmemh("sim/program.mem", instr_mem);        // Load Instructions from program.mem

        if (debug) begin
            $display("---------------------------------");
            $display("✅ Instruction Memory Loaded:");
            for (integer i = 0; i < 32; i = i + 1) begin
                $display("instr_mem[%0d] = %h", i, instr_mem[i]);
            end
            $display("---------------------------------");
            $display("");
        end
    end

    // === DATA MEMORY INITIALIZATION ===
    initial begin
        for (integer i = 0; i < 32; i = i + 1) begin
            data_mem[i] <= 32'b0;
        end
    end

    // === RESET HANDLING (CLEAR DATA MEMORY) ===
    always @(posedge reset) begin
        for (integer i = 0; i < 32; i = i + 1) begin
            data_mem[i] <= 32'b0;
        end
    end

    // === INSTRUCTION FETCH (ROM) ===
    assign instr_out = instr_mem[pc >> 2]; // Fetch instruction from memory

    // Handle Memory Writes (Data Memory)
    always @(posedge clk) begin
        if (mem_write) begin
            data_mem[data_addr >> 2] <= write_data;
            if (debug) $display("📝 Memory Write: Addr %h = %h", data_addr, write_data);
        end
    end

    // === DATA MEMORY WRITE (RAM) ===
    always @(posedge clk) begin
        if (mem_write) begin
            data_mem[data_addr >> 2] <= write_data;
            if (debug) 
                $display("📝 Memory Write: Addr %h = %h", data_addr, write_data);
        end
    end

    // === DATA MEMORY READ (RAM) ===
    always @(*) begin
        if (mem_read) begin
            read_data = data_mem[data_addr >> 2];
            if (debug) 
                $display("📖 Memory Read: Addr %h -> %h", data_addr, read_data);
        end else begin
            read_data = 32'b0;
        end
    end
endmodule


