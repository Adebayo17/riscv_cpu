`timescale 1ns / 1ps
module control_tb;
    reg [6:0] opcode;
    wire reg_write, alu_src, mem_write, mem_read, mem_to_reg, branch;

    control uut (
        .opcode     (opcode     ),
        .reg_write  (reg_write  ),
        .alu_src    (alu_src    ),
        .mem_write  (mem_write  ),
        .mem_read   (mem_read   ),
        .mem_to_reg (mem_to_reg ),
        .branch     (branch     )
    );

    initial begin
        // Test R-type instruction
        opcode = 7'b0110011; #10;
        $display("R-type: reg_write=%b, alu_src=%b", reg_write, alu_src);

        // Test I-type instruction
        opcode = 7'b0010011; #10;
        $display("I-type: reg_write=%b, alu_src=%b", reg_write, alu_src);

        // Test Load instruction (LW)
        opcode = 7'b0000011; #10;
        $display("LW: mem_read=%b, mem_to_reg=%b", mem_read, mem_to_reg);

        // Test Store instruction (SW)
        opcode = 7'b0100011; #10;
        $display("SW: mem_write=%b, alu_src=%b", mem_write, alu_src);

        // Test Branch instruction (BEQ)
        opcode = 7'b1100011; #10;
        $display("BEQ: branch=%b", branch);

        $finish;
    end
endmodule
