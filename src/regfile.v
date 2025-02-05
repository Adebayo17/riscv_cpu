module regfile (
    input wire clk,             // Clock
    input wire we,              // Write Enable
    input wire [4:0] rs1,       // Register Address Source 1
    input wire [4:0] rs2,       // Register Address Source 2
    input wire [4:0] rd,        // Register Address Destination
    input wire [31:0] wd,       // Write Data
    output wire [31:0] rd1,     // Read Data 1
    output wire [31:0] rd2      // Read Data 2
);

    reg [31:0] registers [31:0];

    always @(posedge clk) begin
        if (we && rd != 5'b00000) begin
            registers[rd] <= wd;
        end
    end

    assign rd1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
    assign rd2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

endmodule