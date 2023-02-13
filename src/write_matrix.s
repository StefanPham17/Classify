.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)                # s0 is pointer to filename
    sw s1, 4(sp)                # s1 is pointer to the matrx in memory
    sw s2, 8(sp)                # s2 is the number of rows in the matrix
    sw s3, 12(sp)               # s3 is the number of columns in the matrix
    sw s4, 16(sp)               # s4 is the file descriptor
    sw ra, 20(sp)


    # Plot
    add s0, a0, x0              # s0 is assigned
    add s1, a1, x0              # s1 is assigned
    add s2, a2, x0              # s2 is assigned
    add s3, a3, x0              # s3 is assigned

    addi a1, x0, 1
    jal ra, fopen               # fopen(filename, permission = 0)
    addi t0, x0, -1
    beq t0, a0, fopenError      # Error code 27
    add s4, a0, x0              # s4 is assigned

    addi a0, x0, 4
    jal ra, malloc              # malloc(4)
    beq a0, x0, mallocError     # Error code 26
    sw s2, 0(a0)
    add s2, a0, x0              # s2 is reassigned to pointer to number of rows

    addi a0, x0, 4
    jal ra, malloc              # malloc(4)
    beq a0, x0, mallocError     # Error code 26
    sw s3, 0(a0)
    add s3, a0, x0              # s3 is reassigned to pointer to number of columns

    add a0, s4, x0
    add a1, s2, x0
    addi a2, x0, 1
    addi a3, x0, 4
    jal ra, fwrite              # fwrtie(file descriptor, row pointer, 1, 4)
    addi t0, x0, 1
    bne a0, t0, fwriteError     # Error code 30

    add a0, s4, x0
    add a1, s3, x0
    addi a2, x0, 1
    addi a3, x0, 4
    jal ra, fwrite              # fwrtie(file descriptor, column pointer, 1, 4)
    addi t0, x0, 1
    bne a0, t0, fwriteError     # Error code 30

    add a0, s4, x0
    add a1, s1, x0
    lw a2, 0(s2)
    lw t0, 0(s3)
    mul a2, a2, t0
    addi a3, x0, 4
    jal ra, fwrite              # fwrtie(file descriptor, matrix pointer, row * col, 4)
    lw t0, 0(s2)
    lw t1, 0(s3)
    mul t0, t0, t1
    bne a0, t0, fwriteError     # Error code 30

    add a0, x0, s4
    jal ra, fclose              # fclose(file descriptor)
    bne a0, x0, fcloseError     # Error code 28

    add a0, s2, x0
    jal ra, free

    add a0, s3, x0
    jal ra, free


    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)                
    lw s4, 16(sp)               
    lw ra, 20(sp)
    addi sp, sp, 24

    jr ra

    fopenError:
    li a0 27
    j exit

    fwriteError:
    li a0 30
    j exit

    mallocError:
    li a0 26
    j exit

    fcloseError:
    li a0 28
    j exit
