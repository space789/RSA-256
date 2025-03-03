`timescale 1ns / 1ps
// S = A * B mod N
module Mul_mod #(
    parameter k = 0 // k = 0, 1, 2 to adjust data width
)
(
    // global
    input clk,
    input rst_n,

    // data
    input wire  [255: 0] A, B, N,
    output reg [255: 0] S,
    
    // control
    input wire enable,
    output reg finish
);

///////////parameter////////////
localparam IDLE = 3'd0;
localparam START = 3'd1;
localparam CAL = 3'd2;
localparam ADJUST_C_1 = 3'd3;
localparam ADJUST_C_2 = 3'd4;
localparam FINISH = 3'd5;


////////////reg////////////
reg [2: 0] state;

reg [257: 0] DB_reg;
reg [264: 0] C_reg; // worst case DB_reg * 256 = 2^256 * 2^8 = 2^264 and 1 bit for sign
reg [7: 0] i; // counter 1 to 255

reg [257: 0] DB_in_reg;
reg [257: 0] not_n_reg;

////////////wire////////////
// wire [257: 0] wire_DB_in; // DB = 2 * DB_reg
// wire [257: 0] wire_not_n; // not_n = ~N
wire [257: 0] wire_DB_S; // S =  2 * DB - N

wire [264: 0] wire_C_DB; // C = C + DB_reg
wire [264: 0] wire_C_not_n; // C = C - N
wire [264: 0] wire_C_in; // C = C + DB_reg or C = C - N
wire [264: 0] wire_C_out;


////////////assign////////////
// assign wire_DB_in = DB_reg << 1;
// assign wire_not_n = ~{2'b0, N} + 1'b1;

assign wire_C_DB = {7'b0, DB_reg};
assign wire_C_not_n = ~{{9'b0, N} << k} + 1'b1;
assign wire_C_in = state == CAL ? (B[i] ? wire_C_DB : ((~C_reg[264] & |C_reg) ? wire_C_not_n : 265'b0)) :
                   state == ADJUST_C_1 ? wire_C_not_n : {9'b0, N};


/////////////state/////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;
    end
    else begin
        case(state)
            IDLE: begin
                state <= enable ? START : IDLE;
            end
            START: begin
                state <= enable ? CAL : IDLE;
            end
            CAL: begin
                state <= enable ? (i == 8'd255 ? ADJUST_C_1 : CAL) : IDLE;
            end
            ADJUST_C_1: begin
                state <= enable ? (wire_C_out[264] ? ADJUST_C_2 : ADJUST_C_1) : IDLE;
            end
            ADJUST_C_2: begin
                state <= enable ? (wire_C_out[264] ? ADJUST_C_2 : FINISH) : IDLE;
            end
            FINISH: begin
                state <= IDLE;
            end
        endcase
    end
end

////////////DB_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        DB_reg <= 258'b0;
    end
    else if (state == START) begin
        DB_reg <= A;
    end
    else if (state == CAL) begin
        DB_reg <= wire_DB_S[257] ? DB_in_reg : wire_DB_S;
    end
    else begin
        DB_reg <= 258'b0;
    end
end

////////////C_reg////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        C_reg <= 265'b0;
    end
    else if (state == START) begin
        C_reg <= 265'b0;
    end
    else if (state == CAL || state == ADJUST_C_1 || state == ADJUST_C_2) begin
        C_reg <= wire_C_out;
    end
    else begin
        C_reg <= C_reg;
    end
end

////////////i////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        i <= 8'd0;
    end
    else if (state == CAL) begin
        i <= i + 8'd1;
    end
    else begin
        i <= 8'd0;
    end
end

////////////S////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        S <= 256'b0;
    end
    else if (state == FINISH) begin
        S <= C_reg[255:0];
    end
    else begin
        S <= 256'b0;
    end
end

///////////////DB_in_reg///////////
always @(*) begin
    DB_in_reg = DB_reg << 1;
end

///////////////not_n_reg///////////
always @(*) begin
    not_n_reg = ~{2'b0, N} + 1'b1;
end

////////////finish////////////
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        finish <= 1'b0;
    end
    else if (state == FINISH) begin
        finish <= 1'b1;
    end
    else begin
        finish <= 1'b0;
    end
end


//////////////CSA//////////////
CSA258 csa258_0(.A(DB_in_reg), .B(not_n_reg), .Cin(1'b0), .S(wire_DB_S), .Pout(), .Cout());
CSA265 csa265_0(.A(C_reg), .B(wire_C_in), .Cin(1'b0), .S(wire_C_out), .Pout(), .Cout());
    

endmodule