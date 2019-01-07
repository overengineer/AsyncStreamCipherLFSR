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
// Module : TEST
// Author : Alper Said Soylu
// Date   : 12/27/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module TEST;

reg clk, res, start, conf;
reg [7:0] data_in;
reg [7:0] address_in;
wire done, valid, busy;
wire [7:0] data_out;

// Instantiate the module
TOP instance_name (
    .clk(clk), 
    .res(res), 
    .start(start), 
    .conf(conf), 
    .data_in(data_in), 
    .address_in(address_in), 
    .done(done), 
    .valid(valid), 
    .busy(busy), 
    .data_out(data_out)
    );
	 
always begin
	clk = ~clk;
	#5;
end

parameter RESET  = 3'h0;
parameter CONF   = 3'h1;
parameter DATA   = 3'h2;
parameter FINISH = 3'h3;
parameter IDLE   = 3'h4;

initial begin
	clk   = 0;
	res   = 0;
	start = 0;
	conf  = 0;
	state = RESET;
end

reg [2:0] state;
reg [7:0] data;

always @( posedge clk ) begin
	case(state) 
		RESET: begin
			res   <= 1;
			state <= IDLE;
			address_in <= 8'h00;
			data_in    <= 8'h12;
		end
		IDLE: begin
			res <= 0;
			if ( ~busy ) begin 
				state <= CONF;
				conf  <= 1;
			end
		end
		CONF: begin
			data_in    <= address_in;
			address_in <= address_in + 1;
			if ( address_in == 8'hFF ) begin
				state <= DATA;
				conf <= 0;
			   start <= conf;
			end
		end
		DATA: begin
			if ( valid ) data <= data_out;
			if ( done ) state <= FINISH;
		end
		FINISH: begin
		end
	endcase
end

endmodule
