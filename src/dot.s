.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

    # Prologue
    add t0, x0, x0
    add t2, x0, x0
    addi t3, x0, 4
    addi t4, x0, 4
    mul t3, t3, a3
    mul t4, t4, a4
    blt x0, a2, checkStride1
    li a0 36
    j exit
checkStride1:
    blt x0, a3, checkStride2
    li a0 37
    j exit
checkStride2:
    blt x0, a4, loop_start
    li a0 37
    j exit
loop_start:
    lw t5 0(a0)
    lw t6 0(a1)
    mul t5, t5, t6
    add t0, t0, t5
    add a0, a0, t3
    add a1, a1, t4
    addi t2, t2, 1
    bne t2, a2, loop_start
loop_end:
    add a0, x0, t0


    # Epilogue


    jr ra
