module brickCollision(
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
	// Debug
	//output [9:0] LEDR;
	//output [6:0] HEX2, HEX3;
	
	// Inputs
	input clk;
	
	output gameRun_internal;
	// Read current state from level memory
	output [3:0] brick_x;
	output [3:0] brick_y;
	input [3:0] brick_type;

	// Input Ball locations
	input [7:0] x_ball; 
	input [7:0] y_ball;
	
	// Input signals
	input ballcheckEnable;
	input ballcheckReset;
	
	// Output signals
	output brickBallCollide;
	output [2:0] collideDir;
	output reg ballcheckEnd;
	
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
	// Brick Size
	localparam [7:0] Y_lim_brick = 'd6 , X_lim_brick = 'd12;
	// Count brick 
	localparam [3:0] X_lim_level = 'd9 , Y_lim_level = 'd7;
	
	// Brick types
	localparam [3:0] NOBRICK = 'd0, RED = 'd1, BROWN = 'd2, SRED= 'd3, SBROWN = 'd4;
	
	localparam [1:0] collideLeft = 3'b000, collideRight = 3'b001, collideTop = 3'b010, collideDown= 3'b011, collideNone = 3'b100;
	
	

	reg [7:0] brickCheckCounter;
	
	// Drive Counters, brick_x , brick_y  
	assign gameRun_internal = ~ballcheckEnable;
	
	//assign LEDR[0] = brickBallCollide;
	//assign LEDR[1] = gameRun_internal;
	//assign LEDR[5:2] = brick_type;
	always@(posedge clk)
		begin
			if(ballcheckEnable) begin
					if(brickCheckCounter[3:0] < X_lim_level || brickCheckCounter == -8'd1) begin
						if(brickCheckCounter == -8'd1)
							brickCheckCounter <= 0;
						else 
							brickCheckCounter <= brickCheckCounter + 1;
					end else if(brickCheckCounter[7:4] < Y_lim_level )
						brickCheckCounter <= {brickCheckCounter[7:4] + 1 , 4'b0};
					else begin 
						brickCheckCounter<= -8'd1;
						ballcheckEnd <= 1;
					end
				end
			if(ballcheckReset) begin
				brickCheckCounter<= -8'd1;
				ballcheckEnd <= 0;
			end
		end
	
	
	assign brick_x = brickCheckCounter[3:0];
	assign brick_y = brickCheckCounter[7:4];
	
	seg7 s2(brick_y, HEX2);
	seg7 s3(brick_x, HEX3);
	
	wire collision;
	assign brickBallCollide = collision && (brick_type > NOBRICK) && (brick_x != -'d1) && ballcheckEnable;
	
	output [7:0] left,right,down,top;
	
	collisionCheck cc1(
		brick_x*X_lim_brick + 'd20,
		brick_y*Y_lim_brick + 'd20,
		X_lim_brick,
		Y_lim_brick,
		x_ball,
		y_ball,
		X_lim_ball,
		Y_lim_ball,
		collision,
		collideDir,
		left,right,down,top
	);
endmodule 

// module waitClk()

module waitOne(clk, brickBallCollide, run);
	input brickBallCollide;
	input clk;
	wire run_int;
	
	reg [3:0] Q;
	always@(posedge clk) begin
		Q <= 0;
		if(brickBallCollide) begin
			if(run_int)
				Q <= 'd2;
			else
				Q <= Q - 1;
		end
		else begin
			if(Q > 0)
				Q <= Q - 1;
		end
	end
	
	
	assign run_int = (Q == 0);
	output run;
	assign run = run_int && ~brickBallCollide;
endmodule

module halfclk(clk, newclk, reset);
	input clk;
	input reset;
	reg Q;
	always@(posedge clk) begin
		if(reset)
			Q <= 0;
		else
			Q = Q + 1;
	end
	output newclk;
	assign newclk = (Q == 0); 
endmodule

module collisionCheck(
	objectA_X,
	objectA_Y,
	objectA_X_lim,
	objectA_Y_lim,
	objectB_X,
	objectB_Y,
	objectB_X_lim,
	objectB_Y_lim,
	collision,
	collideDir,
	left,right,down,top
);
	input [7:0] objectA_X,
					objectA_Y,
					objectA_X_lim,
					objectA_Y_lim,
					objectB_X,
					objectB_Y,
					objectB_X_lim,
					objectB_Y_lim;
	output reg collision;
	output reg [2:0] collideDir;
	
	// Collision Region
	output [7:0] left;
	assign left = objectA_X - objectB_X_lim;
	output [7:0] right;
	assign right = objectA_X + objectA_X_lim;
	output [7:0] down;
	assign down = objectA_Y + objectA_Y_lim;
	output [7:0] top;
	assign top = objectA_Y - objectB_Y_lim;

	always@(*) begin
		if(objectB_X > left && objectB_X < right) begin
			if(objectB_Y < down && objectB_Y > top) begin
				collision = 1;
			end
		end
		else begin
			collision = 0;
		end
	end
	
	localparam [3:0] collisionErrorMargin = 'd2;
	// Brick Ball Collisions
	localparam [1:0] collideLeft = 3'b000, collideRight = 3'b001, collideTop = 3'b010, collideDown= 3'b011, collideNone = 3'b100;
	
	always@(*) begin
		if(collision) begin
			if(objectB_Y <= top + collisionErrorMargin )
				collideDir <= collideTop;
			else if(objectB_Y >= down - collisionErrorMargin )
				collideDir <= collideDown;
			else if(objectB_X <= left + collisionErrorMargin )
				collideDir <= collideLeft;
			else if(objectB_X >= right- collisionErrorMargin )
				collideDir <= collideRight;
			else
				collideDir <= collideNone;
		end
		else begin
			collideDir <= collideNone;
		end
	end
endmodule 