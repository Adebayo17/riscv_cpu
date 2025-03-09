# 6. FPGA Synthesis

This section explains how to synthesize the RISC-V CPU design for an FPGA using **Yosys**. It covers the synthesis flow, generating the synthesized design, and visualizing the results.

---

## Synthesis Flow

The synthesis process involves converting the Verilog design into a format suitable for FPGA implementation. The following tools are used:

- **Yosys**: For synthesizing the Verilog design.
- **netlistsvg**: For visualizing the synthesized design.

### Step 1: Synthesize the Design
To synthesize the design, use the following command:

```bash
make synth MODULE=cpu
```

This will:

1. Read the Verilog source files.

2. Synthesize the design using Yosys.

3. Generate a JSON file (`synth/cpu.json`) and a BLIF file (`synth/cpu.blif`).

### Step 2: Visualize the Synthesized Design

After synthesis, you can generate a visual representation of the design using **netlistsvg**. This tool converts the JSON output from Yosys into an SVG file.

#### Step 1: Install netlistsvg

If you don't already have netlistsvg installed, you can install it using npm:

```bash
npm install -g netlistsvg
```

#### Step 2: Generate SVG

To generate an SVG file, use the following command:

```bash
netlistsvg synth/cpu.json -o synth/cpu.svg
```

This will create an SVG file (`synth/cpu.svg`) that you can open in a web browser or image viewer to visualize the design.

### Example Synthesis Output

The synthesized design will include the following components:

- **ALU**: Arithmetic Logic Unit.
- **Register File**: Contains 32 general-purpose registers.
- **Control Unit**: Generates control signals for the CPU.
- **Data Memory**: Stores data for load/store operations.
- **Program Memory**: Stores instructions for execution.

### Debugging Synthesis Issues

#### Common Issues

- **Unconnected Signals**:
    - Ensure all signals in the Verilog design are properly connected.
    - Check for warnings in the Yosys synthesis log.

- **Resource Overuse**:
    - Check if the design exceeds the FPGA's resources (e.g., LUTs, flip-flops).
    - Optimize the design to reduce resource usage.

#### Debugging Tools

- **Yosys Log**: Check the synthesis log for warnings and errors.
- **GTKWave**: Use simulation to verify the design before synthesis.
