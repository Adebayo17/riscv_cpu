# Example RISC-V Assembly Program
_start:
    addi x1, x0, 1      # x1 = 1
    addi x2, x0, 2      # x2 = 2
    add x3, x1, x2      # x3 = x1 + x2 (3)
    sw x3, 0(x0)        # Store x3 at memory address 0
    lw x4, 0(x0)        # Load x4 from memory address 0
    beq x4, x3, _start  # Branch to _start if x4 == x3