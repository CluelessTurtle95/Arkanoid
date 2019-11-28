module ballMovement(
		clk,
		reset, 
		x, 
		y, 
		x_paddle, 
		y_paddle, 
		brickBallCollide,
		left,right,down,top,
		collideDir,
		gameRun,
		livesLeft,//lifeDrawSelect
		LEDR
	); // Clock and current Position of paddle --> update position
	//new 
	output reg [3:0] livesLeft;
	always @ (posedge clk) begin
		if(internal_reset) begin 
			livesLeft<=livesLeft-'d1;
		end else begin
			if(reset)
				livesLeft<='d6;
		end
	end
	
	
	// Debug
	output [9:0] LEDR;
	assign LEDR[5:0] = score;
	assign LEDR[6] = internal_reset;
	assign LEDR[9:7] = moveDir;
	
	// Input
	input clk,reset, gameRun;
	
	// Internal
	reg [1:0] moveDir;
	reg [5:0] score;
	reg internal_reset;
	
	input [7:0] x_paddle, y_paddle;
	
	output reg [7:0] y;
	output reg [7:0] x;
	
	// Input Signals
	input brickBallCollide;
	input [2:0] collideDir;
	input [7:0] left,right,down,top;
	
	// Constants
	// Ball Movement
	localparam [1:0] UpLeft = 2'b10 , UpRight = 2'b11, DownRight = 2'b01, DownLeft = 2'b00;
	// Screen Size
	localparam [7:0] X_lim_screen = 'd160, Y_lim_screen = 'd180;
	// Ball size
	localparam [7:0] Y_lim_ball = 'd6 , X_lim_ball = 'd6;
	// Ball End Positions
	localparam [7:0] x_max_ball = X_lim_screen - X_lim_ball, x_min_ball = 'd0, y_max_ball = Y_lim_screen - Y_lim_ball, y_min_ball = 'd0;
	// Paddle Size
	localparam [7:0] Y_lim_paddle = 'd8 , X_lim_paddle = 'd40;

	localparam [1:0] collideLeft = 3'b000, collideRight = 3'b001, collideTop = 3'b010, collideDown= 3'b011, collideNone = 3'b100;
	
	wire pulse;
	
	speedControl sp2(clk, pulse);
	defparam sp2.data = 'd1000000;
	
	wire [3:0] out;
	lfsr rg(out, clk, 0);
	wire [1:0] randmoveDir = out;
	
	//reg [3:0] lives;
	
	//always@(*)
	
	always@(posedge clk)
	begin : movement_process
		if(reset | internal_reset) begin
			x <= X_lim_screen/2 - X_lim_ball / 2;
			y <= Y_lim_screen/2 - Y_lim_ball / 2;
		end
		else if(pulse && gameRun) begin
			if (moveDir==UpLeft) begin
				if(x > x_min_ball)
					x<=x-1;
				if(y > y_min_ball)
					y<=y-1;
			end
			else if (moveDir==UpRight) begin
				if(x < x_max_ball)
					x<=x+1;
				if(y > y_min_ball)
					y<=y-1;
			end
			else if (moveDir==DownRight) begin
				if(x < x_max_ball)
					x<=x+1;
				if(y < y_max_ball)
					y<=y+1;
			end
			else if (moveDir==DownLeft) begin
				if(x > x_min_ball)
					x<=x-1;
				if(y < y_max_ball)
					y<=y+1;
			end
		end
		// brick correction ?
		if(brickBallCollide) begin
			case (collideDir)
					collideLeft: begin
						x<=left;
					end
					collideRight: begin
						x<=right;
					end
					collideTop: begin
						y<=top;
					end
					collideDown: begin
						y<=down;
					end
			endcase
		end
	end
	
	//reg DoScore;
	
	always@(posedge clk) begin
		if(y == y_max_ball) begin
			//if(DoScore) begin
				score <= score + 1;
				//DoScore <= 0;
			//end
		end
		if(reset) begin
			score <= 0;
			internal_reset <= 0;
		end
		if ( y == y_max_ball) begin
				internal_reset <= 1;
		end
		else begin
			internal_reset <= 0;
			//DoScore <= 1;
		end
	end
	
	always @(posedge clk or posedge brickBallCollide)
	begin : movement_change
		// Bricks
		if (brickBallCollide) begin
				case (collideDir)
					collideLeft: begin
						if(moveDir == DownRight)
							moveDir <= DownLeft;
						else if(moveDir == UpRight)
							moveDir <= UpLeft;
					end
					collideRight: begin
						if(moveDir == DownLeft)
							moveDir <= DownRight;
						else if(moveDir == UpLeft)
							moveDir <= UpRight;
					end
					collideTop: begin
						if(moveDir == DownRight)
							moveDir <= UpRight;
						else if(moveDir == DownLeft)
							moveDir <= UpLeft;
					end
					collideDown: begin
						if(moveDir == UpRight)
							moveDir <= DownRight;
						else if(moveDir == UpLeft)
							moveDir <= DownLeft;
					end
				endcase
			end else begin
					if(reset | internal_reset) begin
						moveDir <= randmoveDir;
					end
				// Walls
					if(x == x_min_ball) begin
						if(moveDir == DownLeft)
							moveDir <= DownRight;
						if(moveDir == UpLeft)
							moveDir <= UpRight;
					end
					if ( x == x_max_ball) begin
						if(moveDir == DownRight)
							moveDir <= DownLeft;
						if(moveDir == UpRight)
							moveDir <= UpLeft;
					end
					if(y == y_min_ball ) begin
						if(moveDir == UpRight)
							moveDir <= DownRight;
						if(moveDir == UpLeft)
							moveDir <= DownLeft;         // Y > y_max_ball ==> GAME_OVER
					end
				// Paddle
					if( (x + X_lim_ball) > x_paddle && x < x_paddle + X_lim_paddle) begin
						if( (y + Y_lim_ball) > y_paddle && y < y_paddle + Y_lim_paddle ) begin
							if(moveDir == DownRight)
								moveDir <= UpRight;
							if(moveDir == DownLeft)
								moveDir <= UpLeft;
						end
					end
			end
	end
