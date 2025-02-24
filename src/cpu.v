module cpu (
    input wire clk,
    input wire reset_n,
    input wire debug
);

    wire [31:0] instr;  // Instruction wire

    datapath dp (
        .clk(clk),
        .reset_n(reset_n),
        .debug(debug),
        .instr(instr)
    );
endmodule
