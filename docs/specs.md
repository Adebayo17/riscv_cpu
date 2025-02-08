# **CPU Overview**
-   **Architecture** : RISC-V RV32I (32-bit Integer)
-   **Pipeline Stages**:
    1.  **Fetch       (IF)**    - Fetch instruction from memory
    2.  **Decode      (ID)**    - Decode instruction & read registers
    3.  **Execute     (EX)**    - Perform ALU operations
    4.  **Memory      (MEM)**   - Read/Write from data memory
    5.  **Write Back  (WB)**    - Write results to registers

-   **Supported Instructions (RV32I Subset)**

    | Instruction       | Operation                 |
    |---                |:-:                        |
    |  `ADD`            | Rd = Rs1 + Rs2            |
    |  `SUB`            | Rd = Rs1 - Rs2            |
    |  `AND`            | Rd = Rs1 & Rs2            |
    |  `OR`             | Rd = Rs1 \| Rs2           |
    |  `XOR`            | Rd = Rs1 ^ Rs2            |
    |  `LW`             | Load word from memory     |
    |  `SW`             | Store word to memory      |
    |  `BEQ`            | Branch if equam           |

---

## **ALU Design**
### ALU Overview
The ALU will support the following RV32I instructions:

| Instruction       | Operation                 | ALU Control   |
|---                |:-:                        |:-:            |
|  `ADD`            | Rd = Rs1 + Rs2            | 0000          |
|  `SUB`            | Rd = Rs1 - Rs2            | 0001          |
|  `AND`            | Rd = Rs1 & Rs2            | 0010          |
|  `OR`             | Rd = Rs1 \| Rs2           | 0011          |
|  `XOR`            | Rd = Rs1 ^ Rs2            | 0100          |

### ALU Module
-   Module name, Testbench module name : `alu`, `alu_tb`
-   Files : src and testbench : `src/alu.v`, `sim/alu_tb.v` 
-   Module Ports :

| Name          | Type                 | Description                    |
|---            |:-                    |:-                              |
|  `a`          | input  wire [31:0]   | First Operand                  |
|  `b`          | input  wire [31:0]   | Second Operand                 |
|  `alu_ctrl`   | input  wire [3:0]    | Select the ALU operation       |
|  `result`     | output reg  [31:0]   | Result of the operation        |
|  `zero`       | output wire          | Flag set to 1 if result==0     |

## **Register File Design**
### Register File Overview
-   32 registers (`x0` to `x31`)
-   2 read ports and 1 write port
-   Register `x0` is hardwired to 0

### Register File Module
-   Module name, Testbench module name : `regfile`, `regfile_tb`
-   Files : src and testbench : `src/regfile.v`, `sim/regfile_tb.v` 
-   Module Ports :

| Name         | Type                 | Description                   |
|---           |:-                    |:-                             |
|  `clk`       | input  wire          | System Clock                  |
|  `we`        | input  wire          | Write Enable                  |
|  `rs1`       | input  wire [4:0]    | Register Address Source 1     |
|  `rs2`       | input  wire [4:0]    | Register Address Source 2     |
|  `rd`        | input  wire [4:0]    | Register Address Destination  |
|  `wd`        | input  wire [31:0]   | Write Data                    |
|  `rd1`       | output wire [31:0]   | Read Data 1                   |
|  `rd2`       | output wire [31:0]   | Read Data 2                   |


## **Control Unit Design**
### Control Unit Overview
-   ALU operation selection
-   Register File read/write
-   Memory read/write
-   Branch Control
-   List of `Opcode`

| Opcode                   | Type                                      | Desciption       |
|---                       |:-                                         |:-                |
|  `7'b0110011`            | R-type (ADD, SUB, AND, OR, XOR)           | *TO DO*          |
|  `7'b0010011`            | I-type (ADDI, ANDI, ORI, XORI)            | *TO DO*          |
|  `7'b0000011`            | Load (LW)                                 | *TO DO*          |
|  `7'b0100011`            | Store (SW)                                | *TO DO*          |
|  `7'b1100011`            | Branch (BEQ)                              | *TO DO*          |

### Control Unit Module
-   Module name, Testbench module name : `control`, `control_tb`
-   Files : src and testbench : `src/control.v`, `sim/control_tb.v`
-   Module Ports :

| Name             | Type                | Description                                          |
|---               |:-                   |:-                                                    |
|  `opcode`        | input  wire [6:0]   | Opcode field of instruction                          |
|  `reg_write`     | output reg          | Enable register write                                |
|  `alu_src`       | output reg          | ALU source select (1 for immediate, 0 for register)  |
|  `mem_write`     | output reg          | Enable memory write                                  |
|  `mem_read`      | output reg          | Enable memory read                                   |
|  `mem_to_reg`    | output reg          | Select memory data for register write                |
|  `branch`        | output reg          | Branch control signal                                |



## **Instruction Decode (ID) Unit Design**
### Instruction Decode (ID) Unit Overview
The Instruction Decode Unit extracts fields from a 32-bit instruction:
-   **Opcode** (7 bits)
-   **Register addresses (rs1, rs2, rd)** (5 bits each)
-   **Function code (funct3, funct7)**
-   **Immediate values (for I, S, B-type instructions)**


### Instruction Decode (ID) Unit Module
-   Module name, Testbench module name : `decode`, `decode_tb`
-   Files : src and testbench : `src/decode.v`, `sim/decode_tb.v`
-   Module Ports :

| Name        | Type                 | Description                          |
|---          |:-                    |:-                                    |
|  `instr`    | input  wire [31:0]   | Full 32-bit instruction              |
|  `opcode`   | output wire [6:0]    | Opcode                               |
|  `rs1`      | output wire [4:0]    | Register addresse                    |
|  `rs2`      | output wire [4:0]    | Register addresse                    |
|  `rd`       | output wire [4:0]    | Register addresse                    |
|  `funct3`   | output wire [2:0]    | Function field (R/I/S-type)          |
|  `funct7`   | output wire [6:0]    | Function field (R-type)              |
|  `imm`      | output wire [31:0]   | Immediate value (for I, S, B-type)   |



## **Datapath Design Design**
### Datapath Design Overview
The datapath consists of the following components:
-   **Instruction Fetch** – Fetches instructions from memory
-   **Instruction Decode** – Decodes instructions and provides control signals
-   **Register File** – Reads and writes register values
-   **ALU** – Performs arithmetic and logical operations
-   **Memory Access** – Handles `LW` and `SW` operations
-   **PC Update Logic** – Updates the program counter (`PC`)


### Datapath Design Module
-   Module name: `datapath`
-   Source File: `src/datapath.v`
-   Module Ports:

| Name        | Type                | Description                          |
|---          |:-                   |:-                                    |
|  `clk`      | input  wire         | System Clock                         |
|  `reset`    | input  wire         | System Reset Signal                  |
|  `instr`    | output wire [31:0]  | Instruction output (for debugging)   |

