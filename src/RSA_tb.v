`timescale 1ns / 1ps

`define CYCLE      54.0
`define SDFFILE    "./RSA_syn.sdf"

`define TESTFILEDIR    "D:\\HPC LAB\\Class\\Master first grade\\Advanced Computer Algorithms\\RSA program\\Test_data\\RSA_key.txt"
`define TEST_DATA_1   "RSA-256 passed congragulations:)" // 32 bytes full text for RSA-256
`define TEST_DATA_2   "RSA testbench"
`define TEST_DATA_3   "This is a test"
`define TEST_DATA_4   "12345678"
`define TEST_DATA_5   "!@#$%^&*()_+"
`define TEST_DATA_6   "A"
`define TEST_DATA_7   "Hello world! -_-"

module RSA_tb;

// Testbench Signals
reg clk;
reg rst_n;
reg [31:0] data;
reg [255:0] out_ans;
reg enable;
wire output_flag;
wire [31:0] out;

reg [255:0] e_key_data;
reg [255:0] d_key_data;
reg [255:0] N_data;

integer cycle_count;


// Instantiate the RSA module
RSA u_RSA (
    .clk(clk),
    .rst_n(rst_n),
    .data(data),
    .out(out),
    .enable(enable),
    .output_flag(output_flag)
);

`ifdef SDF
    initial $sdf_annotate(`SDFFILE, u_RSA);
`endif

// initial begin
//     $fsdbDumpfile("rsa_tb.fsdb");
//     $fsdbDumpvars(0, u_RSA);
// end


// Clock generation
always begin #(`CYCLE/2) clk = ~clk; end

 // Counter for cycle count
always @(posedge clk) begin
    if (!rst_n) begin
        cycle_count <= 0;
    end else begin
        cycle_count <= cycle_count + 1;
    end
end

initial begin
    // Initialize inputs
    clk = 0;
    rst_n = 0;
    data = 32'h0;
    out_ans = 256'h0;
    enable = 0;
    #(`CYCLE);
    rst_n = 1;
    read_key();

    $display("RSA Testbench\n");
    $display("Key data:\n e = %h\n d = %h\n N = %h\n", e_key_data, d_key_data, N_data);

    
    //delay
    #(`CYCLE * 4);
    // Test case 1
    test_encryption_decryption(`TEST_DATA_1);
    // Test case 2
    // test_encryption_decryption(`TEST_DATA_2);
    // Test case 3
    // test_encryption_decryption(`TEST_DATA_3);
    // Test case 4
    // test_encryption_decryption(`TEST_DATA_4);
    // Test case 5
    // test_encryption_decryption(`TEST_DATA_5);
    // Test case 6
    // test_encryption_decryption(`TEST_DATA_6);
    // Test case 7
    // test_encryption_decryption(`TEST_DATA_7);

    // Finish the simulation
    $display("Cycle Count: %d", cycle_count);
    $finish;
end


// Task to read key data from file (e d N) Hexadecimal
task read_key;
integer file;
begin
    // Open the file
    file = $fopen(`TESTFILEDIR, "r");

    // Read the key data from the file
    if (file != 0) begin
        $fscanf(file, "%h %h %h", e_key_data, d_key_data, N_data);
        $fclose(file);
    end
    else begin
        $display("Error: Could not open file");
    end
end
endtask

task test_encryption_decryption(input reg[255:0] test_data); begin
    $display("Testing data (expect): %s", test_data);
    $display("=> ASCII %h\n", test_data);


    // Test case 1: Encryption
    enable = 1;
    #(`CYCLE) data = test_data[255:224];
    #(`CYCLE) data = test_data[223:192];
    #(`CYCLE) data = test_data[191:160];
    #(`CYCLE) data = test_data[159:128];
    #(`CYCLE) data = test_data[127:96];
    #(`CYCLE) data = test_data[95:64];
    #(`CYCLE) data = test_data[63:32];
    #(`CYCLE) data = test_data[31:0];
    #(`CYCLE) data = e_key_data[255:224];
    #(`CYCLE) data = e_key_data[223:192];
    #(`CYCLE) data = e_key_data[191:160];
    #(`CYCLE) data = e_key_data[159:128];
    #(`CYCLE) data = e_key_data[127:96];
    #(`CYCLE) data = e_key_data[95:64];
    #(`CYCLE) data = e_key_data[63:32];
    #(`CYCLE) data = e_key_data[31:0];
    #(`CYCLE) data = N_data[255:224];
    #(`CYCLE) data = N_data[223:192];
    #(`CYCLE) data = N_data[191:160];
    #(`CYCLE) data = N_data[159:128];
    #(`CYCLE) data = N_data[127:96];
    #(`CYCLE) data = N_data[95:64];
    #(`CYCLE) data = N_data[63:32];
    #(`CYCLE) data = N_data[31:0];

    // Wait for encryption to finish
    wait (output_flag == 1);
    #(`CYCLE/2) out_ans[255:224] = out;
    #(`CYCLE) out_ans[223:192] = out;
    #(`CYCLE) out_ans[191:160] = out;
    #(`CYCLE) out_ans[159:128] = out;
    #(`CYCLE) out_ans[127:96] = out;
    #(`CYCLE) out_ans[95:64] = out;
    #(`CYCLE) out_ans[63:32] = out;
    #(`CYCLE) out_ans[31:0] = out;

    enable = 0;


    // Check the result
    $display("Encrypted data: %h", out_ans);

    //delay
    #(`CYCLE * 4);

    // Test case 2: Decryption
    enable = 1;
    #(`CYCLE)  data = out_ans[255:224];
    #(`CYCLE)  data = out_ans[223:192];
    #(`CYCLE)  data = out_ans[191:160];
    #(`CYCLE)  data = out_ans[159:128];
    #(`CYCLE)  data = out_ans[127:96];
    #(`CYCLE)  data = out_ans[95:64];
    #(`CYCLE)  data = out_ans[63:32];
    #(`CYCLE)  data = out_ans[31:0];
    #(`CYCLE)  data = d_key_data[255:224];
    #(`CYCLE)  data = d_key_data[223:192];
    #(`CYCLE)  data = d_key_data[191:160];
    #(`CYCLE)  data = d_key_data[159:128];
    #(`CYCLE)  data = d_key_data[127:96];
    #(`CYCLE)  data = d_key_data[95:64];
    #(`CYCLE)  data = d_key_data[63:32];
    #(`CYCLE)  data = d_key_data[31:0];
    #(`CYCLE)  data = N_data[255:224];
    #(`CYCLE)  data = N_data[223:192];
    #(`CYCLE)  data = N_data[191:160];
    #(`CYCLE)  data = N_data[159:128];
    #(`CYCLE)  data = N_data[127:96];
    #(`CYCLE)  data = N_data[95:64];
    #(`CYCLE)  data = N_data[63:32];
    #(`CYCLE)  data = N_data[31:0];

    wait (output_flag == 1);
    #(`CYCLE/2)  out_ans[255:224] = out;
    #(`CYCLE)  out_ans[223:192] = out;
    #(`CYCLE)  out_ans[191:160] = out;
    #(`CYCLE)  out_ans[159:128] = out;
    #(`CYCLE)  out_ans[127:96] = out;
    #(`CYCLE)  out_ans[95:64] = out;
    #(`CYCLE)  out_ans[63:32] = out;
    #(`CYCLE)  out_ans[31:0] = out;

    enable = 0;

    // Check the result
    $display("Decrypted data (ASCII): %h", out_ans);
    
    // Display decrypted string
    $display("Decrypted string: %s", out_ans);

    // Check if the decrypted data matches the original message
    if (out_ans == test_data) begin
        $display("/////////////////////////////////////////////////////////////////////////////////");
        $display("//                                                                             //");
        $display("//                       congratulation you pass RSA testbench                 //");
        $display("//                                                                             //");
        $display("/////////////////////////////////////////////////////////////////////////////////");
    end
    else begin
        $display("Test Failed");
    end

    // delay
    #(`CYCLE * 4);

end
endtask


endmodule