endmodule 

module ballDraw(
	clk,
	reset,
	ballDrawEnable,
	x,
	y,
	outColour,
	x_curr,
	y_curr,
	ballDrawEnd
);
	// Inputs
	
	// Postion to draw paddle at
	input [7:0] x;
	input [7:0] y;
	
	input clk,reset,ballDrawEnable;
	
	// Ouputs
	output [23:0] outColour;
	
	// Constants
	// Ball Movement
	localparam [1:0] UpLeft = 2'b10 , UpRight = 2'b11, DownRight = 2'b01, DownLeft = 2'b00;
	// Screen Size
	localparam [7:0] X_lim_screen = 'd160, Y_lim_screen = 'd180;
	// Ball size
	localparam [7:0] Y_lim_ball = 'd5 , X_lim_ball = 'd5;
	// Ball End Positions
	localparam [7:0] x_max_ball = X_lim_screen - X_lim_ball, x_min_ball = 'd0, y_max_ball = Y_lim_screen - Y_lim_ball, y_min_ball = 'd0;
	// Paddle Size
	localparam [7:0] Y_lim_paddle = 'd8 , X_lim_paddle = 'd40;
	
	// Paddle X,Y Counters
	reg [15:0] ballCounter;
	wire [7:0] ball_x_count = ballCounter[7:0];
	wire [7:0] ball_y_count = ballCounter[15:8];
	
	// current X,Y locations
	output [7:0] x_curr;
	assign x_curr = ball_x_count + x;
	output [7:0] y_curr;
	assign y_curr = ball_y_count + y;
	
	// Memory Location
	wire [10:0] ball_pos = ball_x_count + ball_y_count * (X_lim_ball + 1);
	
	// Signal to indicate finish drawing
	output reg ballDrawEnd;
	
	// Paddle Couting process
	always@(posedge clk)
		begin
			if(ballDrawEnable) begin
				if(ballCounter[7:0] < X_lim_ball )
					ballCounter <= ballCounter + 1;
				else if(ballCounter[15:8] < Y_lim_ball )
					ballCounter <= {ballCounter[15:8] + 1 , 8'b0};
				else begin 
					ballDrawEnd <= 1;
					ballCounter <= 0;
				end
			end
			if(reset) begin
				ballCounter <= 0;
				ballDrawEnd <= 0;
			end
		end
	
	// Accessing from Memory
	ballMem bm1(.address(ball_pos), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
endmodule 