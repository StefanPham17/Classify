.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

    # Prologue
    addi sp, sp, -24
    sw s0, 0(sp)                # s0 is pointer to filename
    sw s1, 4(sp)                # s1 is pointer to the number of rows
    sw s2, 8(sp)                # s2 is pointer to the number of columns
    sw s3, 12(sp)               # s3 is pointer to file descriptor    
    sw s4, 16(sp)               # s4 is pointer to buffer
    sw ra, 20(sp)


    # Plot
    add s0, a0, x0              # s0 is assigned
    add s1, a1, x0              # s1 is assigned
    add s2, a2, x0              # s2 is assigned

    add a1, x0, x0
    jal ra, fopen               # fopen(filename, permission = 0)
    addi t0, x0, -1
    beq t0, a0, fopenError      # Error code 27
    add s3, a0, x0              # s3 is assigned

    add a0, s3, x0
    add a1, s1, x0
    addi a2, x0, 4
    jal ra, fread               # fread(file descriptor, row pointer, 4)
    addi t0, x0, 4
    bne a0, t0, freadError      # Error code 29

    add a0, s3, x0
    add a1, s2, x0
    addi a2, x0, 4
    jal ra, fread               # fread(file descriptor, column pointer, 4)
    addi t0, x0, 4
    bne a0, t0, freadError      # Error code 29

    lw a0, 0(s1)
    lw t0, 0(s2)
    addi t1, x0, 4
    mul t0, t0, t1
    mul a0, a0, t0
    jal ra, malloc              # malloc(4 * row * col)
    beq a0, x0, mallocError     # Error code 26
    add s4, a0, x0              # s4 is assigned

    add a0, s3, x0
    add a1, s4, x0
    lw a2, 0(s1)
    lw t0, 0(s2)
    addi t1, x0, 4
    mul t0, t0, t1
    mul a2, a2, t0
    jal ra, fread               # fread(file descriptor, buffer, 4 * row * column)
    lw t0, 0(s1)
    lw t1, 0(s2)
    addi t2, x0, 4
    mul t0, t0, t2
    mul t0, t0, t1
    bne a0, t0, freadError      # Error code 29

    add a0, x0, s3
    jal ra, fclose              # fclose(file descriptor)
    bne a0, x0, fcloseError     # Error code 28

    add a0, x0, s4              # return matrix pointer


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

    freadError:
    li a0 29
    j exit

    mallocError:
    li a0 26
    j exit

    fcloseError:
    li a0 28
    j exit
