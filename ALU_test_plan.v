`timescale 1ns/1ns
`include "ALU_design.v"
 
/* defines */
`define PASS 1'b1
`define FAIL 1'b0
`define no_of_testcase 114
 
module test_bench_alu();
        reg [55:0] curr_test_case = 56'b0;
        reg [55:0] stimulus_mem [0:`no_of_testcase-1];
        reg [78:0] response_packet;
 
/* Test bench for ALU design*/
    parameter WIDTH_O = 8;
    parameter WIDTH_C = 4;
    parameter WIDTH_RES = 2 * WIDTH_O;
 
 
/*Decl for giving the Stimulus*/
        integer i,j;
        reg CLK,RST,CE; /*inputs*/
        event fetch_stimulus;
        reg [WIDTH_O-1:0]OPA,OPB; /*inputs*/
        reg [WIDTH_C-1:0]CMD; /*inputs*/
        reg MODE,CIN; /*inputs*/
        reg [7:0] Feature_ID;
        reg [2:0] Comparison_EGL;          /*expected output*/
        reg [WIDTH_RES-1:0] Expected_RES;    /*expected output data*/
        reg err,cout,ov;
        reg [1:0] INP_VALID;
        /*reg [1:0] res1;*/
 
/*Decl to Cop UP the DUT OPERATION*/
        wire [WIDTH_RES-1:0] RES;
        wire ERR,OFLOW,COUT;
        wire [2:0]EGL;
        wire [21:0] expected_data;
        reg  [21:0] exact_data;
 
/*READ DATA FROM THE TEXT VECTOR FILE*/
        task read_stimulus();
                begin
                #10 $readmemb ("stimulus.txt",stimulus_mem);
               end
        endtask
 
ALU_design #(.WIDTH_O(WIDTH_O), .WIDTH_C(WIDTH_C))inst_dut (.OPA_1(OPA),.OPB_1(OPB),.CIN(CIN),.CLK(CLK),.CMD(CMD),.CE(CE),.MODE(MODE),
                      .COUT(COUT),.OFLOW(OFLOW),.RES(RES),.G(EGL[1]),.E(EGL[2]),.L(EGL[0]),.ERR(ERR),
                      .RST(RST),.INP_VALID(INP_VALID));
 
/*STIMULUS GENERATOR*/
 
integer stim_mem_ptr = 0,stim_stimulus_mem_ptr = 0,fid =0 , pointer =0 ;
 
        always@(fetch_stimulus)
                begin
                        curr_test_case=stimulus_mem[stim_mem_ptr];
                        $display ("stimulus_mem data = %0b \n",stimulus_mem[stim_mem_ptr]);
                        $display ("packet data = %0b \n",curr_test_case);
                        stim_mem_ptr=stim_mem_ptr+1;
                end
 
/*INITIALIZING CLOCK*/
        initial
                begin CLK=0;
                        forever #60 CLK=~CLK;
                end
 
 
/*DRIVER MODULE*/
        task driver ();
                begin
                  ->fetch_stimulus;
                  @(posedge CLK);
                  Feature_ID    =curr_test_case[55:48];
                  RST           =curr_test_case[47];
                  INP_VALID     =curr_test_case[46:45];
                  OPA           =curr_test_case[44:37];
                  OPB           =curr_test_case[36:29];
                  CMD           =curr_test_case[28:25];
                  CIN           =curr_test_case[24];
                  CE            = curr_test_case[23];
                  MODE          =curr_test_case[22];
                  Expected_RES  =curr_test_case[21:6];
                  cout          =curr_test_case[5];
                  Comparison_EGL=curr_test_case[4:2];
                  ov            =curr_test_case[1];
                  err           =curr_test_case[0];
                 $display("At time (%0t), Feature_ID = %8d, RST= %1b, INP_VALID = %2b, OPA = %8b, OPB = %8b, CMD = %4b, CIN = %1b, CE = %1b, MODE = %1b, expected_result = %16b, cout = %1b, Comparison_EGL = %3b, ov = %1b, err = %1b",$time,Feature_ID,RST,INP_VALID,OPA,OPB,CMD,CIN,CE,MODE, Expected_RES,cout,Comparison_EGL,ov,err);
                end
        endtask
 
/*GLOBAL DUT RESET*/
        task dut_reset ();
                begin
                CE=1;
                #10 RST=1;
                #20 RST=0;
                end
        endtask
 
/*GLOBAL INITIALIZATION*/
        task global_init ();
                begin
                curr_test_case=56'b0;
                response_packet=78'b0;
                stim_mem_ptr=0;
                end
        endtask
 
 
/*MONITOR PROGRAM*/
task monitor ();
                begin
                repeat(2)@(posedge CLK);
                #5 response_packet[55:0]=curr_test_case;
                response_packet[56]     =ERR;
                response_packet[57]     =OFLOW;
                response_packet[60:58]  ={EGL};
                response_packet[61]     =COUT;
                response_packet[77:62]  =RES;
                /*response_packet[63]   =0;  Reserved Bit*/
                $display("Monitor: At time (%0t), RES = %16b, COUT = %1b, EGL = %3b, OFLOW = %1b, ERR = %1b",$time,RES,COUT,{EGL},OFLOW,ERR);
                exact_data ={RES,COUT,{EGL},OFLOW,ERR};
                end
        endtask
 
assign expected_data = {Expected_RES,cout,Comparison_EGL,ov,err};
 
 
/*SCORE BOARD PROGRAM TO CHECK THE DUT OP WITH EXPECTD OP*/
 
   reg [55:0] scb_stimulus_mem [0:`no_of_testcase-1];
 
task score_board();
   reg [21:0] expected_res;
   reg [7:0] feature_id;
   reg [21:0] response_data;
        begin
                #5;
                feature_id      = curr_test_case[55:48];
                expected_res    = curr_test_case[21:6];
                response_data   = response_packet[77:56];
                $display("expected result = %22b ,response data = %22b",expected_data,exact_data);
                 if(expected_data === exact_data)
                     scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0,feature_id, expected_res,response_data, 1'b0,`PASS};
                 else
                     scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0,feature_id, expected_res,response_data, 1'b0,`FAIL};
            stim_stimulus_mem_ptr = stim_stimulus_mem_ptr + 1;
        end
endtask
 
 
/*Generating the report `no_of_testcase-1*/
task gen_report;
integer file_id,pointer;
reg [54:0] status;
                begin
                   file_id = $fopen("results.txt", "w");
                   for(pointer = 0; pointer <= `no_of_testcase-1 ; pointer = pointer+1 )
                   begin
                     status = scb_stimulus_mem[pointer];
                     if(status[0])
                       $fdisplay(file_id, "Feature ID %8d : PASS", status[53:46]);
                     else
                       $fdisplay(file_id, "Feature ID %8d : FAIL", status[53:46]);
                   end
                end
endtask
 
 
initial
               begin
                #10;
                global_init();
                dut_reset();
                read_stimulus();
                for(j=0;j<=`no_of_testcase-1;j=j+1)
                begin
                        fork
                          driver();
                          monitor();
                         join
                        score_board();
               end
 
               gen_report();
               $fclose(fid);
               #300 $finish();
               end
endmodule
