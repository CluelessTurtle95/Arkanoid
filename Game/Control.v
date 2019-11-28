module Control(
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
	//	Debug Outputs
	//	output [9:0] LEDR;
	//	assign LEDR[1:0] = paddleMoveDir;
	//	assign LEDR[9] = moveInputLeft;
	//	assign LEDR[8] = moveInputRight;
	//	assign LEDR[7] = moveInput;
		
		localparam [1:0] left = 2'b11 , right = 2'b01, noMove = 2'b10;
		
		// Inputs
		input moveInputLeft;
		input moveInputRight;
		
		input clk,reset, beginGame;
		input gameRun_user, gameRun_internal;
		wire gameRun = gameRun_user && gameRun_internal;
		input [3:0] lifeDrawSelect;
		
		// Input Signals
		input paddleDrawEnd;
		input screenDrawEnd;
		input ballDrawEnd;
		input levelDrawEnd;
		input scoreDrawEnd;
		input lifeDrawEnd;
		input ballcheckEnd;
		input scoreEnd;
		
		// Output Signals
		output reg [1:0] paddleMoveDir;
		output reg paddleDrawEnable;	
		output reg screenDrawEnable;
		output reg ballDrawEnable;
		output reg levelDrawEnable;
		output reg scoreDrawEnable;
		output reg lifeDrawEnable;
		output reg ballcheckEnable;
		
		output reg drawGameOver;
		output reg drawGameStart;
		output reg scoreEnable;
		
		// Main FSM
		localparam [3:0] 	start     = 4'b0001 , 
								INPUT		 = 4'b0010 , 
								INPUTWAIT = 4'b0011 , 
								DRAWBACK  = 4'b0100 , 
								DRAWPAD 	 = 4'b0101 , 
								DRAWLVL	 = 4'b0110 ,
								DRAWBALL  = 4'b0111 ,
								DRAWSCORE = 4'b1000 ,
								DRAWLIFE  = 4'b1001 ,
								BALLCOLLISION 	= 4'b0000,
								SCOREGAME		= 4'b1100,
								GAMEOVER 		= 4'b1010,
								CHECKGAMEOVER 	= 4'b1011;
		
		reg [3:0] currentState;
		reg [3:0] nextState;
		
		wire pulse;
		
		speedControl sp1(clk, pulse);
		defparam sp1.data = 'd1000000;
		
		always@(posedge clk) begin
			case(currentState)
				start : nextState <= beginGame ? INPUT : start;
				INPUT : nextState <= (gameRun && pulse) ? INPUTWAIT : INPUT;
				INPUTWAIT : nextState <= gameRun ? DRAWBACK : INPUTWAIT;
				DRAWBACK: nextState <=  screenDrawEnd ? DRAWPAD : DRAWBACK ;
				DRAWPAD : nextState <= paddleDrawEnd ? DRAWLVL : DRAWPAD ;
				DRAWLVL : nextState <= levelDrawEnd ? DRAWBALL : DRAWLVL;
				DRAWBALL : nextState <= ballDrawEnd ? DRAWSCORE : DRAWBALL;
				DRAWSCORE : nextState <= scoreDrawEnd ? DRAWLIFE : DRAWSCORE;
				DRAWLIFE : nextState <= lifeDrawEnd ? BALLCOLLISION : DRAWLIFE;
				BALLCOLLISION : nextState <= ballcheckEnd ? SCOREGAME : BALLCOLLISION;
				SCOREGAME : nextState <= scoreEnd ? CHECKGAMEOVER : SCOREGAME;
				CHECKGAMEOVER : nextState <= (lifeDrawSelect > 0) ? INPUT : GAMEOVER;
				GAMEOVER : nextState <= GAMEOVER;
			endcase
		end
		
		always@(posedge clk) begin
			if(reset) begin
				currentState <= start;
			end
			else begin
				currentState <= nextState;
			end
		end
		
		output reg screenDrawReset;
		output reg paddleDrawReset;
		output reg ballDrawReset;
		output reg levelDrawReset;
		output reg scoreDrawReset;
		output reg lifeDrawReset;
		output reg ballcheckReset;
		
		
		always@(*) begin
			screenDrawEnable = 0;
			paddleDrawEnable = 0;
			ballDrawEnable = 0;
			levelDrawEnable = 0;
			scoreDrawEnable = 0;
			lifeDrawEnable = 0;
			screenDrawReset = 0;
			paddleDrawReset = 0;
			ballDrawReset = 0;
			levelDrawReset = 0;
			scoreDrawReset = 0;
			lifeDrawReset = 0;
			ballcheckEnable = 0;
			ballcheckReset = 0;
			drawGameOver = 0;
			drawGameStart = 0;
			scoreEnable = 0;
			case(currentState)
				start : begin
					drawGameStart = 1;
					screenDrawEnable = 1;
				end
				INPUT : begin 
					if(moveInputLeft) begin
						paddleMoveDir <= left;
					end
					else if(moveInputRight) begin
						paddleMoveDir <= right;
					end
					else
						paddleMoveDir <= noMove;
				end
				INPUTWAIT : begin
					screenDrawReset = 1;
					paddleDrawReset = 1;
					ballDrawReset = 1;
					levelDrawReset = 1;
					lifeDrawReset = 1;
					ballcheckReset = 1;
					scoreDrawReset = 1;
				end
				DRAWBACK : begin
					screenDrawEnable = 1;
				end
				DRAWPAD : begin
					paddleDrawEnable = 1;
				end
				DRAWLVL : begin
					levelDrawEnable = 1;
				end
				DRAWBALL : begin 
					ballDrawEnable = 1;
				end
				DRAWSCORE : begin 
					scoreDrawEnable = 1;
				end
				DRAWLIFE : begin 
					lifeDrawEnable = 1;
				end
				BALLCOLLISION: begin
					ballcheckEnable = 1;
				end
				SCOREGAME: begin
					scoreEnable = 1;
				end
				GAMEOVER : begin
					drawGameOver = 1;
					screenDrawEnable = 1;
				end
			endcase
		end
		
endmodule 