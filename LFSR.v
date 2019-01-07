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
// Project: 
//   SELF-SYNCHRONIZING STREAM CIPHER WITH LINEAR FEEDBACK SHIFT REGISTER
//
// Module : LFSR
// Author : Alper Said Soylu
// Date   : 12/27/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module LFSR(
    input clk,
    input res,
	 input valid,
    input [7:0] seed,
    output [7:0] keystream
    );
	 reg [7:0] state;
	 wire [7:0] next, feed, shifted;
	 wire msb;
	 
	 assign shifted   = state >> 1; 
	 assign next      = {msb, shifted[6:0]};
	 assign feed      = state | seed;
	 assign msb       = feed[0]^feed[2]^feed[3]^feed[4];
	 assign keystream = state;
	 
	 always @(posedge clk, posedge res) begin
		if (res) begin
			state = seed;
		end else if ( valid ) begin
			state = next;	
		end
	 end
endmodule
