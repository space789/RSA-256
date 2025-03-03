`timescale 1ns / 1ps
module FA(
    input A, B, Cin,
    output S, P, Cout
);
    assign P = A ^ B;
    assign S = P ^ Cin;
    assign Cout = (A & B) | (P & Cin);
endmodule

// module CSA8(
//     input [7:0] A, B,
//     input Cin,
//     output [7:0] S,
//     output Pout, Cout
// );
//     wire [7:0] P;
//     wire [7:0] C;

//     FA fa0(A[0], B[0],  Cin, S[0], P[0], C[0]);
//     FA fa1(A[1], B[1], C[0], S[1], P[1], C[1]);
//     FA fa2(A[2], B[2], C[1], S[2], P[2], C[2]);
//     FA fa3(A[3], B[3], C[2], S[3], P[3], C[3]);
//     FA fa4(A[4], B[4], C[3], S[4], P[4], C[4]);
//     FA fa5(A[5], B[5], C[4], S[5], P[5], C[5]);
//     FA fa6(A[6], B[6], C[5], S[6], P[6], C[6]);
//     FA fa7(A[7], B[7], C[6], S[7], P[7], C[7]);

//     assign Pout = &P;
//     assign Cout = Pout ? Cin : C[7];
// endmodule
module CSA4(
    input [3:0] A, B,
    input Cin,
    output [3:0] S,
    output Pout, Cout
);
    wire [3:0] P;
    wire [3:0] C;

    FA fa0(A[0], B[0],  Cin, S[0], P[0], C[0]);
    FA fa1(A[1], B[1], C[0], S[1], P[1], C[1]);
    FA fa2(A[2], B[2], C[1], S[2], P[2], C[2]);
    FA fa3(A[3], B[3], C[2], S[3], P[3], C[3]);

    assign Pout = &P;
    assign Cout = Pout ? Cin : C[3];
endmodule

module CSA16(
    input [15:0] A, B,
    input Cin,
    output [15:0] S,
    output Pout, Cout
);
    wire [3:0] P;
    wire [3:0] C;

    CSA4 csa4_0(A[3:0], B[3:0],  Cin, S[3:0], P[0], C[0]);
    CSA4 csa4_1(A[7:4], B[7:4], C[0], S[7:4], P[1], C[1]);
    CSA4 csa4_2(A[11:8], B[11:8], C[1], S[11:8], P[2], C[2]);
    CSA4 csa4_3(A[15:12], B[15:12], C[2], S[15:12], P[3], C[3]);

    assign Pout = &P;
    assign Cout = Pout ? Cin : C[3];
endmodule

// module CSA32(
//     input [31:0] A, B,
//     input Cin,
//     output [31:0] S,
//     output Pout, Cout
// );
//     wire [3:0] C;
//     wire [3:0] P;

//     CSA8 csa8_0(A[7:0], B[7:0],  Cin, S[7:0], P[0], C[0]);
//     CSA8 csa8_1(A[15:8], B[15:8], C[0], S[15:8], P[1], C[1]);
//     CSA8 csa8_2(A[23:16], B[23:16], C[1], S[23:16], P[2], C[2]);
//     CSA8 csa8_3(A[31:24], B[31:24], C[2], S[31:24], P[3], C[3]);

//     assign Pout = &P;
//     assign Cout = Pout ? Cin : C[3];
// endmodule

module CSA64(
    input [63:0] A, B,
    input Cin,
    output [63:0] S,
    output Pout, Cout
);
    wire [3:0] C;
    wire [3:0] P;

    CSA16 csa16_0(A[15:0], B[15:0],  Cin, S[15:0], P[0], C[0]);
    CSA16 csa16_1(A[31:16], B[31:16], C[0], S[31:16], P[1], C[1]);
    CSA16 csa16_2(A[47:32], B[47:32], C[1], S[47:32], P[2], C[2]);
    CSA16 csa16_3(A[63:48], B[63:48], C[2], S[63:48], P[3], C[3]);

    assign Pout = &P;
    assign Cout = Pout ? Cin : C[3];
endmodule

// module CSA128(
//     input [127:0] A, B,
//     input Cin,
//     output [127:0] S,
//     output Pout, Cout
// );
//     wire [3:0] C;
//     wire [3:0] P;

//     CSA32 csa32_0(A[31:0], B[31:0],  Cin, S[31:0], P[0], C[0]);
//     CSA32 csa32_1(A[63:32], B[63:32], C[0], S[63:32], P[1], C[1]);
//     CSA32 csa32_2(A[95:64], B[95:64], C[1], S[95:64], P[2], C[2]);
//     CSA32 csa32_3(A[127:96], B[127:96], C[2], S[127:96], P[3], C[3]);

//     assign Pout = &P;
//     assign Cout = Pout ? Cin : C[3];
// endmodule

// module CSA258(
//     input [257:0] A, B,
//     input Cin,
//     output [257:0] S,
//     output Pout, Cout
// );
//     wire [3:0] C;
//     wire [3:0] P;

//     CSA128 csa128_0(A[127:0], B[127:0],  Cin, S[127:0], P[0], C[0]);
//     CSA128 csa128_1(A[255:128], B[255:128], C[0], S[255:128], P[1], C[1]);

//     FA fa0(A[256], B[256], C[1], S[256], P[2], C[2]);
//     FA fa1(A[257], B[257], C[2], S[257], P[3], C[3]);

//     assign Pout = &P;
//     assign Cout = Pout ? Cin : C[3];
// endmodule

module CSA258(
    input [257:0] A, B,
    input Cin,
    output [257:0] S,
    output Pout, Cout
);
    wire [5:0] C;
    wire [5:0] P;

    FA fa0(A[0], B[0],  Cin, S[0], P[0], C[0]);

    CSA64 csa64_0(A[64:1], B[64:1], C[0], S[64:1], P[1], C[1]);
    CSA64 csa64_1(A[128:65], B[128:65], C[1], S[128:65], P[2], C[2]);
    CSA64 csa64_2(A[192:129], B[192:129], C[2], S[192:129], P[3], C[3]);
    CSA64 csa64_3(A[256:193], B[256:193], C[3], S[256:193], P[4], C[4]);

    FA fa1(A[257], B[257], C[4], S[257], P[5], C[5]);

    assign Pout = &P;
    assign Cout = Pout ? Cin : C[5];
endmodule


module CSA265(
    input [264:0] A, B,
    input Cin,
    output [264:0] S,
    output Pout, Cout
);
    wire [6:0] C;
    wire [6:0] P;

    CSA4 csa4_0(A[3:0], B[3:0],  Cin, S[3:0], P[0], C[0]);  

    CSA64 csa64_0(A[67:4], B[67:4], C[0], S[67:4], P[1], C[1]);
    CSA64 csa64_1(A[131:68], B[131:68], C[1], S[131:68], P[2], C[2]);
    CSA64 csa64_2(A[195:132], B[195:132], C[2], S[195:132], P[3], C[3]);
    CSA64 csa64_3(A[259:196], B[259:196], C[3], S[259:196], P[4], C[4]);

    CSA4 csa4_1(A[263:260], B[263:260], C[4], S[263:260], P[5], C[5]);

    FA fa0(A[264], B[264], C[5], S[264], P[6], C[6]);

    assign Pout = &P;
    assign Cout = Pout ? Cin : C[6];
endmodule