# 5. Simulation and Testing

This section explains how to simulate and test the RISC-V CPU using the provided testbenches. It covers compiling the design, running simulations, and analyzing the results using GTKWave.

## Running Simulations

### Compile the Design
To compile the Verilog source files and testbenches, use the following command:

```bash
make compile
```

This will generate a simulation binary file in the `sim_out/` directory (e.g., `cpu_tb.out`).

### Run the simulation
To run the simulation, use the following command:

```bash
make simulate
```

This will execute the testbench and generate a waveform file (`cpu.vcd`) in the `wave/` directory.

### View Waveforms
To view the waveforms in GTKWave, use the following command:

```bash
make wave
```

This will open GTKWave and load the `cpu.vcd` file for analysis.

---

## Writing and Assembling Programs

### Writing Assembly Programs
Assembly programs are written in `.s` files and stored in the `asm/` directory. Each program should include RISC-V instructions and comments for clarity.

Example Program (`asm/program_0.s`):
```assembly
# Example RISC-V Assembly Program
_start:
    addi x1, x0, 1      # x1 = 1
    addi x2, x0, 2      # x2 = 2
    add x3, x1, x2      # x3 = x1 + x2 (3)
    sw x3, 0(x0)        # Store x3 at memory address 0
    lw x4, 0(x0)        # Load x4 from memory address 0
    beq x4, x3, _start  # Branch to _start if x4 == x3
```

### Assembling Programs
To assemble an assembly program into machine code and generate the program.mem file, use the following command:
```bash
make select_program PROGRAM=1
```

This will:
1. Assemble the program (`asm/program_1.s`) into machine code.

2. Convert the machine code into the `programs/program_1.mem` format.

3. Copy the `programs/program_1.mem` file to the `sim/` directory as `program.mem` file for simulation.

---

## Testbenches

The project includes testbenches for each module and the full CPU:

### Module Testbenches
- **`alu_tb.v`**: Tests the Arithmetic Logic Unit (ALU).
- **`regfile_tb.v`**: Tests the Register File.
- **`control_tb.v`**: Tests the Control Unit.
- **`decode_tb.v`**: Tests the Instruction Decoder.
- **`data_memory_tb.v`**: Tests the Data Memory.
- **`program_memory_tb.v`**: Tests the Program Memory.

### Full CPU Testbench
- **`cpu_tb.v`**: Tests the full CPU with a sample program.

### Running Module Testbenches
To run a specific module testbench (except `datapath` and `cpu`), use the `MODULE` variable with the `sim` target. For example, to test the ALU:

```bash
make sim MODULE=alu
```

This will compile, simulate, and open the waveforms for the ALU testbench.

You can also use the following shorthand commands for convenience:

- ``make sim_alu``
- ``make sim_regfile``
- ``make sim_control``
- ``make sim_decode``
- ``make sim_data_memory``
- `make sim_program_memory`
- `make sim_datapath`
- `make sim_cpu`

---

## Analyzing Results

### Waveform Analysis
When you open the waveform file (`cpu.vcd`) in GTKWave, you can analyze the following signals:

- **`pc`**: Program Counter, showing the address of the current instruction.
- **`instr`**: The fetched instruction.
- **`regfile`**: Values of the registers in the register file.
- **`alu_result`**: Output of the ALU.
- **`mem_data`**: Data read from or written to memory.

### Expected Results
For the example program in `programs/program_1.mem`, you should see the following:

1. The Program Counter (`pc`) increments correctly.
2. The ALU performs the expected arithmetic operations.
3. The register file is updated with the correct results.
4. Data memory is accessed correctly for load/store operations.

### Debugging Tips
- If the simulation does not produce the expected results, check the following:
  - Ensure the test program (`program.mem`) is correctly loaded.
  - Verify that the control signals are generated correctly.
  - Check the ALU operations and register file updates.

### Running the Program
1. Write your assembly program in the `asm/` directory (e.g., `asm/program_1.s`).

2. Compile and simulate 
    ```bash
    make sim_cpu PROGRAM=1
    ```

This will generate a log file named `cpu_tb.log` in `sim_out/` directory.

---


## Next Steps
- Learn about the FPGA synthesis process in [FPGA Synthesis](6_fpga_synthesis.md).
- Explore the project's directory structure in [Getting Started](2_getting_started.md).