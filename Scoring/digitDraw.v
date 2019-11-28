module digitDraw(
	clk,
	digitDrawEnable,
	digitDrawSelect,
	digitDrawEnd,
	digitDrawReset,
	x,
	y,
	x_draw,
	y_draw,
	outColour
);
	assign LEDR=digit_pos;
	
	// Have multiple memory modules
	// Draw Image starting at x,y


	// digit Size
	localparam [7:0] Y_lim_digit = 'd14 , X_lim_digit = 'd13;
	localparam [3:0] ZERO='d0, ONE='d1, TWO='d2, THREE='d3, FOUR='d4,
						  FIVE='d5, SIX='d6, SEVEN='d7, EIGHT='d8, NINE='d9;
	
	// Inputs
	input clk, digitDrawReset, digitDrawEnable;
	input [3:0] digitDrawSelect;
	
	// Postion to draw digit at
	input [7:0] x;
	input [7:0] y;
	
	// Counter
	reg [15:0] digitCounter;
	
	// output Signal
	output reg digitDrawEnd;
	
	// Current X , Y and Colour
	output [7:0] x_draw;
	output [7:0] y_draw; 

	assign x_draw = digitCounter[7:0] + x;
	assign y_draw = digitCounter[15:8] + y;
	output reg[23:0] outColour;
	
	// Screen Counting Process
	always@(posedge clk)
		begin
			if(digitDrawEnable) begin
				if(digitCounter[7:0] < X_lim_digit )
					digitCounter <= digitCounter + 1;
				else if(digitCounter[15:8] < Y_lim_digit )
					digitCounter <= {digitCounter[15:8] + 1 , 8'b0};
				else 
					digitDrawEnd <= 1;
			end
			if(digitDrawReset) begin
				digitCounter <= 0;
				digitDrawEnd <= 0;
			end
		end
	
	// Memory Location
	wire [7:0] digit_pos = digitCounter[7:0] + digitCounter[15:8] * (X_lim_digit + 1);
	
	//different digit types
	wire [23:0] outColour_0, outColour_1, outColour_2, outColour_3, outColour_4,
					outColour_5, outColour_6, outColour_7, outColour_8, outColour_9;
	
	//digit ram used
	digit0 dig0 (.address(digit_pos), .clock(clk), .q(outColour_0), .wren(1'b0), .data(24'b0));
	digit1 dig1 (.address(digit_pos), .clock(clk), .q(outColour_1), .wren(1'b0), .data(24'b0));
	digit2 dig2 (.address(digit_pos), .clock(clk), .q(outColour_2), .wren(1'b0), .data(24'b0));
	digit3 dig3 (.address(digit_pos), .clock(clk), .q(outColour_3), .wren(1'b0), .data(24'b0));
	digit4 dig4 (.address(digit_pos), .clock(clk), .q(outColour_4), .wren(1'b0), .data(24'b0));
	digit5 dig5 (.address(digit_pos), .clock(clk), .q(outColour_5), .wren(1'b0), .data(24'b0));
	digit6 dig6 (.address(digit_pos), .clock(clk), .q(outColour_6), .wren(1'b0), .data(24'b0));
	digit7 dig7 (.address(digit_pos), .clock(clk), .q(outColour_7), .wren(1'b0), .data(24'b0));
	digit8 dig8 (.address(digit_pos), .clock(clk), .q(outColour_8), .wren(1'b0), .data(24'b0));
	digit9 dig9 (.address(digit_pos), .clock(clk), .q(outColour_9), .wren(1'b0), .data(24'b0));
	
	// for different colour cases
	always @ ( * )begin
		begin: brickColour_cases
			case(digitDrawSelect)
				ZERO:    outColour <= outColour_0;
				ONE: 	   outColour <= outColour_1;
				TWO:	   outColour <= outColour_2;
				THREE:   outColour <= outColour_3;
				FOUR:	   outColour <= outColour_4;
				FIVE:	   outColour <= outColour_5;
				SIX:	   outColour <= outColour_6;
				SEVEN:   outColour <= outColour_7;
				EIGHT:   outColour <= outColour_8;
				NINE:	   outColour <= outColour_9;
				default: outColour <= 24'b111111111111111111111111;//else
			endcase
		end
	end
endmodule