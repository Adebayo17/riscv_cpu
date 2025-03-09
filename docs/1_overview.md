# 1. Project Overview

## Introduction
This project implements a **32-bit RISC-V CPU** in Verilog. It is designed to support a subset of the RISC-V instruction set and is intended for **educational purposes**, particularly for students in **Integrated Electronics Systems Engineering**. The project serves as a practical application of digital design principles and provides a hands-on experience in building a CPU from scratch.

The CPU is modular, with separate components for the **ALU**, **control unit**, **register file**, **data memory**, and **program memory**. It also includes a **5-stage pipeline** to improve performance and demonstrate modern CPU design techniques.

---

## Purpose
The primary goals of this project are:
1. **Educational**: To provide a clear understanding of CPU architecture, RISC-V instruction set, and digital design principles.
2. **Practical**: To create a functional CPU that can execute RISC-V instructions and be synthesized for FPGA implementation.
3. **Modularity**: To design a modular system that can be easily extended or modified for future enhancements.

This project is particularly useful for:
- Students learning computer architecture and digital design.
- Engineers exploring RISC-V and FPGA-based systems.
- Hobbyists interested in building their own CPU.

---

## Features
The RISC-V CPU project includes the following features:
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

---

## Target Audience
This project is designed for:
- **Students**: Those studying computer architecture, digital design, or RISC-V.
- **Engineers**: Professionals exploring RISC-V or FPGA-based systems.
- **Hobbyists**: Individuals interested in building and understanding CPUs.

---

## Project Structure
The project is organized into the following directories:
- `src/`: Contains the Verilog source files for the CPU modules.
- `sim/`: Includes testbenches and simulation scripts.
- `programs/`: Stores assembly programs for testing.
- `synth/`: Output files for FPGA synthesis.
- `wave/`: Waveform files for debugging.
- `docs/`: Project documentation (this file is part of it).

---

## Next Steps
- Learn how to set up the project in [Getting Started](2_getting_started.md).
- Explore the CPU architecture in [CPU Architecture](3_cpu_architecture.md).
- Run simulations and test the CPU in [Simulation and Testing](5_simulation_testing.md).