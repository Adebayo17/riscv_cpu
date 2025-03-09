# RISC-V CPU Project

## Overview
This project implements a 32-bit RISC-V CPU in Verilog. It is designed to support a subset of the RISC-V instruction set and is intended for educational purposes, particularly for students in Integrated Electronics Systems Engineering.

### Features
- Supports RV32I base instruction set.
- 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback).
- Modular design with separate ALU, control unit, and memory modules.
- Testbenches for each module and full CPU simulation.
- FPGA synthesis-ready design.

## Getting Started

### Prerequisites
- **Icarus Verilog (`iverilog`)**: For simulation.
- **GTKWave**: For viewing waveforms.
- **Yosys**: For FPGA synthesis.
- **NextPNR**: For place and route.
- **Python**: Optional, for running test scripts.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Adebayo17/riscv_cpu.git
   cd riscv-cpu
   ```

2. Install dependencies:
    ```bash
   sudo apt install iverilog gtkwave yosys nextpnr-ice40
   ```

3. Directory Structure
    ```
    src/        - Contains Verilog source files for the CPU modules.
    sim/        - Includes testbenches and simulation scripts.
    programs/   - Stores assembly programs for testing.
    synth/      - Output files for FPGA synthesis.
    wave/       - Waveform files for debugging.
    docs/       - Project documentation.
    ```