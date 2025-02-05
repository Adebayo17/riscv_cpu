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

## **Register File Design**
### Register File Overview
-   32 registers (`x0` to `x31`)
-   2 read ports and 1 write port
-   Register `x0` is hardwired to 0

### Register File Module
-   Module name, Testbench module name : `regfile`, `regfile_tb`
-   Files : src and testbench : `src/regfile.v`, `sim/regfile_tb.v` 