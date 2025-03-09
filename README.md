# RISC-V CPU Project

## Overview
This project implements a 32-bit RISC-V CPU in Verilog. It is designed to support a subset of the RISC-V instruction set and is intended for educational purposes, particularly for students in Integrated Electronics Systems Engineering.

## Features

- **RISC-V ISA Support**: Implements a subset of the RV32I base instruction set, including arithmetic, memory, and control instructions.
- **5-Stage Pipeline**: 
   - **Fetch**: Fetches instructions from program memory.
   - **Decode**: Decodes instructions and reads registers.
   - **Execute**: Performs ALU operations.
   - **Memory**: Accesses data memory for load/store operations.
   - **Writeback**: Writes results back to registers.
- **Modular Design**: Each component (ALU, control unit, register file, etc.) is implemented as a separate module for clarity and reusability.
- **Testbenches**: Includes testbenches for each module and the full CPU to verify functionality.
- **FPGA Synthesis**: The design is synthesis-ready and can be implemented on an FPGA using tools like Yosys and NextPNR.

## Getting Started

To get started with the project, follow these steps:

1. **Clone the Repository**
      ```bash
      git clone https://github.com/Adebayo17/riscv_cpu.git
      cd riscv-cpu
      ```

2. **Install Dependencies**
      Ensure you have the required tools installed:
      - Icarus Verilog (`iverilog`)
      - GTKWave
      - Yosys
      - NextPNR
      - Python

      On Ubuntu/Debian, you can install them using:
      ```bash
      sudo apt update
      sudo apt install iverilog gtkwave yosys nextpnr-ice40 python3
      ```

3. **Compile and Simulate**
      ```bash
      make compile
      make simulate
      make wave
      ```

## Directory Structure

- `src/`: Verilog source files for the CPU modules.
- `sim/`: Testbenches and simulation scripts.
- `asm/`: Assembly programs for testing.
- `programs/`: Stores assembly programs in hexadecimal format.
- `synth/`: Output files for FPGA synthesis.
- `wave/`: Waveform files for debugging.
- `docs/`: Project documentation.

## Documentation

For detailed information, refer to the documentation files in the `docs/` directory:

- [1. Project Overview](docs/1_overview.md)
- [2. Getting Started](docs/2_getting_started.md)
- [3. CPU Architecture](docs/3_cpu_architecture.md)
- [4. Instruction Set](docs/4_instruction_set.md)
- [5. Simulation and Testing](docs/5_simulation_testing.md)
- [6. FPGA Synthesis](docs/6_fpga_synthesis.md)

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License.