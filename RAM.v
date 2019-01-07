//////////////////////////////////////////////////////////////////////////////////
// MIT License
// 
// Copyright © 2018 Alper Said Soylu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in 
// the Software without restriction, including without limitation the rights to 
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do 
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all 
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//////////////////////////////////////////////////////////////////////////////////
//
// Module : RAM
// Author : Alper Said Soylu
// Date   : 12/27/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module RAM #(
		parameter DATA_WIDTH = 8,
		parameter ADDRESS_WIDTH = 8
		)(clk,res,wren,address,datain,dataout);
input clk; 
input res; 
input wren;
input [ADDRESS_WIDTH-1:0] address;
input [DATA_WIDTH-1:0] datain;
output [DATA_WIDTH-1:0] dataout;

parameter depth = 1 << ADDRESS_WIDTH;

reg [DATA_WIDTH-1:0] memory[depth-1:0];
integer i;

assign dataout = memory[address];

always @(posedge clk or posedge res) begin
	if ( res ) begin
		for(i=0;i<depth;i=i+1) begin
			memory[i] <= 0;
		end
	end else begin
		if ( wren ) begin
			memory[address] <= datain;
		end
	end
end
endmodule
