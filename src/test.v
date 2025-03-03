`timescale 1ns / 1ps
// c = m^e mod N encrypt
// m = c^d mod N decrypt
module RSA
(
    // global
    input clk,
    input rst_n,
    
    // data
    input wire  [31: 0] data, // data = m: message, c: cipher -> key=> e (encrypt): public key, d (decrypt): private key, -> N: modulus
    output reg [31: 0] out_reg, // c_out: cipher output, m_out: message output
    
    // control
    input wire enable, // 0: idle, 1: start
    input wire write, // 0: read, 1: write
    output wire output_flag // 0: processing, 1: output data
);

//////////parameter////////////
localparam IDLE = 6'd0;
localparam WRITE_DATA_0 = 6'd1;
localparam WRITE_DATA_1 = 6'd2;
localparam WRITE_DATA_2 = 6'd3;
localparam WRITE_DATA_3 = 6'd4;
localparam WRITE_KEY_0 = 6'd5;
localparam WRITE_KEY_1 = 6'd6;
localparam WRITE_KEY_2 = 6'd7;
localparam WRITE_KEY_3 = 6'd8;
localparam WRITE_N_0 = 6'd9;
localparam WRITE_N_1 = 6'd10;
localparam WRITE_N_2 = 6'd11;
localparam WRITE_N_3 = 6'd12;
localparam START = 6'd13;
localparam CAL_BITS = 6'd14; // calculate key bits
localparam CAL_1 = 6'd15; // C = C * C mod N
localparam CAL_2 = 6'd16; // C = C * M mod N
localparam CHECK = 6'd17; // if k (key bits) = 1 bit, adjust data_reg < N or out = 1
localparam OUTPUT_0 = 6'd18;
localparam OUTPUT_1 = 6'd19;
localparam OUTPUT_2 = 6'd20;
localparam OUTPUT_3 = 6'd21;
localparam FINISH = 6'd22;

////////////reg////////////
reg [127:0] data_reg;
reg [127:0] key_reg;
reg [127:0] N_reg;


reg [5: 0] state;
reg [127: 0] C_reg;
reg [7: 0] i; // counter i = k - 2 to 0

reg mul_mod_enable;

////////////wire////////////
wire [127: 0] wire_b, wire_out;
wire mul_mod_finish;

wire [7: 0] i_1; // i - 1
wire i_flag;

////////////assign////////////
assign i_1 = i - 8'b1;
assign wire_b = state == CAL_1 ? C_reg : data_reg;
assign i_flag = (state == CAL_BITS) ||
                (state == CAL_1 && mul_mod_finish && ~key_reg[i_1]) ||
                (state == CAL_2 && mul_mod_finish);

assign output_flag = state == OUTPUT_1;

////////////state////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                state <= enable ? WRITE_DATA_0 : IDLE;
            end
            // write data
            WRITE_DATA_0 : begin state <= write ? WRITE_DATA_1 : WRITE_DATA_0; end
            WRITE_DATA_1 : begin state <= WRITE_DATA_2; end
            WRITE_DATA_2 : begin state <= WRITE_DATA_3; end
            WRITE_DATA_3 : begin state <= WRITE_KEY_0; end
            WRITE_KEY_0 : begin state <= WRITE_KEY_1; end
            WRITE_KEY_1 : begin state <= WRITE_KEY_2; end
            WRITE_KEY_2 : begin state <= WRITE_KEY_3; end
            WRITE_KEY_3 : begin state <= WRITE_N_0; end
            WRITE_N_0 : begin state <= WRITE_N_1; end
            WRITE_N_1 : begin state <= WRITE_N_2; end
            WRITE_N_2 : begin state <= WRITE_N_3; end
            WRITE_N_3 : begin state <= START; end
            START: begin
                state <= CAL_BITS;
            end
            CAL_BITS: begin
                state <= (i == 8'b0) ? CHECK : (key_reg[i_1] ? CAL_1 : CAL_BITS);
            end
            CAL_1: begin
                state <= mul_mod_finish ? (key_reg[i_1] ? CAL_2 : CAL_1) : (i == 8'b0 ? OUTPUT_0 : CAL_1);
            end
            CAL_2: begin
                state <= mul_mod_finish ? CAL_1 : CAL_2;
            end
            CHECK: begin
                state <= OUTPUT_0;
            end
            OUTPUT_0: begin state <= OUTPUT_1; end
            OUTPUT_1: begin state <= OUTPUT_2; end
            OUTPUT_2: begin state <= OUTPUT_3; end
            OUTPUT_3: begin state <= FINISH; end
            FINISH: begin
                state <= IDLE;
            end
        endcase
    end
end

////////////C_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        C_reg <= 128'b0;
    end
    else if (state == START) begin
        C_reg <= data_reg;
    end
    else if ((state == CAL_1 || state == CAL_2) && mul_mod_finish) begin
        C_reg <= wire_out;
    end
    else if (state == CHECK && key_reg == 128'd0) begin
        C_reg <= 128'b1;
    end
    else begin
        C_reg <= C_reg;
    end
end


//////////////data_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        data_reg <= 128'b0;
    end
    else if (state == WRITE_DATA_0) begin
        data_reg[31:0] <= data;
    end
    else if (state == WRITE_DATA_1) begin
        data_reg[63:32] <= data;
    end
    else if (state == WRITE_DATA_2) begin
        data_reg[95:64] <= data;
    end
    else if (state == WRITE_DATA_3) begin
        data_reg[127:96] <= data;
    end
    else begin
        data_reg <= data_reg;
    end
end

//////////////key_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        key_reg <= 128'b0;
    end
    else if (state == WRITE_KEY_0) begin
        key_reg[31:0] <= data;
    end
    else if (state == WRITE_KEY_1) begin
        key_reg[63:32] <= data;
    end
    else if (state == WRITE_KEY_2) begin
        key_reg[95:64] <= data;
    end
    else if (state == WRITE_KEY_3) begin
        key_reg[127:96] <= data;
    end
    else begin
        key_reg <= key_reg;
    end
end


//////////////N_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        N_reg <= 128'b0;
    end
    else if (state == WRITE_N_0) begin
        N_reg[31:0] <= data;
    end
    else if (state == WRITE_N_1) begin
        N_reg[63:32] <= data;
    end
    else if (state == WRITE_N_2) begin
        N_reg[95:64] <= data;
    end
    else if (state == WRITE_N_3) begin
        N_reg[127:96] <= data;
    end
    else begin
        N_reg <= N_reg;
    end
end

//////////////out_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        out_reg <= 32'b0;
    end
    else if (state == OUTPUT_0) begin
        out_reg <= C_reg[31:0];
    end
    else if (state == OUTPUT_1) begin
        out_reg <= C_reg[63:32];
    end
    else if (state == OUTPUT_2) begin
        out_reg <= C_reg[95:64];
    end
    else if (state == OUTPUT_3) begin
        out_reg <= C_reg[127:96];
    end
    else begin
        out_reg <= out_reg;
    end
end

////////////i////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        i <= 8'd128;
    end
    else if (i_flag) begin
        i <= i_1;
    end
    else begin
        i <= i;
    end
end

////////////mul_mod_enable/////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        mul_mod_enable <= 1'b0;
    end
    else if (state == CAL_1 || state == CAL_2) begin
        mul_mod_enable <= 1'b1;
    end
    else begin
        mul_mod_enable <= 1'b0;
    end
end

////////////mul_mod////////////
Mul_mod u_mul_mod
(
    .clk(clk),
    .rst_n(rst_n),
    .enable(mul_mod_enable),
    .A(C_reg),
    .B(wire_b),
    .N(N_reg),
    .S(wire_out),
    .finish(mul_mod_finish)
);

endmodule