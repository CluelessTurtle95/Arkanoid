// Screen Size 320 x 240
// With 160 x 180 Virtual Screen
// everything active high

module Arkanoid
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5	,				// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		
		// PS2
		
		PS2_CLK,
		PS2_DAT
		
	);
	inout PS2_CLK, PS2_DAT;
		
	input			CLOCK_50;//	50 MHz
	input	[3:0]	KEY;	
	input	[9:0]	SW;
	output	[9:0]	LEDR;
	output [6:0] HEX0,HEX1, HEX2, HEX3, HEX4,HEX5;	
	// Declare your inputs and outputs here
	
	wire beginGame = SPACE;
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire writeEn;
	wire [8:0] x;
	wire [8:0] y;
	wire [23:0] outColour;
	wire reset = SW[0];
	wire [7:0] last_data_received;
	
	wire newclk;
	wire debug;
	wire user_debug = SW[9];
	Game g1(
		.reset(R |  ~KEY[0]),
		.clk(newclk),
		.beginGame(beginGame),
		.moveInputLeft(A | ~KEY[2]),
		.moveInputRight(D | ~KEY[1]),
		.gameRun(~P),
		.XScreenLOC('d80),
		.YScreenLOC('d30) ,
		.writeEn(writeEn),
		.x(x),
		.y(y),
		.outColour(outColour),
		.LEDR(LEDR),
		.levelSelect(game_level),
		.debug(debug),
		.user_debug(user_debug) ,
		.HEX2(HEX2) , 
		.HEX3(HEX3) , .HEX0(HEX0),
		.HEX1(HEX1),
		.X_SCORE_LOC(-'d75),
		.Y_SCORE_LOC('d0) ,
		.X_LIVE_LOC(-'d60),
		.Y_LIVE_LOC('d172)
	);
	
	Keyboard k1(
		// Inputs
		CLOCK_50,
		reset,
		// Bidirectionals
		PS2_CLK,
		PS2_DAT,
		last_data_received
	);	
	
	debugClock d1(CLOCK_50, debug, newclk, KEY);
	
   seg7 s1(last_data_received[3:0], HEX4);
   seg7 s2(last_data_received[7:4], HEX5);
	
	wire R = last_data_received == 'h2d;
	wire P = last_data_received == 'h4d;
	wire A = last_data_received == 'h1c;
	wire D = last_data_received == 'h23;
	wire SPACE = last_data_received == 'h29;
	wire N = last_data_received == 'h31;
	
	wire [2:0] game_level;
	assign game_level = level + 1;
	reg [1:0] level = 0;
	always@(posedge N) begin
		level = level + 1;
	end
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(
			.resetn(~reset),
			.clock(CLOCK_50),
			.colour(outColour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "src/Memory/MIF/fullback.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
endmodule 
