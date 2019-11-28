module Game(
		reset,
		clk,
		beginGame,
		moveInputLeft,
		moveInputRight,
		gameRun,
		XScreenLOC,
		YScreenLOC,
		writeEn, x,
		y,
		outColour,
		levelSelect,
		debug ,
		user_debug,
		X_SCORE_LOC,
		Y_SCORE_LOC,
		X_LIVE_LOC,
		Y_LIVE_LOC,
		LEDR, 
		HEX2,
		HEX3, 
		HEX1, 
		HEX0
	);

	//Debug
	output debug;
	input user_debug;
	
	output [6:0] HEX2 , HEX3, HEX0, HEX1;
	
	input reset, clk, beginGame;
	input [2:0] levelSelect;
	
	input [7:0] XScreenLOC;
	input [7:0] YScreenLOC;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	output writeEn;
	output [9:0] LEDR;
	// Signals Between Control and Datapath
	
	// Enable and End
	wire paddleDrawEnable;
	wire paddleDrawEnd;
	wire screenDrawEnable;
	wire screenDrawEnd;
	wire ballDrawEnable;
	wire ballDrawEnd;
	wire levelDrawEnable;
	wire levelDrawEnd;
	wire scoreDrawEnable;
	wire scoreDrawEnd;
	wire lifeDrawEnable;
	wire lifeDrawEnd;
	wire ballcheckEnable;
	wire ballcheckEnd;

	// Move Direction
	wire [1:0] paddleMoveDir;
	
	// Reset Signals
	wire screenDrawReset, paddleDrawReset, ballDrawReset, levelDrawReset, ballcheckReset, scoreDrawReset, lifeDrawReset; 
	
	// Virtual Screen
	wire [7:0] x_virtualScreen;
	wire [7:0] y_virtualScreen;
	
	// User Inputs
	input gameRun; // Press KEY3 to Pause
	input moveInputLeft;
	input moveInputRight;
	
	
	output [23:0] outColour;
	output [7:0] x;
	output [7:0] y;
	
	assign y = y_virtualScreen + YScreenLOC;
	assign x = x_virtualScreen + XScreenLOC;

	wire gameRun_user = gameRun;
	wire gameRun_internal;
	
	
	input [7:0] X_SCORE_LOC, Y_SCORE_LOC,X_LIVE_LOC, Y_LIVE_LOC;
	
	wire [3:0] lifeDrawSelect;
	wire drawGameOver;
	wire drawGameStart;
	wire 	scoreEnd;
	wire scoreEnable;
	Control pc1(
		moveInputLeft, 
		moveInputRight, 
		clk,	
		reset, 
		beginGame,
		gameRun_user,
		gameRun_internal, 
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
		screenDrawReset,
		paddleDrawReset,
		ballDrawReset,
		levelDrawReset,
		scoreDrawReset,
		lifeDrawReset,
		ballcheckReset,
		lifeDrawSelect,
		drawGameOver,
		drawGameStart,
		scoreEnd,
		scoreEnable
	);
	Datapath pd1(
		outColour,
		x_virtualScreen ,
		y_virtualScreen ,
		writeEn ,
		paddleMoveDir ,
		paddleDrawEnable ,
		paddleDrawEnd ,
		ballDrawEnable,
		ballDrawEnd ,
		screenDrawEnable ,
		screenDrawEnd ,
		levelDrawEnable,
		levelDrawEnd,
		scoreDrawEnable,
		scoreDrawEnd,
		lifeDrawEnable,
		lifeDrawEnd,
		ballcheckEnable,
		ballcheckEnd,
		clk ,
		reset ,
		screenDrawReset ,
		paddleDrawReset ,
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
		HEX2 , HEX3, HEX0,HEX1
	);
endmodule 
