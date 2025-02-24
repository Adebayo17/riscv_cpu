module regfile (
    input  wire         clk,                // Clock
    input  wire         write_enable,       // Write Enable
    input  wire [4:0]   read_addr_1 ,       // Register Address Source 1
    input  wire [4:0]   read_addr_2 ,       // Register Address Source 2
    input  wire [4:0]   write_addr  ,       // Register Address Destination
    input  wire [31:0]  write_data  ,       // Write Data
    output wire [31:0]  read_data_1 ,       // Read Data 1
    output wire [31:0]  read_data_2         // Read Data 2
);

    reg [31:0] registers [31:0];

    initial begin
        for (integer i = 0; i < 32; i = i + 1) begin
            registers[i] = 0;
        end
    end

    always @(posedge clk) begin
        if (write_enable && write_addr != 5'b00000) begin
            registers[write_addr] <= write_data;
        end
    end

    // Read from registers
    assign read_data_1 = (read_addr_1 == 5'b00000) ? 32'b0 : registers[read_addr_1];
    assign read_data_2 = (read_addr_2 == 5'b00000) ? 32'b0 : registers[read_addr_2];

endmodule

// module regfile (
//     input  wire         clk,             // Clock
//     input  wire         we,              // Write Enable
//     input  wire [4:0]   rs1,             // Register Address Source 1
//     input  wire [4:0]   rs2,             // Register Address Source 2
//     input  wire [4:0]   rd,              // Register Address Destination
//     input  wire [31:0]  wd,              // Write Data
//     output wire [31:0]  rd1,             // Read Data 1
//     output wire [31:0]  rd2              // Read Data 2
// );

//     reg [31:0] registers [31:0];

//     initial begin
//         for (integer i = 0; i < 32; i = i+1 ) begin
//             registers[i] = 0;
//         end
//     end

//     always @(posedge clk) begin
//         if (we && rd != 5'b00000) begin
//             registers[rd] <= wd;
//         end
//     end

//     // Read from registers
//     assign rd1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
//     assign rd2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

// endmodule

// module regfile (
//     input wire clk,                     // Clock
//     input wire debug,
//     input wire we,                      // Write Enable
//     input wire [4:0]   rs1,             // Register Address Source 1
//     input wire [4:0]   rs2,             // Register Address Source 2
//     input wire [4:0]   rd,              // Register Address Destination
//     input wire [31:0]  wd,              // Write Data
//     output wire [31:0] rd1,             // Read Data 1
//     output wire [31:0] rd2              // Read Data 2
// );

//     reg [31:0] registers [31:0];

//     initial begin
//         for (integer i = 0; i < 32; i = i+1 ) begin
//             registers[i] = 0;
//         end

//         if (debug) begin
//             $display("---------------------------------");
//             $display("✅ Initialize registers to zero at reset:");
//             for (integer i = 0; i < 32; i = i+1 ) begin
//                 $display("x%0d = %h", i, registers[i]);
//             end
//             $display("---------------------------------");
//             $display("");
//         end
//     end

//     always @(posedge clk) begin
//         if (we && rd != 5'b00000) begin
//             if (debug) begin
//             //    $display("💾 Writing x%0d = %h (Previous: %h)", rd, wd, registers[rd]); // Debug print 
//             end
//             registers[rd] <= wd;
//         end
//     end

//     // Read from registers
//     assign rd1 = (rs1 == 5'b00000) ? 32'b0 : registers[rs1];
//     assign rd2 = (rs2 == 5'b00000) ? 32'b0 : registers[rs2];

// endmodule