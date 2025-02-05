`timescale 1ns/1ps

module alu_tb;
    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire zero;

    alu uut (
        .a          (a)         ,
        .b          (b)         ,
        .alu_ctrl   (alu_ctrl)  ,
        .result     (result)    ,
        .zero       (zero)
    );

    initial begin
        // Test ADD
        a = 32'd10;
        b = 32'd5;
        alu_ctrl = 4'b0000;
        #10;
        $display("ADD: %d + %d = %d", a, b, result);

        // Test SUB
        a = 32'd10;
        b = 32'd5;
        alu_ctrl = 4'b0001;
        #10;
        $display("SUB: %d - %d = %d", a, b, result);

        // Test AND
        a = 32'b1010;
        b = 32'b1100;
        alu_ctrl = 4'b0010;
        #10;
        $display("AND: %b & %b = %b", a, b, result);

        // Test OR
        a = 32'b1010;
        b = 32'b1100;
        alu_ctrl = 4'b0011;
        #10;
        $display("OR:  %b | %b = %b", a, b, result);

        // Test XOR
        a = 32'b1010;
        b = 32'b1100;
        alu_ctrl = 4'b0100;
        #10;
        $display("XOR: %b ^ %b = %b", a, b, result);

        $finish;
    end
endmodule