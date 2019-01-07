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
// Module : TOP
// Author : Alper Said Soylu
// Date   : 12/27/2018 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module TOP(
		input clk, res, start, conf,
		input [7:0] data_in,
		input [7:0] address_in,
		output reg done, busy,
		output valid,
		output [7:0] data_out
    );
	 
//submodule input registers
reg pico_res;

//submodule IO wires
wire ram_wren, ram_res;
wire [7:0] ram_dataout, ram_datain, ram_address;
wire [7:0] lfsr_out, lfsr_in;
wire lfsr_valid,lfsr_res;
wire 	[9:0]	 instr_address ;
wire 	[17:0] instruction ;
wire 	[7:0]	 port_id ;
wire 	write_strobe, read_strobe, interrupt_ack, interrupt ;
wire [7:0] in_port, out_port ;


//submodule instantiations
LFSR lfsr_inst (
    .clk(clk), 
    .res(lfsr_res), 
    .valid(lfsr_valid),  
    .seed(lfsr_in), 
    .keystream(lfsr_out)
    );
	 
RAM  #(.DATA_WIDTH(8),.ADDRESS_WIDTH(8)) ram_inst (
    .clk(clk), 
    .res(ram_res), 
    .wren(ram_wren), 
    .address(ram_address), 
    .datain(ram_datain),
	 .dataout(ram_dataout)
    );

kcpsm3 pico_inst (
    .address(instr_address), 
    .instruction(instruction), 
    .port_id(port_id), 
    .write_strobe(write_strobe), 
    .out_port(out_port), 
    .read_strobe(read_strobe), 
    .in_port(in_port), 
    .interrupt(interrupt), 
    .interrupt_ack(interrupt_ack), 
    .reset(pico_res), 
    .clk(clk)
    );
	 
// Instantiate the module
SSSC instr_memory (
    .address(instr_address), 
    .instruction(instruction), 
    .clk(clk)
    );

//state labels
parameter DATA_WRITE 	 = 3'b000;
parameter IDLE				 = 3'b001;
parameter START			 = 3'b011; 
parameter PUBKEY_READ	 = 3'b010; 
//
parameter PUBKEY_STORE	 = 3'b110; 
parameter DATA_READ		 = 3'b111;
parameter KEYSTREAM_READ = 3'b101;
parameter CIPHER_OUT		 = 3'b100;

//state register
reg [7:0] state;
wire last;

//state logic
always @( posedge clk or posedge res ) begin
	if ( res ) begin
		state <= IDLE;
	end else begin
		case(state)
			DATA_WRITE		: if ( ~conf ) state <= IDLE;
			IDLE				: begin
				if ( pico_res ) begin // ensuring to reset picoblaze two clock cycles
					state <= START;
				end else	if ( conf & ~start ) begin
					state <= DATA_WRITE;
				end
			end
			START				: if ( read_strobe  ) state <= PUBKEY_READ;
			PUBKEY_READ		: if ( write_strobe ) state <= CIPHER_OUT;
			PUBKEY_STORE	: if ( read_strobe  ) state <= DATA_READ; //removed
			DATA_READ		: if ( read_strobe ) state <= KEYSTREAM_READ;
			KEYSTREAM_READ : if ( write_strobe  ) state <= CIPHER_OUT;
			CIPHER_OUT : begin
				if ( last ) begin
					state <= IDLE;//BUG
				end else if ( read_strobe ) begin
					state <= DATA_READ;
				end
			end
		endcase
	end
end

//continious assignments
assign interrupt    = 0;
assign ram_datain   = data_in;
assign ram_res		  = 0;
assign last         = ( port_id == 8'hFF );
assign ram_wren     = conf & ~busy;
assign ram_address  = ram_wren ? address_in : port_id;
assign lfsr_in      = out_port;
assign lfsr_valid   = write_strobe;
assign lfsr_res     = ( state == PUBKEY_READ ) & lfsr_valid;
assign data_out     = out_port;
assign valid        = ( state == KEYSTREAM_READ ) & write_strobe;

parameter RAM = 0, LFSR = 1;
reg select_input;
assign in_port = ( select_input == RAM ) ? ram_dataout : lfsr_out;

//IO logic
always @( posedge clk or posedge res ) begin
	if ( res ) begin
		pico_res      <= 0;
		busy		     <= 1;
		done          <= 0;
	end else begin
		case(state)
			IDLE				: begin
				busy		     <= 0;
				done          <= 0;
				pico_res      <= start;
				if ( pico_res ) begin				
					pico_res      <= 0;
					busy		     <= 1;
					select_input  <= RAM;	
				end
			end
			START				: begin
				if ( read_strobe ) begin
					pico_res      <= 0;
				end
			end
			DATA_READ		: begin		
					select_input  <= LFSR;	
				if ( read_strobe ) begin
					done          <= last;
				end
			end
			KEYSTREAM_READ : begin select_input  <= RAM; end
			default: begin end
		endcase
	end
end


endmodule
