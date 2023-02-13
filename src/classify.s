.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
    #Prologue
    addi t0, x0, 5
    bne a0, t0, numArgError

    addi sp, sp, -40
    sw s0, 0(sp)                # s0 is helper
    sw s1, 4(sp)                # s1 is argv
    sw s2, 8(sp)                # s2 is silent mode indicator
    sw s3, 12(sp)               # s3 is pointer to m0 in memory
    sw s4, 16(sp)               # s4 is pointer to m1 in memory
    sw s5, 20(sp)               # s5 is pointer to input matrix in memory
    sw s6, 24(sp)               # s6 is pointer to m0's row and col
    sw s7, 28(sp)               # s7 is pointer to m1's row and col
    sw s8, 32(sp)               # s8 is pointer to input's row and col
    sw ra, 36(sp)

    add s1, a1, x0
    add s2, a2, x0

    # Read pretrained m0
    addi a0, x0, 8
    jal ra, malloc              # malloc(8)
    beq a0, x0, mallocError     # Error code 26

    add a1, a0, x0
    addi a2, a1, 4
    add s6, a0, x0              # s6 is assigned
    lw a0, 4(s1)
    jal ra, read_matrix
    add s3, a0, x0              # s3 is assigned


    # Read pretrained m1
    addi a0, x0, 8
    jal ra, malloc              # malloc(8)
    beq a0, x0, mallocError     # Error code 26

    add a1, a0, x0
    addi a2, a1, 4
    add s7, a0, x0              # s7 is assigned
    lw a0, 8(s1)
    jal ra, read_matrix
    add s4, a0, x0              # s4 is assigned


    # Read input matrix
    addi a0, x0, 8
    jal ra, malloc              # malloc(8)
    beq a0, x0, mallocError     # Error code 26

    add a1, a0, x0
    addi a2, a1, 4
    add s8, a0, x0              # s8 is assigned
    lw a0, 12(s1)
    jal ra, read_matrix
    add s5, a0, x0              # s5 is assigned


    # Compute h = matmul(m0, input)
    lw a0, 0(s6)
    lw t0, 4(s8)
    mul a0, a0, t0
    addi t0, x0, 4
    mul a0, a0, t0
    jal ra, malloc              # malloc(m0-row * input-col * 4)
    beq a0, x0, mallocError     # Error code 26
    add s0, a0, x0              # s0 is assigned to h memory

    add a6, a0, x0
    add a0, s3, x0
    lw a1, 0(s6)
    lw a2, 4(s6)
    add a3, s5, x0
    lw a4, 0(s8)
    lw a5, 4(s8)
    jal ra, matmul              # matmul(m0, m0-row, m0-col, input, input-row, input-col, result-address)
    add a0, s3, x0
    jal ra, free                # s3 is free to use
    add s3, s0, x0              # s3 is assigned to h memory

    # Compute h = relu(h)
    add a0, s3, x0
    lw a1, 0(s6)
    lw t0, 4(s8)
    mul a1, a1, t0              # h = relu(h)
    jal ra, relu


    # Compute o = matmul(m1, h)
    lw t0, 4(s8)
    sw t0, 4(s6)                # s6 is pointer to h's row and col
    add a0, s8, x0
    jal ra, free                # s8 is free to use
    
    lw a0, 0(s7)
    lw t0, 4(s6)
    mul a0, a0, t0
    addi t0, x0, 4
    mul a0, a0, t0
    jal ra, malloc              # malloc(m1-row * h-col * 4)
    beq a0, x0, mallocError     # Error code 26
    add s0, a0, x0              # s0 is assigned to o memory

    add a6, a0, x0
    add a0, s4, x0
    lw a1, 0(s7)
    lw a2, 4(s7)
    add a3, s3, x0
    lw a4, 0(s6)
    lw a5, 4(s6)
    jal ra, matmul              # matmul(m0, m0-row, m0-col, input, input-row, input-col, result-address)
    add a0, s4, x0
    jal ra, free                # s4 is free to use
    add s4, s0, x0              # s4 is assigned to o memory

    lw t0, 4(s6)
    sw t0, 4(s7)                # s7 is pointer to o's row and col
    add a0, s6, x0
    jal ra, free                # s6 is free to use

    # Write output matrix o
    lw a0, 16(s1)
    add a1, s4, x0
    lw a2, 0(s7)
    lw a3, 4(s7)
    jal ra, write_matrix

    # Compute and return argmax(o)
    add a0, s4, x0
    lw a1, 0(s7)
    lw t0, 4(s7)
    mul a1, a1, t0
    jal ra, argmax
    add s6, a0, x0

    # If enabled, print argmax(o) and newline
    bne s2, x0, skip
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char
    skip:

    # Freedom
    add a0, s3, x0
    jal ra, free                # s3 is free
    add a0, s4, x0
    jal ra, free                # s4 is free
    add a0, s5, x0
    jal ra, free                # s5 is free
    add a0, s7, x0
    jal ra, free                # s7 is free

    add a0, s6, x0              # return result of argmax(o)

    # Epilogue
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

    jr ra

    mallocError:
    li a0 26
    j exit

    numArgError:
    li a0 31
    j exit
