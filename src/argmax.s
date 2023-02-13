.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi t1, x0, 1
    add t2, a0, x0
    bge a1, t1, loop_start
    li a0 36
    j exit
loop_start:
    add t5, x0, x0
    lw t3, 0(a0)
    beq t1, a1, loop_end
loop_continue:
    addi a0, a0, 4
    lw t4, 0(a0)
    bge t3, t4, time_skip
    add t5, x0, t1
    add t3, x0, t4
time_skip:
    addi t1, t1, 1
    blt t1, a1, loop_continue
loop_end:
    add a0, t5, x0
    # Epilogue
    jr ra
