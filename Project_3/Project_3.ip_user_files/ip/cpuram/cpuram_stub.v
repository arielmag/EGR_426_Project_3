// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Wed Apr 10 21:43:22 2019
// Host        : LAPTOP-VHI018SI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/ariel/OneDrive/Documents/GitHub/EGR_426_Project_3/Project_3/Project_3.srcs/sources_1/ip/cpuram/cpuram_stub.v
// Design      : cpuram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module cpuram(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[8:0],dina[7:0],douta[7:0]" */;
  input clka;
  input [0:0]wea;
  input [8:0]addra;
  input [7:0]dina;
  output [7:0]douta;
endmodule
