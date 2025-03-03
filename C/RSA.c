#include <stdio.h>
#include <stdlib.h>

#define k 1

// 函數用來顯示整數 e 的位元數
int displayBitCount(int e) {
    int count = 0;
    unsigned int mask = 1; // 使用無符號整數以避免右移時出現符號擴展問題

    // 遍歷整數的每一位，計算置為1的位元數
    while (e != 0) {
        count++;  // 增加計數
        e >>= 1;      // 右移一位，檢查下一位
    }

    return count;
}

// 函數用來顯示整數 e 的第 g 個位元
int displayKthBit(int e, int g) {
    unsigned int mask = 1;

    // 將 mask 左移 k-1 位，以找到第 k 個位元
    mask <<= (g - 1);

    // 如果第 k 個位元為1，則輸出1，否則輸出0
    if (e & mask)
        return 1;
    else
        return 0;
}

int Mul_mod(int a,int b,int n) {
    /*
        a [127: 0]
        b [127: 0]
        n [127: 0]
    */
    int DB_reg = a; // DB_reg [127: 0]
    int C_reg = 0; // C_reg [138: 0]
    int DB_2 = 0; // wire [128: 0]
    int DB_2_N = 0; // wire [129: 0]
    // do in parallel
    for (int i = 1; i <= 31; i++) {
        DB_2 = (DB_reg << 1); // assgin wire 
        DB_2_N = (DB_reg << 1) - n;
        // parallel
        if (b & 1) {
            C_reg = C_reg + DB_reg;
        } else if (C_reg > 0) {
            C_reg = C_reg - k * n;
        }
        b = b >> 1;
        // parallel
        if (DB_2_N >= 0) {
            DB_reg = DB_2_N;
        } else {
            DB_reg = DB_2;
        }
    }
    while (C_reg >= 0) {
        C_reg = C_reg - k * n;
    }
    while (C_reg < 0) {
        C_reg = C_reg + n;
    }
    return C_reg;
}

int RSA(int M,int C,int e,int d,int N){
    int C_reg = M;
    for (int i = displayBitCount(e) - 1; i > 0; i--){  // e:k bits k > 1, i = k - 2 to 0 do
        // printf("i: %d\n", i);
        C_reg = Mul_mod(C_reg, C_reg, N);
        // printf("displayKthBit(e, i): %d\n", displayKthBit(e, i));
        if (displayKthBit(e, i)) // e[k]
            C_reg = Mul_mod(C_reg, M, N);
    }
    return C_reg;
}


int main() {
    int a = 4000, b = 12;
    int e = 8000000, d = 187, N = 319;
    printf("Mul_mod(%d, %d, %d) = %d\n", a, b, N, Mul_mod(a, b, N));
    printf("RSA(%d, %d, %d, %d, %d) = %d\n", a, b, e, d, N, RSA(a, b, e, d, N));
    return 0;
}