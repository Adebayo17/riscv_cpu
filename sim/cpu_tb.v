`timescale 1ns / 1ps
module cpu_tb;
    
    // Inputs
    reg clk;
    reg reset_n;
    reg debug;

    cpu uut (
        .clk(clk),
        .reset_n(reset_n),
        .debug(debug)
    );

    // Clock Generation
    always #5 clk = ~clk;  

    initial begin
        $dumpfile("wave/cpu.vcd");     // Create waveform file
        $dumpvars(0, cpu_tb);           // Dump all signals
    end

    initial begin
        clk   = 0;
        reset_n = 0;
        debug = 1'b1;
        #20 reset_n = 1;

        #200;  // Run simulation for some time
        $finish;
    end

endmodule
