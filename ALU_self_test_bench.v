`timescale 1ns/1ns
`include "ALU_design.v"

module ALU_test;

  parameter WIDTH_O = 8;
  parameter WIDTH_C = 4;
  parameter WIDTH_RES = 2 * WIDTH_O;

  reg signed [WIDTH_O-1:0] OPA_1, OPB_1;
  reg CIN, CLK, RST, CE, MODE;
  reg [1:0] INP_VALID;
  reg [WIDTH_C-1:0] CMD;

  wire signed [WIDTH_RES:0] RES;
  wire COUT, OFLOW, G, E, L, ERR;

  ALU_design #(.WIDTH_O(WIDTH_O), .WIDTH_C(WIDTH_C)) dut (
    .OPA_1(OPA_1), .OPB_1(OPB_1), .CIN(CIN), .CLK(CLK), .RST(RST),
    .CMD(CMD), .CE(CE), .MODE(MODE), .INP_VALID(INP_VALID),
    .RES(RES), .COUT(COUT), .OFLOW(OFLOW), .G(G), .E(E), .L(L), .ERR(ERR)
  );

  initial CLK = 0;
  always #5 CLK = ~CLK;

  initial begin
    /* Reset */
    RST = 1; CE = 0; #10;
    RST = 0;

    /* ARITHMETIC TESTS */
    MODE = 1'b1;
    CIN = 1;
    INP_VALID = 2'b11;
    CE = 1;
    #5;
    CMD = 4'd0;  OPA_1 = 8'd255; OPB_1 = 8'd255; #10;  /* ADD*/
    CMD = 4'd1;  OPA_1 = 8'd40;  OPB_1 = 8'd20;  #10;  /* SUB*/
    CMD = 4'd1;  OPA_1 = 8'd20;  OPB_1 = 8'd40;  #10;
    CMD = 4'd2;  OPA_1 = 8'd10;  OPB_1 = 8'd20;  #10;  /* ADD_CIN*/
    CMD = 4'd3;  OPA_1 = 8'd50;  OPB_1 = 8'd20;  #10;  /* SUB_CIN*/
    CMD = 4'd4;  OPA_1 = 8'd55;  OPB_1 = 8'd0;   #10;  /* INC_A*/
    CMD = 4'd5;  OPA_1 = 8'd55;  OPB_1 = 8'd0;   #10;  /* DEC_A*/
    CMD = 4'd6;  OPA_1 = 8'd0;   OPB_1 = 8'd23;  #10;  /* INC_B*/
    CMD = 4'd7;  OPA_1 = 8'd0;   OPB_1 = 8'd23;  #10;  /* DEC_B*/
    CMD = 4'd8;  OPA_1 = 8'd23;  OPB_1 = 8'd23;  #10;
    CMD = 4'd9;  OPA_1 = 8'd7;   OPB_1 = 8'd5;   #10;  /* INC and MULT*/
    CMD = 4'd9;  OPA_1 = 8'd128; OPB_1 = 8'd5;   #10;
    CMD = 4'd10; OPA_1 = 8'd4;   OPB_1 = 8'd5;   #10;  /* SHL and MULT*/
    CMD = 4'd10; OPA_1 = 8'd128; OPB_1 = 8'd5;   #10;
    CMD = 4'd11; OPA_1 = 8'd50;  OPB_1 = 8'd25;  #10;  /* ADD_COND*/
    CMD = 4'd11; OPA_1 = 8'd127; OPB_1 = 8'd1;   #10;
    CMD = 4'd11; OPA_1 = 8'd50;  OPB_1 = -8'sd25;#10;
    CMD = 4'd11; OPA_1 = -8'sd120; OPB_1 = -8'sd25; #10;
    CMD = 4'd12; OPA_1 = 8'd40;  OPB_1 = 8'd10;  #10;  /* SUB_COND*/
    CMD = 4'd12; OPA_1 = 8'd10;  OPB_1 = 8'd40;  #10;
    CMD = 4'd12; OPA_1 = 8'd50;  OPB_1 = -8'sd25;#10;
    CMD = 4'd12; OPA_1 = -8'sd30; OPB_1 = -8'sd25; #10;

    /* LOGIC TESTS */
    MODE = 1'b0;
    INP_VALID = 2'b11;
    CE = 1;

    CMD = 4'd0;  OPA_1 = 8'b10101010; OPB_1 = 8'b11001100; #10;  /* AND*/
    CMD = 4'd1;  OPA_1 = 8'b10101010; OPB_1 = 8'b11001100; #10;  /* NAND*/
    CMD = 4'd2;  OPA_1 = 8'b10101010; OPB_1 = 8'b11001100; #10;  /* OR*/
    CMD = 4'd3;  OPA_1 = 8'b10101010; OPB_1 = 8'b11001100; #10;  /* NOR*/
    CMD = 4'd4;  OPA_1 = 8'b10101010; OPB_1 = 8'b11001100; #10;  /* XOR*/
    CMD = 4'd5;  OPA_1 = 8'b10101010; OPB_1 = 8'b11001100; #10;  /* XNOR*/
    CMD = 4'd6;  OPA_1 = 8'b10101010; OPB_1 = 8'b00000000; #10;  /* NOT_A*/
    CMD = 4'd7;  OPA_1 = 8'b00000000; OPB_1 = 8'b11001100; #10;  /* NOT_B*/
    CMD = 4'd8;  OPA_1 = 8'b10000000; OPB_1 = 8'b00000000; #10;  /* SHR1_A*/
    CMD = 4'd9;  OPA_1 = 8'b00000001; OPB_1 = 8'b00000000; #10;  /* SHL1_A*/
    CMD = 4'd10; OPA_1 = 8'b00000000; OPB_1 = 8'b10000000; #10;  /* SHR1_B*/
    CMD = 4'd11; OPA_1 = 8'b00000000; OPB_1 = 8'b00000001; #10;  /* SHL1_B*/
    CMD = 4'd12; OPA_1 = 8'b00101011; OPB_1 = 8'b00000001; #10;  /* ROL_A_B*/
    CMD = 4'd12; OPA_1 = 8'b01111101; OPB_1 = 8'b00010001; #10;
    CMD = 4'd13; OPA_1 = 8'b01111101; OPB_1 = 8'b00000100; #10;  /* ROR_A_B*/
    CMD = 4'd13; OPA_1 = 8'b01111101; OPB_1 = 8'b00001001; #10;

    $stop;
  end

endmodule
