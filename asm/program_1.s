# =======================================
# 📌 Comprehensive RISC-V Test Program
# =======================================

_start:
    # 🔹 Register Initialization (I-type)
    addi x1, x0, 1      # x1 = 1
    addi x2, x0, 2      # x2 = 2
    addi x3, x0, 3      # x3 = 3
    addi x4, x0, 4      # x4 = 4

    # 🔹 Padding (NOP)
    nop
    nop

    # 🔹 Arithmetic & Logic Operations (R-type)
    add x3, x1, x2      # x3 = x1 + x2 = 3
    sub x4, x2, x1      # x4 = x2 - x1 = 1
    and x5, x3, x3      # x5 = x3 & x3 = 3
    or x6, x3, x3       # x6 = x3 | x3 = 3
    xor x7, x3, x3      # x7 = x3 ^ x3 = 0

    # 🔹 Padding (NOP)
    nop
    nop

    # 🔹 Shift Instructions (R-type)
    sll x5, x1, x2      # x5 = x1 << x2 (1 << 2 = 4)
    srl x6, x1, x2      # x6 = x1 >> x2 (1 >> 2 = 0)
    sra x7, x1, x2      # x7 = x1 >> x2 (Arithmetic)

    # 🔹 Padding (NOP)
    nop
    nop

    # 🔹 Memory Load (I-type) and Store (S-type)
    sw x10, 0(x2)       # MEM[x2 + 0] = x10
    lw x2, 0(x2)        # x2 = MEM[x2 + 0]

    # 🔹 Padding (NOP)
    nop
    nop

    # 🔹 Branch Instructions (B-type)
    beq x1, x2, 12      # Branch if x1 == x2 (Not taken)
    bne x1, x2, 12      # Branch if x1 != x2 (Taken, jump 12 bytes)

    # 🔹 Padding (NOP)
    nop
    nop

    # 🔹 Jump Instructions
    jal x5, 8           # x5 = PC+4, jump +8 bytes
    jalr x0, x5, 0      # Jump to x5 (Return to PC)

    # =======================================
    # End of Program
    # =======================================

    # 🔹 Padding (NOPs)
    nop
    nop
    nop
    nop