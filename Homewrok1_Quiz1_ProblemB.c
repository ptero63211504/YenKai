#include <stdint.h>
#include <stdio.h>     
#include <stdlib.h>   

typedef struct {
    uint16_t bits;
} bf16_t;

static inline float bf16_to_fp32(bf16_t h)
{
    union {
        float f;
        uint32_t i;
    } u = {.i = (uint32_t)h.bits << 16};
    return u.f;
}

static inline bf16_t fp32_to_bf16(float s)
{
    bf16_t h;
    union {
        float f;
        uint32_t i;
    } u = {.f = s};
    if ((u.i & 0x7fffffff) > 0x7f800000) { /* NaN */
        h.bits = (u.i >> 16) | 64;         /* force to quiet */
        return h;                                                                                                                                             
    }
    h.bits = (u.i + (0x7fff + ((u.i >> 0x10) & 1))) >> 0x10;
    return h;
}

int main(){
    float test_data[3] = {-1.5f, 123.456f, -0.0f};
    bf16_t expected_bf16[3] = {0xBFC0, 0x42F7, 0x8000};
    uint32_t expected_fp32[3] = {0xBFC00000, 0x42F70000, 0x80000000};
    int num = sizeof(test_data) / sizeof(test_data[0]);
    
    for (int i = 0; i < num; i++) {
        bf16_t bf16_value = fp32_to_bf16(test_data[i]);
        if (bf16_value.bits == expected_bf16[i].bits) {
            printf("BF16 conversion for test_data[%d] is correct\n", i);
        } else {
            printf("BF16 conversion for test_data[%d] is incorrect\n", i);
        }

        float recovered_fp32 = bf16_to_fp32(bf16_value);
        if (*(uint32_t *)&recovered_fp32 == expected_fp32[i]) {
            printf("FP32 recovery for test_data[%d] is correct\n", i);
        } else {
            printf("FP32 recovery for test_data[%d] is incorrect\n", i);
        }
    }
    
    return 0;
}