module datapath (
    input  wire clk, reset,          // Clock and reset signals
    output wire [31:0] instr         // Instruction output (for debugging)
);

    reg  [31:0] pc, next_pc;                                  // Program Counter (PC)
    wire [31:0] reg_data1;                                    // Data signals
    wire [31:0] reg_data2;                                    // Data signals
    wire [31:0] alu_result;                                   // Data signals
    wire [31:0] mem_data;                                     // Data signals
    wire [6:0]  opcode;                                       // Extracted opcode
    wire [4:0]  rs1;                                          // Register addresse
    wire [4:0]  rs2;                                          // Register addresse
    wire [4:0]  rd;                                           // Register addresse
    wire [2:0]  funct3;                                       // Function code (funct3)
    wire [6:0]  funct7;                                       // Function code (funct7)
    wire [31:0] imm;                                          // Immediate value

    // Control signals
    wire reg_write;
    wire alu_src;
    wire mem_write;
    wire mem_read;
    wire mem_to_reg;
    wire branch;
    reg  [3:0] alu_ctrl;

    // Program Counter (PC) logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00000000;
        else
            pc <= next_pc;

            // Debug: Print executed instruction
            $display("PC: %h | Instruction: %h", pc, instr);
            $display("Reg x1: %h | Reg x2: %h | Reg x3: %h", registers.registers[1], registers.registers[2], registers.registers[3]);
            $display("---------------------------");
    end

    // Instruction Memory (simple ROM model)
    reg [31:0] instr_mem [0:31];
    initial begin
        $readmemh("sim/program.mem", instr_mem);    // Load program into memory
    end 
    assign instr = instr_mem[pc >> 2];          // Fetch instruction

    // Decode instruction fields
    decode decoder (
        .instr(instr),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm)
    );

    // Control Unit
    control ctrl_unit (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .branch(branch)
    );

    // Register File
    regfile registers (
        .clk(clk),
        .we(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(mem_to_reg ? mem_data : alu_result),
        .rd1(reg_data1),
        .rd2(reg_data2)
    );

    // ALU Control Unit (determines ALU operation based on funct3 and funct7)
    always @(*) begin
        case (funct3)
            3'b000: alu_ctrl = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000; // SUB or ADD
            3'b100: alu_ctrl = 4'b0100; // XOR
            3'b110: alu_ctrl = 4'b0011; // OR
            3'b111: alu_ctrl = 4'b0010; // AND
            default: alu_ctrl = 4'b0000; // Default to ADD
        endcase
    end

    // ALU
    alu alu_unit (
        .a(reg_data1),
        .b(alu_src ? imm : reg_data2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero()
    );

    // Data Memory
    reg [31:0] data_mem [0:31];  // Simple memory model
    always @(posedge clk) begin
        if (mem_write)
            data_mem[alu_result >> 2] <= reg_data2;
    end
    assign mem_data = mem_read ? data_mem[alu_result >> 2] : 32'b0;

    // PC Update Logic (Handles Jumps and Branches)
    always @(*) begin
        if (branch && alu_result == 0)
            next_pc = pc + (imm << 1);
        else
            next_pc = pc + 4;
    end
endmodule
