module datapath (
    input  wire clk,                // Clock signal
    input  wire reset_n,            // Asynchronous reset (active low)
    input  wire debug,
    output wire [31:0] instr        // Instruction output (for debugging)
);
    
    // === PARAMETERS ===
    localparam R_TYPE_OPCODE = 7'b0110011;
    localparam I_TYPE_OPCODE = 7'b0010011;
    localparam LOAD_OPCODE   = 7'b0000011;
    localparam STORE_OPCODE  = 7'b0100011;
    localparam BRANCH_OPCODE = 7'b1100011;
    localparam JAL_OPCODE    = 7'b1101111;
    localparam JALR_OPCODE   = 7'b1100111;
    
    // === WIRES ===
    // Instance wires: program_memory0
    wire [31:0] program_memory0__instr_out;

    // Instance wires: decoder
    wire [31:0] decoder__instr  ;
    wire [6:0]  decoder__opcode ;
    wire [4:0]  decoder__rs1    ;
    wire [4:0]  decoder__rs2    ;
    wire [4:0]  decoder__rd     ;
    wire [2:0]  decoder__funct3 ;
    wire [6:0]  decoder__funct7 ;
    wire [31:0] decoder__imm    ;

    // Instance wires: ctrl_unit
    wire [6:0]  ctrl_unit__opcode     ;
    wire        ctrl_unit__reg_write  ;
    wire        ctrl_unit__alu_src    ;
    wire        ctrl_unit__mem_write  ;
    wire        ctrl_unit__mem_read   ;
    wire        ctrl_unit__mem_to_reg ;
    wire        ctrl_unit__branch     ;
    wire        ctrl_unit__jump       ;

    // Instance wires: registers
    wire        registers__write_enable ;
    wire [4:0]  registers__read_addr_1  ;
    wire [4:0]  registers__read_addr_2  ;
    wire [4:0]  registers__write_addr   ;
    wire [31:0] registers__write_data   ;
    wire [31:0] registers__read_data_1  ;
    wire [31:0] registers__read_data_2  ;

    reg  [3:0]  alu_ctrl_calculated;

    // Instance wires: alu_unit
    wire [31:0] alu_unit__a        ;
    wire [31:0] alu_unit__b        ;
    wire [3:0]  alu_unit__alu_ctrl ;
    wire [31:0] alu_unit__result   ;
    wire        alu_unit__zero     ;
    wire        alu_unit__alu_ready;

    // Instance wires: data_memory
    wire        data_memory0__mem_write   ;
    wire        data_memory0__mem_read    ;
    wire [31:0] data_memory0__data_addr   ;
    wire [31:0] data_memory0__write_data  ;
    wire [31:0] data_memory0__read_data   ;


    // === PROGRAM COUNTER ===
    reg  [31:0] pc, next_pc;

    // === PIPELINE REGISTERS ===
    // IF to ID
    reg  [31:0] IF_to_ID_instr;

    // ID to EX
    reg  [31:0] ID_to_EX_read_data_1;
    reg  [31:0] ID_to_EX_read_data_2;
    reg  [31:0] ID_to_EX_imm;
    reg  [4:0]  ID_to_EX_rd;
    reg  [3:0]  ID_to_EX_alu_ctrl;
    reg         ID_to_EX_alu_src;
    reg         ID_to_EX_alu_ready;
    reg         ID_to_EX_branch;
    reg         ID_to_EX_jump;
    reg         ID_to_EX_mem_read;
    reg         ID_to_EX_mem_write;
    reg         ID_to_EX_reg_write;
    reg         ID_to_EX_mem_to_reg;

    // EX to MEM
    reg  [31:0] EX_to_MEM_alu_result;
    reg  [31:0] EX_to_MEM_read_data_2;
    reg  [4:0]  EX_to_MEM_rd;
    reg         EX_to_MEM_mem_read;
    reg         EX_to_MEM_mem_write;
    reg         EX_to_MEM_reg_write;
    reg         EX_to_MEM_mem_to_reg;

    // MEM to WB
    reg  [31:0] MEM_to_WB_alu_result;
    reg  [31:0] MEM_to_WB_mem_data;
    reg  [4:0]  MEM_to_WB_rd;
    reg         MEM_to_WB_reg_write;
    reg         MEM_to_WB_mem_to_reg;


    // ==============================
    // === INSTRUCTION FETCH (IF) ===
    // ==============================
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc <= 32'h00000000;
        end else begin
            // $display("🔍 (datapath) PC Update: Previous PC = %h → Next PC = %h", pc, next_pc);
            pc <= next_pc;
        end
    end 

    program_memory program_memory0 (
        .debug              (debug                          ),
        .pc                 (pc                             ),  // Pass PC for instruction fetch
        .instr_out          (program_memory0__instr_out     )   // Fetch instruction
    );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            IF_to_ID_instr  <= 0;
        end else begin
            //$display("🔍 (datapth) IF/ID Pipeline: Storing instr = %h (PC = %h)", program_memory0__instr_out, pc);
            IF_to_ID_instr  <= program_memory0__instr_out;
        end
    end

    // Datapath instruction output
    assign instr = program_memory0__instr_out;


    // ===============================
    // === INSTRUCTION DECODE (ID) ===
    // ===============================

    assign decoder__instr = IF_to_ID_instr;

    decode decoder (
        .instr              (decoder__instr     ),
        .opcode             (decoder__opcode    ),
        .rs1                (decoder__rs1       ),
        .rs2                (decoder__rs2       ),
        .rd                 (decoder__rd        ),
        .funct3             (decoder__funct3    ),
        .funct7             (decoder__funct7    ),
        .imm                (decoder__imm       )
    );

    control ctrl_unit (
        .opcode             (ctrl_unit__opcode      ),
        .reg_write          (ctrl_unit__reg_write   ),
        .alu_src            (ctrl_unit__alu_src     ),
        .mem_write          (ctrl_unit__mem_write   ),
        .mem_read           (ctrl_unit__mem_read    ),
        .mem_to_reg         (ctrl_unit__mem_to_reg  ),
        .branch             (ctrl_unit__branch      ),
        .jump               (ctrl_unit__jump        )
    );


    regfile registers (
        .clk                (clk            ),
        .write_enable       (registers__write_enable ),
        .read_addr_1        (registers__read_addr_1  ),
        .read_addr_2        (registers__read_addr_2  ),
        .write_addr         (registers__write_addr   ),
        .write_data         (registers__write_data   ),
        .read_data_1        (registers__read_data_1  ),
        .read_data_2        (registers__read_data_2  )
    );

    assign ctrl_unit__opcode        = decoder__opcode;
    assign registers__read_addr_1   = decoder__rs1;
    assign registers__read_addr_2   = decoder__rs2;

    // TO COMPLETE
    always @(*) begin
        case ({decoder__opcode, decoder__funct7, decoder__funct3})
            // R-type instructions
            {R_TYPE_OPCODE, 7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0000; // ADD
            {R_TYPE_OPCODE, 7'b0100000, 3'b000}: alu_ctrl_calculated = 4'b0001; // SUB
            {R_TYPE_OPCODE, 7'b0000000, 3'b111}: alu_ctrl_calculated = 4'b0010; // AND
            {R_TYPE_OPCODE, 7'b0000000, 3'b110}: alu_ctrl_calculated = 4'b0011; // OR
            {R_TYPE_OPCODE, 7'b0000000, 3'b100}: alu_ctrl_calculated = 4'b0100; // XOR
            {R_TYPE_OPCODE, 7'b0000000, 3'b001}: alu_ctrl_calculated = 4'b0101; // SLL
            {R_TYPE_OPCODE, 7'b0000000, 3'b101}: alu_ctrl_calculated = 4'b0110; // SRL
            {R_TYPE_OPCODE, 7'b0100000, 3'b101}: alu_ctrl_calculated = 4'b0111; // SRA
            {R_TYPE_OPCODE, 7'b0000001, 3'b000}: alu_ctrl_calculated = 4'b1000; // MUL

            // I-type instructions
            {I_TYPE_OPCODE, 7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0000; // ADDI
            {I_TYPE_OPCODE, 7'b0000000, 3'b111}: alu_ctrl_calculated = 4'b0010; // ANDI
            {I_TYPE_OPCODE, 7'b0000000, 3'b110}: alu_ctrl_calculated = 4'b0011; // ORI
            {I_TYPE_OPCODE, 7'b0000000, 3'b100}: alu_ctrl_calculated = 4'b0100; // XORI
            {I_TYPE_OPCODE, 7'b0000000, 3'b001}: alu_ctrl_calculated = 4'b0101; // SLLI
            {I_TYPE_OPCODE, 7'b0000000, 3'b101}: alu_ctrl_calculated = 4'b0110; // SRLI
            {I_TYPE_OPCODE, 7'b0100000, 3'b101}: alu_ctrl_calculated = 4'b0111; // SRAI 

            // Load and Store instructions
            {LOAD_OPCODE,   7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0000; // LW (use ADD for address calculation)
            {STORE_OPCODE,  7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0000; // SW (use ADD for address calculation)

            // Branch instructions
            {BRANCH_OPCODE, 7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0001; // BEQ (use SUB for comparison)
            {BRANCH_OPCODE, 7'b0000000, 3'b001}: alu_ctrl_calculated = 4'b0001; // BNE (use SUB for comparison)
            {BRANCH_OPCODE, 7'b0000000, 3'b100}: alu_ctrl_calculated = 4'b0001; // BLT (use SUB for comparison)
            {BRANCH_OPCODE, 7'b0000000, 3'b101}: alu_ctrl_calculated = 4'b0001; // BGE (use SUB for comparison)
            {BRANCH_OPCODE, 7'b0000000, 3'b110}: alu_ctrl_calculated = 4'b0001; // BLTU (use SUB for comparison)
            {BRANCH_OPCODE, 7'b0000000, 3'b111}: alu_ctrl_calculated = 4'b0001; // BGEU (use SUB for comparison)

            // Jump instructions
            {JAL_OPCODE,    7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0000; // JAL (use ADD for address calculation)
            {JALR_OPCODE,   7'b0000000, 3'b000}: alu_ctrl_calculated = 4'b0000; // JALR (use ADD for address calculation)

            default: alu_ctrl_calculated = 4'b0000; // Default to ADD
        endcase
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ID_to_EX_rd          <= 0;
            ID_to_EX_imm         <= 0;

            ID_to_EX_read_data_1 <= 0;
            ID_to_EX_read_data_2 <= 0;

            ID_to_EX_alu_ctrl    <= 0;
            ID_to_EX_alu_src     <= 0;
            ID_to_EX_branch      <= 0;
            ID_to_EX_jump        <= 0;

            ID_to_EX_mem_read    <= 0;
            ID_to_EX_mem_write   <= 0;
            ID_to_EX_reg_write   <= 0;
            ID_to_EX_mem_to_reg  <= 0;
        end else begin
            ID_to_EX_rd          <= decoder__rd;
            ID_to_EX_imm         <= decoder__imm;
            ID_to_EX_read_data_1 <= registers__read_data_1;
            ID_to_EX_read_data_2 <= registers__read_data_2;
            ID_to_EX_alu_ctrl    <= alu_ctrl_calculated;
            ID_to_EX_alu_src     <= ctrl_unit__alu_src;
            ID_to_EX_branch      <= ctrl_unit__branch;
            ID_to_EX_jump        <= ctrl_unit__jump; 
            ID_to_EX_mem_read    <= ctrl_unit__mem_read;
            ID_to_EX_mem_write   <= ctrl_unit__mem_write;
            ID_to_EX_reg_write   <= ctrl_unit__reg_write;
            ID_to_EX_mem_to_reg  <= ctrl_unit__mem_to_reg;
        end
    end 



    // =======================
    // === EXECUTION (EX) ===
    // ======================

    assign alu_unit__a          = ID_to_EX_read_data_1;
    assign alu_unit__b          = (ID_to_EX_alu_src) ? ID_to_EX_imm : ID_to_EX_read_data_2;
    assign alu_unit__alu_ctrl   = ID_to_EX_alu_ctrl;

    // ALU Unit
    alu alu_unit (
        .a                  (alu_unit__a        ),
        .b                  (alu_unit__b        ),
        .alu_ctrl           (alu_unit__alu_ctrl ),
        .result             (alu_unit__result   ),
        .zero               (alu_unit__zero     ),
        .alu_ready          (alu_unit__alu_ready)
    );

    // Branch and Jump Logic
    always @(*) begin
        if (ID_to_EX_jump && (decoder__opcode == JALR_OPCODE)) begin
            // JALR: PC = rs1 + imm (with LSB set to 0)
            next_pc = (ID_to_EX_read_data_1 + ID_to_EX_imm) & ~32'b1;
        end else if (ID_to_EX_branch && alu_unit__zero) begin
            // Branch taken: PC = PC + imm
            next_pc = pc + ID_to_EX_imm;
        end else if (ID_to_EX_jump) begin
            // JAL: PC = PC + imm
            next_pc = pc + ID_to_EX_imm;
        end else begin
            // Default: PC = PC + 4
            next_pc = pc + 4;
        end
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            EX_to_MEM_alu_result    <= 0;
            EX_to_MEM_read_data_2   <= 0;
            EX_to_MEM_rd            <= 0;
            EX_to_MEM_mem_read      <= 0;
            EX_to_MEM_mem_write     <= 0;
            EX_to_MEM_reg_write     <= 0;
            EX_to_MEM_mem_to_reg    <= 0;
        end else begin
            EX_to_MEM_alu_result    <= alu_unit__result;
            EX_to_MEM_read_data_2   <= ID_to_EX_read_data_2;
            EX_to_MEM_rd            <= ID_to_EX_rd;
            EX_to_MEM_mem_read      <= ID_to_EX_mem_read;
            EX_to_MEM_mem_write     <= ID_to_EX_mem_write;
            EX_to_MEM_reg_write     <= ID_to_EX_reg_write;
            EX_to_MEM_mem_to_reg    <= ID_to_EX_mem_to_reg;
        end
    end

    // =====================
    // === MEMORY (MEM) ===
    // ====================

    assign data_memory0__mem_write  = EX_to_MEM_mem_write;
    assign data_memory0__mem_read   = EX_to_MEM_mem_read;
    assign data_memory0__data_addr  = EX_to_MEM_alu_result;
    assign data_memory0__write_data = EX_to_MEM_read_data_2;

    data_memory data_memory0 (
        .clk                (clk                        ),
        .reset_n            (reset_n                    ),
        .debug              (debug                      ),
        .mem_write          (data_memory0__mem_write    ),
        .mem_read           (data_memory0__mem_read     ),
        .data_addr          (data_memory0__data_addr    ),
        .write_data         (data_memory0__write_data   ),
        .read_data          (data_memory0__read_data    )
    );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            MEM_to_WB_alu_result   <= 0;
            MEM_to_WB_mem_data     <= 0;
            MEM_to_WB_rd           <= 0;
            MEM_to_WB_reg_write    <= 0;
            MEM_to_WB_mem_to_reg   <= 0;
        end else begin
            MEM_to_WB_alu_result   <= EX_to_MEM_alu_result;
            MEM_to_WB_mem_data     <= data_memory0__read_data;
            MEM_to_WB_rd           <= EX_to_MEM_rd;
            MEM_to_WB_reg_write    <= EX_to_MEM_reg_write;
            MEM_to_WB_mem_to_reg   <= EX_to_MEM_mem_to_reg;
        end
    end

    // ======================
    // === WRITEBACK (WB) ===
    // ======================

    // Writeback Mux
    assign registers__write_data    =   (MEM_to_WB_mem_to_reg) ? MEM_to_WB_mem_data : 
                                        (ID_to_EX_jump) ? (pc + 4) :  MEM_to_WB_alu_result;
    
    // Write to Register File
    assign registers__write_enable  = MEM_to_WB_reg_write;
    assign registers__write_addr    = MEM_to_WB_rd;

endmodule
