# 2. Getting Started

This section provides step-by-step instructions for setting up the RISC-V CPU project. It covers the prerequisites, installation process, and an overview of the project's directory structure.

---

## Prerequisites
Before getting started, ensure you have the following tools installed on your system:

### Tools
- **Icarus Verilog (`iverilog`)**: For compiling and simulating Verilog code.
- **GTKWave**: For viewing waveform files generated during simulation.
- **Yosys**: For synthesizing the Verilog design for FPGA.
- **NextPNR**: For place and route on FPGAs.
- **Python**: Optional, for running test scripts or automation.

### Installation on Ubuntu/Debian
You can install the required tools using the following commands:

```bash
sudo apt update
sudo apt install iverilog gtkwave yosys nextpnr-ice40 python3
```

---

## Installation
Follow these steps to set up the project on your local machine:

1. **Clone the Repository**
    ```bash
    git clone https://github.com/Adebayo17/riscv_cpu.git
    cd riscv-cpu
    ```

2. **Verify Dependencies**
Ensure all tools are installed correctly by running:
    ```bash
    iverilog -v
    gtkwave -v
    yosys -V
    nextpnr-ice40 --version
    ```

3. **Set Up Test Programs**
The project includes pre-written assembly programs in the `programs/` directory. To select a specific program for simulation, use the `select_program` target in the Makefile:
    ```bash
    make select_program PROGRAM=1
    ```
This will copy `programs/program_1.mem` to `sim/program.mem` for simulation.

---

## Directory Structure
The project is organized into the following directories:

### Key Directories

-   **`asm/`**: Contains the assembly programs to test on the RISC-V

-   **`src/`**: Contains the Verilog source files for the CPU modules.
    -   **`alu.v`**: Arithmetic Logic Unit (ALU) implementation.
    -   **`control.v`**: Control unit for instruction decoding.
    -   **`datapath.v`**: Datapath module connecting all CPU components.
    -   **`decode.v`**: Instruction decoder.
    -   **`regfile.v`**: Register file implementation.
    -   **`data_memory.v`**: Data memory module.
    -   **`program_memory.v`**: Program memory module.
    -   **`cpu.v`**: Top-level CPU module.

-   **`sim/`**: Includes testbenches and simulation scripts.
    -   **`alu_tb.v`**: Testbench for the ALU.
    -   **`datapath_tb.v`**: Testbench for the Datapath.
    -   **`cpu_tb.v`**: Testbench for the full CPU.
    -   **`program.mem`**: Memory file containing the program to be executed.

-   **`programs/`**: Stores assembly programs for testing.
    -   **`program_0.mem`**, **`program_1.mem`**, etc.: Example programs in hexadecimal format.

-   **`synth/`**: Output files for FPGA synthesis.
    -   **`cpu.json`**, **`cpu.blif`**, **`cpu.asc`**: Synthesis outputs.
    -   **`cpu.svg`**: Visual representation of the synthesized design.

-   **`wave/`**: Waveform files for debugging.
    -   **`cpu.vcd`**: Waveform file generated during simulation.

-   **`docs/`**: Project documentation (this file is part of it).

---

## Running the Project
Once the project is set up, you can compile, simulate, and view waveforms using the provided Makefile.

### Compile and Simulate

1. Compile the Verilog Source files:
    ```bash
    make compile
    ```
2. Run the simulation (CPU):
    ```bash
    make simulate
    ```
    Or for one module (alu, decode, control, regfile, datapth, data_memory, program_memory, cpu)
    ```bash
    make sim_<MODULE_NAME>
    ```

3. View the waveforms in GTKWave:
    ```bash
    make wave
    ```

### FPGA Synthesis
To synthesize the design for an FPGA:

1. Run the synthesis:
    ```bash
    make synth MODULE=cpu
    ```
    Or
    ```bash
    make synth_<MODULE_NAME>
    ```

---

## Next Steps
- Learn about the CPU architecture in [CPU Architecture](3_cpu_architecture.md).
- Explore the supported RISC-V instructions in [Instruction Set](2_getting_started.md).
- Run simulations and test the CPU in [Simulation and Testing](5_simulation_testing.md).