.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

    # Error checks
    blt x0, a1, check1
    li a0 38
    j exit
    check1:
    blt x0, a2, check2
    li a0 38
    j exit
    check2:
    blt x0, a4, check3
    li a0 38
    j exit
    check3:
    blt x0, a5, check4
    li a0 38
    j exit
    check4:
    beq a2, a4, prologue
    li a0 38
    j exit
    # Prologue
prologue: 
    addi sp, sp, -40
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw ra, 36(sp)

    mv s0, a0                       # Start of m0
    mv s1, a1                       # Row count of m0
    mv s2, a2                       # Col count of m0
    mv s3, a3                       # Start of m1
    mv s4, a4                       # Row count of m1
    mv s5, a5                       # Col count of m1
    mv s6, a6                       # Start of d
    add s7, x0, x0                  # Current row of m0

    
outer_loop_start:
    add s8, x0, x0                  # Current col of m1


inner_loop_start:
    addi t0, x0, 4
    mul t1, s2, s7
    mul t1, t1, t0
    add a0, s0, t1                  # a0 set
    mul t2, s8, t0
    add a1, s3, t2                  # a1 set
    add a2, s2, x0                  # a2 set
    addi a3, x0, 1                  # a3 set
    add a4, x0, s5                  # a4 set
    jal ra, dot
    sw a0, 0(s6)
    addi s6, s6, 4
    addi s8, s8, 1
    bne s8, s5, inner_loop_start

inner_loop_end:
    addi s7, s7, 1
    bne s7, s1, outer_loop_start

outer_loop_end:
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    lw ra, 36(sp)
    addi sp, sp, 40
    # Epilogue
    ret


    jr ra
