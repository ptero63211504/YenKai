#include <stdio.h>     
#include <stdlib.h>    
#include <string.h>    

char* addBinary(char* a, char* b) {
    int la = strlen(a), lb = strlen(b);
    int lc = la > lb ? la : lb;
    char* c = (char*)malloc(lc+1);
    c[lc] = '\0';

    int i, carry = 0; // carry表示進位
    for(i = 0 ; i < lc ; i++){
        int bit_a = (la - 1 - i >= 0) ? 
            a[la - 1 - i] - '0' : 0; //從ascii轉成數字
        int bit_b = (lb - 1 - i >= 0) ? 
            b[lb - 1 - i] - '0' : 0; //從ascii轉成數字
        int sum = bit_a + bit_b + carry;
        carry = sum / 2;
        c[lc - 1 - i] = (sum % 2) + '0';
    }
    if(carry == 1){
        c = (char*)realloc(c,lc+2);
        for(i = lc ; i >= 0 ; i--){
            c[i+1] = c[i];
        }
        c[0] = '1';
    }
    return c;
}

int main() {
    char a[] = "11";
    char b[] = "1";

    char* result = addBinary(a, b);
    printf("Result of %s +%s = %s\n", a, b, result);
    free(result);

    return 0;
}
