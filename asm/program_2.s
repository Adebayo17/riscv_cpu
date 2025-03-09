# =======================================
# 📌 RISC-V Test Program: BRANCH, JAL, JALR
# =======================================

_start:
    # 🔹 Initialize Registers
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 5      # x2 = 5 (BEQ taken)

    # 🔹 BEQ (Taken)
    beq x1, x2, branch_target_1  # Skip 3 instructions (12 bytes)

    # 🔹 Skipped Instructions
    addi x3, x0, 1      # x3 = 1 (SKIPPED)
    addi x3, x0, 1      # x3 = 1 (SKIPPED)
    addi x3, x0, 1      # x3 = 1 (SKIPPED)

branch_target_1:
    # 🔹 Post-BEQ Target
    addi x4, x0, 10     # x4 = 10

    # 🔹 BNE (Taken: 5 ≠ 10)
    bne x1, x4, branch_target_2  # Skip 2 instructions (8 bytes)

    # 🔹 Skipped Instructions
    addi x5, x0, 1      # x5 = 1 (SKIPPED)
    addi x5, x0, 1      # x5 = 1 (SKIPPED)

branch_target_2:
    # 🔹 Post-BNE Target
    addi x6, x0, 3      # x6 = 3

    # 🔹 BLT (Taken: 3 < 10)
    blt x6, x4, branch_target_3  # Skip 3 instructions (12 bytes)

    # 🔹 Skipped Instructions
    addi x7, x0, 1      # x7 = 1 (SKIPPED)
    addi x7, x0, 1      # x7 = 1 (SKIPPED)
    addi x7, x0, 1      # x7 = 1 (SKIPPED)

branch_target_3:
    # 🔹 Post-BLT Target
    addi x8, x0, 15     # x8 = 15

    # 🔹 BGE (Taken: 15 ≥ 10)
    bge x8, x4, branch_target_4  # Skip 3 instructions (12 bytes)

    # 🔹 Skipped Instructions
    addi x9, x0, 1      # x9 = 1 (SKIPPED)
    addi x9, x0, 1      # x9 = 1 (SKIPPED)
    addi x9, x0, 1      # x9 = 1 (SKIPPED)

branch_target_4:
    # 🔹 Post-BGE Target
    jal x10, jump_target  # x10 = PC+4, jump +8 bytes (to JALR)

jump_target:
    # 🔹 JALR (Return to JAL+4)
    jalr x0, x10, 0     # Jump to x10 (address of JALR + 4)

    # 🔹 Infinite Loop
    jal x0, 0           # Infinite loop (stay here)

    # =======================================
    # End of Program
    # =======================================

    # 🔹 Padding (NOPs)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop