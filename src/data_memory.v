module data_memory (
    input  wire        clk,
    input  wire        reset_n,       // Reset memory to zero (clears data memory)
    input  wire        debug,         // Debug enable
    input  wire        mem_write,     // Memory Write Enable
    input  wire        mem_read,      // Memory Read Enable
    input  wire [31:0] data_addr,     // Memory Address
    input  wire [31:0] write_data,    // Data to Write
    output reg  [31:0] read_data      // Data Read from Memory
);

    // === MEMORY ARRAYS === 
    reg [31:0] data_mem  [0:31];      // Data Memory (RAM)

    integer i, j;


    // === DATA MEMORY INITIALIZATION ===
    initial begin
        for (j = 0; j < 32; j = j + 1) begin
            data_mem[j] = 32'b0;
        end
    end

    // === MAIN LOGIC ===
    always @(posedge clk or negedge reset_n) begin
        // Reset Memory
        if (!reset_n) begin 
            for (i = 0; i < 32; i = i + 1) begin
                data_mem[i] <= 32'b0;
            end
        end 
        // Write Memory
        else if (mem_write) begin
            data_mem[data_addr >> 2] <= write_data;
        end 
        // Read Memory
        else if (mem_read) begin
            read_data = data_mem[data_addr >> 2];
        end else begin
            read_data = 32'b0;
        end 
    end

    // // === RESET HANDLING (CLEAR DATA MEMORY) ===
    // always @(negedge reset_n) begin
    //     for (i = 0; i < 32; i = i + 1) begin
    //         data_mem[i] <= 32'b0;
    //     end
    // end

    
    // // === DATA MEMORY WRITE (RAM) ===
    // always @(posedge clk) begin
    //     if (mem_write) begin
    //         data_mem[data_addr >> 2] <= write_data;
    //         if (debug) 
    //             $display("📝 Memory Write: Addr %h = %h", data_addr, write_data);
    //     end
    // end

    
    // // === DATA MEMORY READ (RAM) ===
    // always @(posedge clk) begin
    //     if (mem_read) begin
    //         read_data = data_mem[data_addr >> 2];
    //         if (debug) 
    //             $display("📖 Memory Read: Addr %h -> %h", data_addr, read_data);
    //     end else begin
    //         read_data = 32'b0;
    //     end
    // end
endmodule


