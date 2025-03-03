`timescale 1ns / 1ps
// c = m^e mod N encrypt
// m = c^d mod N decrypt
module RSA
(
    // global
    input clk,
    input rst_n,
    
    // data
    input wire [31: 0] data, // data = m: message, c: cipher -> key=> e (encrypt): public key, d (decrypt): private key, -> N: modulus
    output reg [31: 0] out, // encrypt: cipher output, decrypt: message output
    
    // control
    input wire enable, // 0: idle, 1: start
    output reg output_flag // 0: processing, 1: output data
);

//////////parameter////////////
localparam IDLE = 4'd0;
localparam LOAD_DATA = 4'd1;
localparam LOAD_KEY = 4'd2;
localparam LOAD_N = 4'd3;
localparam START = 4'd4;
localparam CAL_BITS = 4'd5; // calculate key bits
localparam CAL_1 = 4'd6; // C = C * C mod N
localparam CAL_2 = 4'd7; // C = C * M mod N
// localparam CHECK = 4'd8; // if k (key bits) = 1 bit, adjust data < N or out = 1
localparam OUTPUT = 4'd9;
localparam FINISH = 4'd10;

////////////reg////////////
reg [3: 0] state;
reg [255: 0] data_reg, key_reg, N_reg, C_reg;
reg [8: 0] i; // counter i = k - 2 to 0
reg [2: 0] counter; // counter for loading 256-bit values in 32-bit chunks

reg mul_mod_enable;

////////////wire////////////
wire [255: 0] wire_b, wire_out;
wire mul_mod_finish;

wire [8: 0] i_1; // i - 1
wire i_flag;

////////////assign////////////
assign i_1 = i - 9'b1;
assign wire_b = state == CAL_1 ? C_reg : data_reg;
assign i_flag = (state == CAL_BITS) ||
                (state == CAL_1 && mul_mod_finish && ~key_reg[i_1]) ||
                (state == CAL_2 && mul_mod_finish);

////////////state////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                state <= enable ? LOAD_DATA : IDLE;
            end
            LOAD_DATA: begin
                state <= (counter == 3'b111) ? LOAD_KEY : LOAD_DATA;
            end
            LOAD_KEY: begin
                state <= (counter == 3'b111) ? LOAD_N : LOAD_KEY;
            end
            LOAD_N: begin
                state <= (counter == 3'b111) ? START : LOAD_N;
            end
            START: begin
                state <= CAL_BITS;
            end
            CAL_BITS: begin
                state <= (i == 9'b0) ? OUTPUT : (key_reg[i_1] ? CAL_1 : CAL_BITS);
            end
            CAL_1: begin
                state <= mul_mod_finish ? (key_reg[i_1] ? CAL_2 : CAL_1) : (i == 9'b0 ? OUTPUT : CAL_1);
            end
            CAL_2: begin
                state <= mul_mod_finish ? CAL_1 : CAL_2;
            end
            OUTPUT: begin
                state <= (counter == 3'b111) ? FINISH : OUTPUT;
            end
            FINISH: begin
                state <= IDLE;
            end
        endcase
    end
end

////////////C_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        C_reg <= 256'b0;
    end
    else if (state == START) begin
        C_reg <= data_reg;
    end
    else if ((state == CAL_1 || state == CAL_2) && mul_mod_finish) begin
        C_reg <= wire_out;
    end
    else begin
        C_reg <= C_reg;
    end
end

////////////data_reg, key_reg, N_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        data_reg <= 256'b0;
        key_reg <= 256'b0;
        N_reg <= 256'b0;
    end
    else begin
        case(state)
            LOAD_DATA: begin
                data_reg <= {data_reg[223:0], data};
            end
            LOAD_KEY: begin
                key_reg <= {key_reg[223:0], data};
            end
            LOAD_N: begin
                N_reg <= {N_reg[223:0], data};
            end
            default: begin
                data_reg <= data_reg;
                key_reg <= key_reg;
                N_reg <= N_reg;
            end
        endcase
    end
end

///////////counter///////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        counter <= 3'b0;
    end
    else if (state == LOAD_DATA || state == LOAD_KEY || state == LOAD_N || state == OUTPUT) begin
        counter <= counter + 3'b1;
    end
    else begin
        counter <= 3'b0;
    end
end


////////////i////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        i <= 9'd256;
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

////////////output_flag////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        output_flag <= 1'b0;
    end
    else if (state == OUTPUT) begin
        output_flag <= 1'b1;
    end
    else begin
        output_flag <= 1'b0;
    end
end


////////////////out/////////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n || state == IDLE) begin
        out <= 32'b0;
    end
    else if (state == OUTPUT) begin
        case (counter)
            3'b000: out <= C_reg[255:224];
            3'b001: out <= C_reg[223:192];
            3'b010: out <= C_reg[191:160];
            3'b011: out <= C_reg[159:128];
            3'b100: out <= C_reg[127:96];
            3'b101: out <= C_reg[95:64];
            3'b110: out <= C_reg[63:32];
            3'b111: out <= C_reg[31:0];
        endcase
    end
    else begin
        out <= 32'b0;
    end
end

////////////mul_mod////////////
Mul_mod #(
    .k(0)
)u_mul_mod
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