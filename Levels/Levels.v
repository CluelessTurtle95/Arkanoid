module levelTop(
	clk,
	levelDrawEnable,
	levelDrawEnd,
	levelDrawReset,
	ballcheckEnable,
	ballcheckEnd,
	ballcheckReset,
	gameRun_internal,
	collideDir,
	x_ball, 
	y_ball,
	x_draw,
	y_draw,
	outColour,
	brickBallCollide,
	left,right,down,top,
	levelSelect,
	score,
	scoreEnd,
	scoreEnable,
	reset,
	debug,
	user_debug,
	LEDR,
	HEX2 , HEX3
);
	// Debug
	output [9:0] LEDR;
	output [6:0] HEX2 , HEX3;
	output debug;
	input user_debug;
	// General Inputs
	input clk;
	input [2:0] levelSelect;
	input reset;
	
	// Drawing Inputs
	input levelDrawEnable, levelDrawReset;
	
	//Scoring
	output reg scoreEnd;
	input scoreEnable;
	
	// Collision Inputs
	input [7:0] x_ball;
	input [7:0] y_ball;
	input ballcheckEnable;
	input ballcheckReset;
	
	// Drawing
	output [7:0] x_draw;
	output [7:0] y_draw;
	output [23:0] outColour;
	output levelDrawEnd;
	output gameRun_internal;
	
	// Collision
	output brickBallCollide;
	output ballcheckEnd;
	output [2:0] collideDir;
	
	// General wires
	wire [2:0] brick_type;
	
	// Draw Wires
	wire [7:0] drawBrick_pos;
	
	// score
	output [7:0] score;
	
	levelDraw ld1(
		clk,
		levelDrawEnable,
		levelDrawEnd,
		levelDrawReset,
		brick_type,
		drawBrick_pos,
		x_draw,
		y_draw,
		outColour,
		brickDrawEnd
	);
	wire brickDrawEnd;
	
	reg [7:0] pos ;
	wire [7:0] brick_update_pos;
	//assign pos = (levelDrawEnable ? drawBrick_pos : brick_external_pos);
	
	always@(*) begin
		if(levelDrawEnable)
			pos = drawBrick_pos;
		else if(scoreEnable)
			pos = brick_update_pos;
		else
			pos = brick_external_pos;
	end
	
	always@(posedge clk) begin
		if(scoreEnable)
			scoreEnd <= 1;
		else 
			scoreEnd <= 0;
	end
	
	wire brick_update_enable;
	
	assign LEDR = brick_update_pos;
	seg7 s44(brick_update, HEX2);
	assign brick_update_enable = scoreEnable;
	levelMemory lm1(clk,levelSelect,pos,brick_type, brick_update , brick_update_enable);
	scoring s1(clk, reset, brick_x, brick_y, brick_type, ballcheckEnable, brickBallCollide, brick_update, brick_update_pos,score);
	// Collision Wires
	wire [7:0] brick_x;
	wire [7:0] brick_y;
	
	output [7:0] left,right,down,top;
	
	brickCollision bc1(
		ballcheckEnable,
		ballcheckEnd,
		ballcheckReset,
		clk,
		brick_x,
		brick_y,
		brick_type,
		x_ball, 
		y_ball,
		brickBallCollide,
		collideDir,
		gameRun_internal,
		left,right,down,top
	);
	
	assign debug =  scoreEnable && user_debug;
	
//	assign LEDR[0] = brickBallCollide;
//	assign LEDR[1] = gameRun_internal;
//	assign LEDR[2] = ballcheckEnd;
//	assign LEDR[3] = ballcheckEnable;
//	assign LEDR[5:4] = collideDir;
//	assign LEDR[9:6] = brick_x;
	
	//seg7 s2(brick_type, HEX2);
	//seg7 s3(brick_external_pos, HEX3);
	
	localparam [3:0] X_lim_level = 'd10 , Y_lim_level = 'd8;
	wire [7:0] brick_x_adv = brick_x + 1;
	wire [7:0] brick_external_pos = brick_x_adv + brick_y * X_lim_level;
endmodule 

module levelMemory(clk,levelSelect,pos,brick_type, brick_update, brick_update_enable);
	input clk;
	input [2:0] levelSelect;
	input [7:0] pos;
	output reg [2:0] brick_type;
	input [2:0] brick_update;
	input brick_update_enable;
	
	// Brick types
	localparam [2:0] NOBRICK = 'd0, RED = 'd1, BROWN = 'd2, SRED= 'd3, SBROWN = 'd4;

	localparam [2:0] LEV1=3'b001, LEV2=3'b010, LEV3=3'b011, LEV4=3'b100;
	
	wire [2:0] brick_type_internal_level1, brick_type_internal_level2, brick_type_internal_level3, brick_type_internal_level4;
	
	// Level Memory
	level1Mem l1m(.address(pos), .clock(clk), .q(brick_type_internal_level1), .wren(brick_update_enable && (levelSelect == LEV1)), .data(brick_update));
	level2Mem l2m(.address(pos), .clock(clk), .q(brick_type_internal_level2), .wren(brick_update_enable && (levelSelect == LEV2)), .data(brick_update));
	level3Mem l3m(.address(pos), .clock(clk), .q(brick_type_internal_level3), .wren(brick_update_enable && (levelSelect == LEV3)), .data(brick_update));
	level4Mem l4m(.address(pos), .clock(clk), .q(brick_type_internal_level4), .wren(brick_update_enable && (levelSelect == LEV4)), .data(brick_update));
	
	//mux for the levelSelect	
	always@(*) begin : Level_choice
		case(levelSelect)
			LEV1:brick_type=brick_type_internal_level1;
			LEV2:brick_type=brick_type_internal_level2;
			LEV3:brick_type=brick_type_internal_level3;
			LEV4:brick_type=brick_type_internal_level4;
			default: brick_type=NOBRICK;
		endcase
	end
endmodule

module scoring(clk, reset, brick_x, brick_y, brick_type, ballcheckEnable, brickBallCollide, brick_update, brick_update_pos,score);
		input clk;
		input reset;
		output reg [7:0] score;
		input [2:0] brick_type;
		input ballcheckEnable;
		input brickBallCollide;
		
		input [7:0] brick_x;
		input [7:0] brick_y;
		output [2:0] brick_update;
		output [7:0] brick_update_pos;
		// New
		reg [7:0] brick_x_saved;
		reg [7:0] brick_y_saved;
		reg [3:0] brick_new_type;
		
		// Save state
		always@(posedge brickBallCollide) begin
			if(brickBallCollide)
					brick_x_saved <= brick_x;
					brick_y_saved <= brick_y;
					brick_new_type <= brick_type - 1;
		end
		
		assign brick_update = brick_new_type;
		assign brick_update_pos = brick_x_saved + brick_y_saved * 10 ;
		
		
		// Score Management
		always@(posedge brickBallCollide) begin
			if(brickBallCollide)
				score <= score + brick_type;
			else if(reset)
				score <= 0;
		end
endmodule 