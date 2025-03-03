`timescale 1ns / 1ps

module CS32ADD_tb;

    // Inputs
    reg [127:0] A, B;
    reg Cin;

    // Outputs
    wire [127:0] Sum;
    wire Cout;

    // Instantiate the Unit Under Test (UUT)
    CSA128 uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(Sum),
        .Cout(Cout)
    );

    // Test vectors
    reg [127:0] test_vectors [0:7];
    reg [128:0] expected_results [0:7];

    // Loop variable
    integer i;

    initial begin
        // Initialize test vectors
        test_vectors[0] = 128'd654251211;       expected_results[0] =129'd659402722;
        test_vectors[1] = 128'd5151511;         expected_results[1] =129'd5473066;
        test_vectors[2] = 128'd321555;          expected_results[2] = 129'd1321480;
        test_vectors[3] = 128'd999925;          expected_results[3] = 129'd1000000;
        test_vectors[4] = 128'd75;              expected_results[4] = 129'd100;
        test_vectors[5] = 128'd25;
    end

    always begin
        for (i = 0; i < 5; i = i + 1) begin
            A = test_vectors[i];
            B = test_vectors[i + 1];
            Cin = 1'b0;
            #10;
            if ({Cout,Sum} !== expected_results[i]) begin
                $display("Test failed: A=%d, B=%d, Cin=%d, Sum=%d, Cout=%d, expected=%d", A, B, Cin, Sum, Cout, expected_results[i]);
            end
        end

        $finish;
    end
endmodule