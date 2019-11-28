module Datapath(
	outColour,
	x_draw,
	y_draw,
	writeEn,
	paddleMoveDir,
	paddleDrawEnable,
	paddleDrawEnd,
	ballDrawEnable,
	ballDrawEnd,
	screenDrawEnable,
	screenDrawEnd,
	levelDrawEnable,
	levelDrawEnd,
	scoreDrawEnable,
	scoreDrawEnd,
	lifeDrawEnable,
	lifeDrawEnd,
	ballcheckEnable,
	ballcheckEnd,
	clk,
	reset,
	screenDrawReset, 
	paddleDrawReset,
	ballDrawReset,
	levelDrawReset,
	scoreDrawReset,
	lifeDrawReset,
	ballcheckReset,
	gameRun_user,
	gameRun_internal,
	levelSelect,
	debug,
	user_debug,
	lifeDrawSelect,
	X_SCORE_LOC, Y_SCORE_LOC,X_LIVE_LOC, Y_LIVE_LOC,
	drawGameOver,
	drawGameStart,
	scoreEnd,
	scoreEnable,
	LEDR,
	HEX2 , HEX3, HEX0, HEX1
);
	//Debug
	input user_debug;
	output debug;
	
	// Output
	output [9:0] LEDR;
	output [6:0] HEX2 , HEX3, HEX1, HEX0;
	
	//assign LEDR = paddleMoveDir;
	
	// Inputs
	input clk,reset,gameRun_user;
	wire gameRun = gameRun_user && gameRun_internal;
	output gameRun_internal;
	input [2:0] levelSelect;
	
	// Final output Colour 
	output reg [23:0] outColour;
	
	// Final Write Enable
	output reg writeEn;
	
	// score
	wire [7:0] score;
	
	seg7 s1(score[7:4],HEX1);
	seg7 s0(score[3:0],HEX0);
	// Signals
	input paddleDrawEnable, screenDrawEnable, ballDrawEnable, levelDrawEnable, scoreDrawEnable, lifeDrawEnable, ballcheckEnable, scoreEnable;
	output paddleDrawEnd, screenDrawEnd, ballDrawEnd, levelDrawEnd, scoreDrawEnd, lifeDrawEnd, ballcheckEnd, scoreEnd;
	input screenDrawReset, paddleDrawReset, ballDrawReset, levelDrawReset, scoreDrawReset, lifeDrawReset, ballcheckReset; 
	
	input drawGameOver , drawGameStart;
	// Movement Inputs
	input [1:0] paddleMoveDir;
	
	// Output X,Y
	output reg [7:0] x_draw;
	output reg [7:0] y_draw;
	
	// Current x,y Position to draw object
	wire [7:0] x_paddle;
	wire [7:0] y_paddle;
	
	wire [7:0] x_ball;
	wire [7:0] y_ball;
	
	// Current level
	wire [1:0] levelInput = 'd1;
	
	// Intermediate X,Y,colour
	wire [7:0] x_draw_paddle;
	wire [7:0] y_draw_paddle;
	
	wire [7:0] x_draw_ball;
	wire [7:0] y_draw_ball;
	
	wire [7:0] x_draw_screen;
	wire [7:0] y_draw_screen;
	
	wire [7:0] x_draw_lvl;
	wire [7:0] y_draw_lvl;
	
	wire [7:0] x_draw_score;
	wire [7:0] y_draw_score;
	
	wire [7:0] x_draw_life;
	wire [7:0] y_draw_life;
	
   wire [7:0] x_draw_over;
   wire [7:0] y_draw_over;
	
	wire [7:0] x_draw_start;
	wire [7:0] y_draw_start;
	
	
	wire [23:0] outColour_paddle;
	wire [23:0] outColour_ball;
	wire [23:0] outColour_screen;
	wire [23:0] outColour_lvl;
	wire [23:0] outColour_score;
	wire [23:0] outColour_life;
	wire [23:0] outColour_over;
	wire [23:0] outColour_start;
	// Acess current level state from levelDraw 
	wire [7:0] brick_x;
	wire [7:0] brick_y;
	wire [3:0] brick_type;
	
	wire brickReadEnable;
	wire brickReadEnd;
	
	// Brick Ball Collision state
	wire brickBallCollide;
	wire [2:0] collideDir;
	
	// Setting Final X,Y
	always@(posedge clk)
		begin
			writeEn <= 0;
			if(paddleDrawEnable) begin
				x_draw <= x_draw_paddle;
				y_draw <= y_draw_paddle;
				outColour <= outColour_paddle;
				writeEn <= (outColour_paddle != 24'b111111111111111111111111);
			end
			if(screenDrawEnable && ~drawGameOver && ~drawGameStart) begin
				x_draw <= x_draw_screen;
				y_draw <= y_draw_screen;
				outColour <= outColour_screen;
				writeEn <= 1;
			end
			
			if(ballDrawEnable) begin
				x_draw <= x_draw_ball;
				y_draw <= y_draw_ball;
				outColour <= outColour_ball;
				writeEn <= (outColour_ball != 24'b111111111111111111111111);
			end
			
			if(levelDrawEnable) begin
				x_draw <= x_draw_lvl;
				y_draw <= y_draw_lvl;
				outColour <= outColour_lvl;
				writeEn <= (outColour_lvl != 24'b111111111111111111111111);
			end
			
			if(scoreDrawEnable) begin
				x_draw <= x_draw_score;
				y_draw <= y_draw_score;
				outColour <= outColour_score;
				writeEn <= (outColour_score != 24'b111111111111111111111111);
			end
			
			if(lifeDrawEnable) begin
				x_draw <= x_draw_life;
				y_draw <= y_draw_life;
				outColour <= outColour_life;
				writeEn <= (outColour_life != 24'b111111111111111111111111);
			end
			
			if(drawGameOver) begin
				x_draw <= x_draw_over + 'd40;
				y_draw <= y_draw_over + 'd75;
				outColour <= outColour_over;
				writeEn <= (outColour_over != 24'b111111111111111111111111);
			end
			
			if(drawGameStart) begin
				x_draw <= x_draw_screen;
				y_draw <= y_draw_screen;
				outColour <= outColour_start;
				writeEn <= 1;
			end
			
		end 
	
	input [7:0] X_SCORE_LOC, Y_SCORE_LOC,X_LIVE_LOC, Y_LIVE_LOC;
	output [3:0] lifeDrawSelect;
	wire [7:0] left,right,down,top;
	
	paddleMovement pm(
		clk, 
		reset,
		paddleMoveDir, 
		x_paddle, 
		y_paddle
	);
	
	ballMovement bm1(
		clk,
		reset, 
		x_ball, 
		y_ball, 
		x_paddle, 
		y_paddle,
		brickBallCollide,
		left,right,down,top,
		collideDir, 
		gameRun,
		lifeDrawSelect//livesLeft
	);
	
	paddleDraw pd(
		clk,
		paddleDrawReset | reset, 
		paddleDrawEnable, 
		x_paddle, 
		y_paddle, 
		outColour_paddle, 
		x_draw_paddle, 
		y_draw_paddle, 
		paddleDrawEnd
	);
	
	levelTop lt1(
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
		x_draw_lvl,
		y_draw_lvl,
		outColour_lvl,
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
	
	ballDraw bd1(
		clk, 
		ballDrawReset | reset, 
		ballDrawEnable,
		x_ball, 
		y_ball,
		outColour_ball,
		x_draw_ball,
		y_draw_ball,
		ballDrawEnd
	);
	
	screenDraw sd1(
		clk, 
		screenDrawReset | reset, 
		screenDrawEnable, 
		screenDrawEnd, 
		outColour_screen,
		outColour_start,
		outColour_over,	
		x_draw_screen, 
		y_draw_screen,
		x_draw_over,
		y_draw_over,
		drawGameOver
	);
	
	scoreDraw sd2(
		clk,
		scoreDrawEnable,
		score,
		scoreDrawEnd,
		scoreDrawReset | reset,
		X_SCORE_LOC,
		Y_SCORE_LOC,
		x_draw_score,
		y_draw_score,
		outColour_score
	);
	
	digitDraw ld1(
		clk,
		lifeDrawEnable,
		(lifeDrawSelect/2),//livesLeft
		lifeDrawEnd,
		lifeDrawReset,
		X_LIVE_LOC, 
		Y_LIVE_LOC,
		x_draw_life,
		y_draw_life,
		outColour_life
	);
	
endmodule 