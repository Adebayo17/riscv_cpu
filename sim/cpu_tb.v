`timescale 1ns / 1ps
module cpu_tb;
    reg clk, reset;

    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock Generation
    always #5 clk = ~clk;  

    initial begin
        clk = 0;
        reset = 1;
        #10 reset = 0;

        #200;  // Run simulation for some time
        $finish;
    end
endmodule
