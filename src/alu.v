module alu (
    input  wire [31:0] a,                   // Operand A
    input  wire [31:0] b,                   // Operand B
    input  wire [3:0]  alu_ctrl,            // ALU Control Signal
    output reg  [31:0] result,              // ALU Output
    output wire        zero,                // Zero flag (1 if result==0)
    output reg         alu_ready
);

    always @(*) begin
        alu_ready = 0;
        case (alu_ctrl)
            4'b0000:    result = a + b;                                         // ADD 
            4'b0001:    result = $signed(a) - $signed(b);                       // SUB 
            4'b0010:    result = a & b;                                         // AND 
            4'b0011:    result = a | b;                                         // OR 
            4'b0100:    result = a ^ b;                                         // XOR 
            4'b0101:    result = a << b;                                        // SLL (Shift Left Logical)
            4'b0110:    result = a >> b;                                        // SRL (Shift Right Logical)
            4'b0111:    result = $signed(a) >>> b;                              // SRA (Shift Right Arithmetic)
            4'b1000:    result = a * b;                                         // MUL
            // 4'b1001:    result = (b != 0) ? $signed(a) / $signed(b) : 32'b0;    // DIV (signed)
            // 4'b1010:    result = (b != 0) ? $signed(a) % $signed(b) : 32'b0;    // REM (signed)
            // 4'b1011:    result = (b != 0) ? a / b : 32'b0;                      // DIVU (unsigned)
            // 4'b1100:    result = (b != 0) ? a % b : 32'b0;                      // REMU (unsigned)
            default:    result = 32'b0;                                         // Default case 
        endcase
        alu_ready = 1;
    end

    assign zero = (result == 32'b0) ? 1 : 0;                                    // Set zero flag
endmodule



// module alu (
//     input  wire        clk,                 // Clock signal for pipelining
//     input  wire        enable,              // ALU Enable Signal (Active when in EX stage)
//     input  wire [31:0] a,                   // Operand A
//     input  wire [31:0] b,                   // Operand B
//     input  wire [3:0]  alu_ctrl,            // ALU Control Signal
//     output reg  [31:0] result,              // ALU Output
//     output wire        zero,                // Zero flag (1 if result==0)
//     output reg         alu_ready
// );
    
//     integer alu_log;
    
//     initial begin
//         alu_log = $fopen("sim_out/alu_results.log", "w"); // Open file for writing
//         if (alu_log == 0) begin
//             $display("❌ ERROR: Unable to open sim_out/alu_results.log for writing!");
//             $finish;
//         end
//     end

//     // initial begin
//     //     result = 32'b0;
//     // end

//     always @(*) begin
//         if (enable && a != 32'hxxxxxxxx && b != 32'hxxxxxxxx) begin
//             case (alu_ctrl)
//                 4'b0000:    result = a + b;                                         // ADD 
//                 4'b0001:    result = $signed(a) - $signed(b);                       // SUB 
//                 4'b0010:    result = a & b;                                         // AND 
//                 4'b0011:    result = a | b;                                         // OR 
//                 4'b0100:    result = a ^ b;                                         // XOR 
//                 4'b0101:    result = a << b;                                        // SLL (Shift Left Logical)
//                 4'b0110:    result = a >> b;                                        // SRL (Shift Right Logical)
//                 4'b0111:    result = $signed(a) >>> b;                              // SRA (Shift Right Arithmetic)
//                 4'b1000:    result = a * b;                                         // MUL
//                 4'b1001:    result = (b != 0) ? $signed(a) / $signed(b) : 32'b0;    // DIV (signed)
//                 4'b1010:    result = (b != 0) ? $signed(a) % $signed(b) : 32'b0;    // REM (signed)
//                 4'b1011:    result = (b != 0) ? a / b : 32'b0;                      // DIVU (unsigned)
//                 4'b1100:    result = (b != 0) ? a % b : 32'b0;                      // REMU (unsigned)
//                 default:    result = 32'b0;                                         // Default case 
//             endcase
//             alu_ready = 1'b1;   // ALU is ready when computation is done

//             // Log the operation
//             $fdisplay(alu_log, "%h %h %h %h", alu_ctrl, a, b, result);
//         end else begin
//             result = 32'b0;
//             alu_ready = 1'b0;   // ALU is not ready if not in EX stage
//         end
//     end

//     assign zero = (result == 32'b0) ? 1 : 0;                                    // Set zero flag
// endmodule