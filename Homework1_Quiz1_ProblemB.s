    .data
test_data:
    .word 0xBFC00000       # -1.5 (float)
    .word 0x42F6E979       # 123.456 (float)
    .word 0x80000000       # -0.0 (float)

expected_bf16:
    .half 0xBFC0           # Expected bfloat16 values
    .half 0x42F7
    .half 0x8000

expected_fp32:
    .word 0xBFC00000       # Expected float32 recovered values
    .word 0x42F70000
    .word 0x80000000

bf16correct:
    .string "bf16_Correct\n"
fp32correct:
    .string "fp32_Correct\n"
bf16incorrect:
    .string "bf16_Incorrect\n"
fp32incorrect:
    .string "fp32_Incorrect\n"

    .text
    .global main
main:
    # Initialize loop counter
    la s0, test_data
    la s1, expected_bf16
    la s2, expected_fp32
    li s3, 0               # i = 0
    li s4, 3               # num = 3 (size of the test_data array)
    li s5, 0xffff0000

loop:
    bge s3, s4, end_loop   # if i >= num, exit loop
    lw a0, 0(s0)           # Load float value (FP32) into a0
    lh a1, 0(s1)
    sub a1, a1, s5
    lw a2, 0(s2)
    jal ra, fp32_to_bf16   # Call function

    beq a0, a1, bf16_correct

    # Load test_data[i+1]
    addi s0, s0, 4         # Address of test_data[i]
    addi s1, s1, 2         # Address of expected_bf16[i]
    addi s2, s2, 4         # Address of expected_fp32[i]
    
    bne a0, a1, print_bf16_incorrect
    j next_iteration
    
fp32_to_bf16:
    li t0, 0x7fffffff      
    li t6, 0
    and t1, t6, t0         
    li t0, 0x7f800000      
    bgt t1, t0, handle_nan 
    
_1:
    li t0, 0x7fff          
    srli t1, a0, 16        
    andi t1, t1, 1         
    add t1, t1, t0         
    add t1, t1, a0         
    srli t1, t1, 16        
    mv a0, t1              
    ret                    

handle_nan:
    srli t1, a0, 16         
    ori t1, t1, 64        
    mv a0, t1              
    j _1                   

bf16_correct:
    jal ra, print_bf16_correct
    jal ra, bf16_to_fp32   

    beq a0, a2, fp32_correct
    bne a0, a2, print_fp32_incorrect
    j next_iteration
    
bf16_to_fp32:
# a0 contains the input bf16 (h.bits)
    addi a0, a1, 0      
    slli t0, a0, 16      
    mv a0, t0
    ret

fp32_correct:
    la a0, fp32correct
    li a7, 4
    ecall
    j next_iteration

next_iteration:
    addi s3, s3, 1         # i++
    j loop                 # Go to the next iteration

end_loop:
    li a7, 10
    li a0, 0
    ecall

# Print routines (implement later)
print_bf16_correct:
    la a0, bf16correct
    li a7, 4
    ecall
    ret

print_bf16_incorrect:
    la a0, bf16incorrect
    li a7, 4
    ecall

    j next_iteration

print_fp32_incorrect:
    la a0, fp32incorrect
    li a7, 4
    ecall

    j next_iteration