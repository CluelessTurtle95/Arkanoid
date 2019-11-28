module brickDraw(
	clk,
	brickDrawEnable,
	brickDrawSelect,
	brickDrawEnd,
	brickDrawReset,
	x,
	y,
	x_draw,
	y_draw,
	outColour
);
	// Have multiple memory modules , Select Brick image using brick type.
	// Draw Image starting at x,y


	// Brick Size
	localparam [7:0] Y_lim_brick = 'd5 , X_lim_brick = 'd11;
	localparam [2:0] NOBRICK = 'd0, RED = 'd1, BROWN = 'd2, SRED= 'd3, SBROWN = 'd4;
	
	// Inputs
	input clk, brickDrawReset, brickDrawEnable;
	input [2:0] brickDrawSelect;
	
	// Postion to draw paddle at
	input [7:0] x;
	input [7:0] y;
	
	// Counter
	reg [15:0] brickCounter;
	
	// output Signal
	output reg brickDrawEnd;
	
	// Current X , Y and Colour
	output [7:0] x_draw;
	output [7:0] y_draw; 

	assign x_draw = brickCounter[7:0] + x;
	assign y_draw = brickCounter[15:8] + y;
	output reg[23:0] outColour ;
	
	// Screen Counting Process
	always@(posedge clk)
		begin
			if(brickDrawEnable) begin
				if(brickCounter[7:0] < X_lim_brick )
					brickCounter <= brickCounter + 1;
				else if(brickCounter[15:8] < Y_lim_brick )
					brickCounter <= {brickCounter[15:8] + 1 , 8'b0};
				else 
					brickDrawEnd <= 1;
			end
			if(brickDrawReset) begin
				brickCounter <= 0;
				brickDrawEnd <= 0;
			end
		end
	
	// Memory Location
	wire [16:0] brick_pos = brickCounter[7:0] + brickCounter[15:8] * (X_lim_brick + 1);
	
	//different brick types
	wire [23:0] outColour_red, outColour_super_red, outColour_brown, outColour_super_brown; 
	
	//brick ram used
	redBrick 		rbm1 (.address(brick_pos), .clock(clk), .q(outColour_red		), .wren(1'b0), .data(24'b0));
	brownBrick 		bbm1 (.address(brick_pos), .clock(clk), .q(outColour_brown		), .wren(1'b0), .data(24'b0));
	superRedBrick 	srbm1(.address(brick_pos), .clock(clk), .q(outColour_super_red	), .wren(1'b0), .data(24'b0));
	superBrownBrick sbbm1(.address(brick_pos), .clock(clk), .q(outColour_super_brown), .wren(1'b0), .data(24'b0));
	
	// for different colour cases
	always @ ( * )begin
		begin: brickColour_cases
			case(brickDrawSelect)
				RED: 	 outColour <= outColour_red ;
				BROWN: 	 outColour <= outColour_brown;
				SRED: 	 outColour <= outColour_super_red;
				SBROWN:  outColour <= outColour_super_brown;
				NOBRICK: outColour <= 24'b111111111111111111111111;
				default: outColour <= 24'b000000001111111100000000;
			endcase
		end
	end
endmodule 