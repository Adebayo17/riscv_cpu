# 4. Instruction Set

This section describes the RISC-V instruction set supported by the CPU. It includes details about the instruction types, encoding, and examples of how the instructions are used.

---

## Supported Instructions

The CPU supports a subset of the **RV32I base instruction set**, which includes the following types of instructions:

### Arithmetic Instructions
- **ADD**: Add two registers.
- **SUB**: Subtract one register from another.
- **ADDI**: Add an immediate value to a register.
- **SUBI**: Substract an immediate value to a register

### Logical Instructions
- **AND**: Bitwise AND of two registers.
- **OR**: Bitwise OR of two registers.
- **XOR**: Bitwise XOR of two registers.
- **ANDI**: Bitwise AND of an immediate value and a register.
- **ORI**: Bitwise OR of an immediate value and a register.
- **XORI**: Bitwise XOR of an immediate value and a register.

### Shift Instructions
- **SLL**: Shift left logical.
- **SRL**: Shift right logical.
- **SRA**: Shift right arithmetic.

### Memory Instructions
- **LW**: Load word from memory.
- **SW**: Store word to memory.

### Control Instructions
- **BEQ**: Branch if equal.
- **BNE**: Branch if not equal.
- **BLT**: Branch if less than
- **BGE**: Branch if greater or equal
- **BLTU**: Branch if less than for unsigned 
- **BGEU**: Branch if greater or equal for unsigned
- **JAL**: Jump and link.
- **JALR**: Jump and link register.


---

## Instruction Encoding

RISC-V instructions are 32-bit encoded and are categorized into multiple instruction formats.

### R-Type (Register-Type)
Used for arithmetic and logical operations between registers.

| 31:25 | 24:20 | 19:15 | 14:12 | 11:7 | 6:0   |
|-------|-------|-------|-------|------|-------|
| funct7| rs2   | rs1   | funct3| rd   | opcode|

- Example: `ADD x1, x2, x3`
    - &rarr; `x1 = x2 + x3` 
- Opcode: `0110011` (`R_TYPE_OPCODE`)


### I-Type (Immediate-Type)
Used for arithmetic operations with immediates, load instructions, and JALR (jump register).

| 31:20         | 19:15 | 14:12 | 11:7 | 6:0   |
|---------------|-------|-------|------|-------|
| imm[11:0]     | rs1   | funct3| rd   | opcode|

- Example (Arithmetic): `ADDI x1, x2, 10`
    - &rarr; `x1 = x2 + 10`

- Example (Load): `LW x1, 8(x2)`
    - &rarr; Load a 32-bit word from memory at `x2 + 8` into `x1`

- Example (Jump register): `JALR x1, x2, 0`
    - &rarr; Jump to `x2 + 0` and store return address in `x1`

- Opcodes:
    - Arithmetic Immediate: `0010011` (`I_TYPE_OPCODE`)
    - Load: `0000011` (`LOAD_OPCODE`)
    - JALR: `1100111` (`JALR_OPCODE`)


### S-Type (Store-Type)
Used for store instructions.

| 31:25 | 24:20 | 19:15 | 14:12 | 11:7  | 6:0   |
|-------|-------|-------|-------|-------|-------|
| imm[11:5]    | rs2   | rs1   | funct3| imm[4:0] | opcode|

- Example: `SW x1, 8(x2)`
    - &rarr; Store `x1` at memory address `x2 + 8` 
- Opcode: `0100011` (`STORE_OPCODE`)


### B-Type (Branch-Type)
Used for branch instructions.

| 31     | 30:25    | 24:20 | 19:15 | 14:12 | 11:8    | 7      | 6:0   |
|------- |----------|-------|-------|-------|---------|--------|-------|
| imm[12]|imm[10:5] | rs2   | rs1   | funct3| imm[4:1]|imm[11] | opcode|


- Example: `BEQ x1, x2, label`
    - &rarr; If `x1==x2`, branch to `label` 
- Opcode: `1100011` (`BRANCH_OPCODE`)

### J-Type (Jump-Type)
Used for jump instructions.

| 31     | 30:21    | 20     | 19:12     | 11:7   | 6:0   |
|------- |----------|--------|-----------|--------|-------|
| imm[20]|imm[10:1] |imm[11] | imm[19:12]| rd     | opcode|

- Example: `JAL x1, label`
    - &rarr; Jump to `label`, and store return address in `x1`
- Opcode: `1101111` (`JAL_OPCODE`)
