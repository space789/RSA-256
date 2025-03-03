`timescale 1ns/1ns
`define TESTFILEDIR    "D:\\HPC LAB\\Class\\Master first grade\\Advanced Computer Algorithms\\RSA program\\Test_data"

module tb_Mul_mod;

// Inputs
reg clk;
reg rst_n;
reg [255:0] A, B, N;
reg enable;

reg flag;

// Outputs
wire [255:0] S;
wire finish;

// Instantiate the Unit Under Test
Mul_mod #(
    .k(1)
)
uut (
    .clk(clk),
    .rst_n(rst_n),
    .A(A),
    .B(B),
    .N(N),
    .S(S),
    .enable(enable),
    .finish(finish)
);

// Clock generation
always #5 clk = ~clk;

// Read test data from file
task read_test_data;
    integer file, scan_res;
    reg [255:0] exp_S;
    begin
        file = $fopen({`TESTFILEDIR,"\\Mul_mod_data.txt"},"r");
        if (file == 0) begin
            $display("Failed to open file Mul_mod_data.txt");
            $finish;
        end
        while (!$feof(file)) begin
            scan_res = $fscanf(file, "%d %d %d %d", A, B, N, exp_S);
            if (scan_res == 4) begin
                enable = 1;
                wait(finish == 1);
                if (S == exp_S) $display("Test passed: A=%d, B=%d, N=%d, S=%d", A, B, N, S);
                else begin $error("Test failed: A=%d, B=%d, N=%d, Expected S=%d, Got S=%d", A, B, N, exp_S, S); flag =1; end
                wait(finish == 0);
            end
        end
        $fclose(file);
    end
endtask

// Test vectors
initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 0;
    A = 0;
    B = 0;
    N = 0;
    enable = 0;
    flag = 0;
    
    // Assert reset
    #10 rst_n = 1;
    
    // Read test data from file
    read_test_data();

    if (!flag) begin
        $display("/////////////////////////////////////////////////////////////////////////////////");
        $display("//                                                                             //");
        $display("//                       Congratulation you pass all data                      //");
        $display("//                                                                             //");
        $display("/////////////////////////////////////////////////////////////////////////////////");
    end
    
    $finish;
end

endmodule