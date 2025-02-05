`timescale 1ns / 1ps
module regfile_tb;
    reg clk;
    reg we;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [31:0] wd;
    wire [31:0] rd1;
    wire [31:0] rd2;

    regfile uut (
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    always #5 clk = ~clk;  // Clock toggle every 5 ns

    initial begin
        clk = 0; 
        we = 0;
        
        // Test Writing to Register 1
        rd = 5'd1; 
        wd = 32'd42; 
        we = 1;
        #10; 
        we = 0;  // Write complete

        // Test Reading from Register 1
        rs1 = 5'd1;
        #10;
        $display("Register 1 Read: %d (Expected: 42)", rd1);

        // Test Register x0 (should always be 0)
        rs1 = 5'd0;
        #10;
        $display("Register 0 Read: %d (Expected: 0)", rd1);

        $finish;
    end
endmodule
