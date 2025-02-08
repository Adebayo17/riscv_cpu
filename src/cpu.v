module cpu (
    input wire clk,
    input wire reset
);

    wire [31:0] instr;  // Instruction wire

    datapath dp (
        .clk(clk),
        .reset(reset),
        .instr(instr)
    );
endmodule
