`timescale 1ns/1ns
module ALU_design(OPA_1,OPB_1,CIN,CLK,RST,CMD,CE,MODE,INP_VALID,COUT,OFLOW,RES,G,E,L,ERR);

    parameter WIDTH_O = 8;
    parameter WIDTH_C = 4;
    parameter WIDTH_RES = 2 * WIDTH_O;

    input [WIDTH_O-1:0] OPA_1, OPB_1;
    input CLK, RST, CE, MODE, CIN;
    input [WIDTH_C-1:0] CMD;
    input [1:0]INP_VALID;
    output reg signed [WIDTH_RES-1:0] RES = 'b0;
    output reg COUT = 1'b0;
    output reg OFLOW = 1'b0;
    output reg G = 1'b0;
    output reg E = 1'b0;
    output reg L = 1'b0;
    output reg ERR = 1'b0;

    reg [WIDTH_O-1:0] OPA, OPB;
    integer shift;//for ROR and ROL
    reg signed [WIDTH_RES-1:0] RES_temp;
    reg COUT_temp, OFLOW_temp, G_temp, E_temp, L_temp, ERR_temp;
    reg [WIDTH_O-1:0]OPA_2,OPB_2;

    always@(posedge CLK or posedge RST)begin  /*delay by one clock cycle except for multiplication command*/
        if (RST) begin
            OPA <= 0;
            OPB <= 0;
        end else begin
            OPA <= OPA_1;
            OPB <= OPB_1;
        end
    end

    always @(posedge CLK) begin
        case (CMD)
            4'b1001: begin
                OPA_2 = OPA + 1;
                OPB_2 = OPB + 1;
            end
            4'b1010: begin
                OPA_2 = OPA << 1;
                OPB_2 = OPB;
            end
            default: begin
                OPA_2 = OPA;
                OPB_2 = OPB;
            end
        endcase
    end


  /* Output update with 1 clock cycle delay */
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            RES   <= 0;
            COUT  <= 0;
            OFLOW <= 0;
            G     <= 0;
            E     <= 0;
            L     <= 0;
            ERR   <= 0;
        end else if (CE) begin
            RES   <= RES_temp;
            COUT  <= COUT_temp;
            OFLOW <= OFLOW_temp;
            G     <= G_temp;
            E     <= E_temp;
            L     <= L_temp;
            ERR   <= ERR_temp;
        end
    end

always @(*) begin
    if (RST) begin
        RES_temp   = {WIDTH_RES+1{1'b0}};
        COUT_temp  = 1'b0;
        OFLOW_temp = 1'b0;
        G_temp     = 1'b0;
        E_temp     = 1'b0;
        L_temp     = 1'b0;
        ERR_temp   = 1'b0;
    end 
    else if (CE) begin
        RES_temp   = {WIDTH_RES+1{1'b0}};
        COUT_temp  = 1'b0;
        OFLOW_temp = 1'b0;
        G_temp     = 1'b0;
        E_temp     = 1'b0;
        L_temp     = 1'b0;
        ERR_temp   = 1'b0;

        if (MODE == 1'b1) begin
		RES_temp = {WIDTH_RES+1{1'b0}};
                COUT_temp = 1'b0;
                OFLOW_temp = 1'b0;
                G_temp = 1'b0;
                E_temp = 1'b0;
                L_temp = 1'b0;
                ERR_temp = 1'b0;
            if (INP_VALID == 2'b11) begin
                    case (CMD)
                    4'b0000:/*ADD*/
                    begin
                        RES_temp[WIDTH_O-1:0] = OPA + OPB;
                        COUT_temp = RES_temp[WIDTH_O] ? 1 : 0;
                    end
                    4'b0001:/*SUB*/
                    begin
                        OFLOW_temp = (OPA < OPB) ? 1 : 0;
                        RES_temp = OPA - OPB;
                    end
                    4'b0010:/*ADD_CIN*/
                    begin
                        RES_temp = OPA + OPB + CIN;
                        COUT_temp = RES_temp[WIDTH_O] ? 1 : 0;
                    end
                    4'b0011:/*SUB_CIN*/
                    begin
                        OFLOW_temp = (OPA < OPB) ? 1 : 0;
                        RES_temp = OPA - OPB - CIN;
                    end
                       4'b0100:
                       begin
                           RES_temp = OPA + 1;              /*INC_A*/
                           OFLOW_temp = RES_temp[WIDTH_O] ? 1 : 0;
                       end
                   4'b0101:
                       begin
                        RES_temp = OPA - 1;              /*DEC_A*/
                           OFLOW_temp = (OPA < 1'b1) ? 1 : 0;
                       end
                       4'b0110:
                       begin
                           RES_temp = OPB + 1;             /*INC_B*/
                           OFLOW_temp = RES_temp[WIDTH_O] ? 1 : 0;
                       end
                   4'b0111:
                   begin
                           RES_temp = OPB - 1;             /*DEC_B*/
                           OFLOW_temp = (OPB < 1'b1) ? 1 : 0;
                   end
                   4'b1000:/*CMP*/
                   begin
                        RES_temp = {WIDTH_O+1{1'b0}};
                        if (OPA == OPB)
                        begin
                            E_temp = 1'b1;
                            G_temp = 1'b0;
                            L_temp = 1'b0;
                        end
                        else if (OPA > OPB)
                        begin
                            E_temp = 1'b0;
                            G_temp = 1'b1;
                            L_temp = 1'b0;
                        end
                        else
                        begin
                            E_temp = 1'b0;
                            G_temp = 1'b0;
                            L_temp = 1'b1;
                        end
                   end
                   4'b1001:/*increment and multiply*/
                   begin
                        RES_temp = OPA_2 * OPB_2;
                        COUT_temp = RES_temp[WIDTH_O] ? 1 : 0;
                   end
                   4'b1010:/*shift left A and multiply with B*/
                   begin
                        RES_temp = OPA_2 * OPB_2;
                        COUT_temp = RES_temp[WIDTH_O] ? 1 : 0;
                   end
                   4'b1011:/*ADD_CONDITION_SIGNED*/
                   begin
                        RES_temp = $signed(OPA) + $signed(OPB);
                        COUT_temp =  RES_temp[WIDTH_O] ? 1 : 0;
                        OFLOW_temp = (~(OPA[WIDTH_O-1] ^ OPB[WIDTH_O-1])) & (OPA[WIDTH_O-1] ^ RES_temp[WIDTH_O-1]);
                        E_temp = (RES_temp == 0) ? 1 : 0;
                        G_temp = (RES_temp > 0) ? 1 : 0;
                        L_temp = (RES_temp < 0) ? 1 : 0;
                   end
                   4'b1100:/*SUB_CONDITION_SIGNED*/
                   begin

                        RES_temp = $signed(OPA) - $signed(OPB);
                        COUT_temp =  (OPA < OPB) ? 1 : 0;
                        OFLOW_temp =(OPA[WIDTH_O-1] != OPB[WIDTH_O-1]) && (RES_temp[WIDTH_O-1] != OPA[WIDTH_O-1]);
                        E_temp = (RES_temp == 0) ? 1 : 0;
                        G_temp = (RES_temp > 0) ? 1 : 0;
                        L_temp = (RES_temp < 0) ? 1 : 0;
                   end
                   default:
                   begin
                        RES_temp = 'b0;
                        COUT_temp = 1'b0;
                        OFLOW_temp = 1'b0;
                        G_temp = 1'b0;
                        E_temp = 1'b0;
                        L_temp = 1'b0;
                        ERR_temp = 1'b1;
                   end
                   endcase
               end  
            else if (INP_VALID == 2'b01) begin
                       case(CMD)
                       4'b0100:
                       begin
                           RES_temp = OPA + 1;              /*INC_A*/
                           OFLOW_temp = RES_temp[WIDTH_O] ? 1 : 0;
                       end
                       4'b0101:
                       begin
                        RES_temp = OPA - 1;               /*DEC_A*/
                            OFLOW_temp = (OPA < 1'b1) ? 1 : 0;
                       end
                       endcase
            end
            else if (INP_VALID == 2'b10) begin
                      case(CMD)
                       4'b0110:
                       begin
                           RES_temp = OPB + 1;             /*INC_B*/
                           OFLOW_temp = RES_temp[WIDTH_O] ? 1 : 0;
                       end
                       4'b0111:
                       begin
                           RES_temp = OPB - 1;            /*DEC_B*/
                           OFLOW_temp = (OPB < 1'b1) ? 1 : 0;
                       end
                       endcase
            end
            else begin
                ERR_temp = 1'b1;
            end
        end 
        else if (MODE == 1'b0) begin
                    RES_temp = 'b0;
                    COUT_temp = 1'b0;
                    OFLOW_temp = 1'b0;
                    G_temp = 1'b0;
                    E_temp = 1'b0;
                    L_temp = 1'b0;
                    ERR_temp = 1'b0;
                    case (CMD)
                        4'b0000: RES_temp = {1'b0, OPA & OPB};/*AND*/
                        4'b0001: RES_temp = {1'b0, ~(OPA & OPB)};/*NAND*/
                        4'b0010: RES_temp = {1'b0, OPA | OPB};/*OR*/
                        4'b0011: RES_temp = {1'b0, ~(OPA | OPB)};/*NOR*/
                        4'b0100: RES_temp = {1'b0, OPA ^ OPB};/*XOR*/
                        4'b0101: RES_temp = {1'b0, ~(OPA ^ OPB)};/*XNOR*/
                        4'b0110: RES_temp = {1'b0, ~OPA};/*NOT_A*/
                        4'b0111: RES_temp = {1'b0, ~OPB};/*NOT_B*/
                        4'b1000: RES_temp = {1'b0, OPA >> 1};/*SHR1_A*/
                        4'b1001: RES_temp = {1'b0, OPA << 1};/*SHL1_A*/
                        4'b1010: RES_temp = {1'b0, OPB >> 1};/*SHR1_B*/
                        4'b1011: RES_temp = {1'b0, OPB << 1};/*SHL1_B*/
                        4'b1100:/*ROL_A_B*/
                        begin
                            shift = OPB % WIDTH_O;
                            RES_temp = {1'b0, (OPA << shift) | (OPA >> (WIDTH_O - shift))};
                            if (|OPB[WIDTH_O-1:4])
                                ERR_temp = 1'b1;
                            else
                                ERR_temp = 1'b0;
                        end
                        4'b1101:/*ROR_A_B*/
                        begin
                            shift = OPB % WIDTH_O;
                            RES_temp = {1'b0, (OPA >> shift) | (OPA << (WIDTH_O - shift))};
                            if (|OPB[WIDTH_O-1:4])
                                ERR_temp = 1'b1;
                            else
                                ERR_temp = 1'b0;
                        end
                        default:
                        begin
                            RES_temp = 'b0;
                            COUT_temp = 1'b0;
                            OFLOW_temp = 1'b0;
                            G_temp = 1'b0;
                            E_temp = 1'b0;
                            L_temp = 1'b0;
                            ERR_temp = 1'b1;
                        end
                    endcase

        end
    end 
    else begin
        RES_temp   = 'b0;
        COUT_temp  = 1'b0;
        OFLOW_temp = 1'b0;
        G_temp     = 1'b0;
        E_temp     = 1'b0;
        L_temp     = 1'b0;
        ERR_temp   = 1'b0;
    end
end
endmodule




