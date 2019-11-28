
module levelDraw(
	clk,
	levelDrawEnable,
	levelDrawEnd,
	levelDrawReset,
	brick_type_internal,
	drawBrick_pos,
	x_draw,
	y_draw,
	outColour,
	brickDrawEnd
);
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
	// Brick Ball Collisions
	localparam [1:0] collideLeft = 2'b00, collideRight = 2'b01, collideTop = 2'b10, collideDown= 2'b11;
	// Brick types
	localparam [2:0] NOBRICK = 'd0, RED = 'd1, BROWN = 'd2, SRED= 'd3, SBROWN = 'd4;

	//Debug
	//output [9:0] LEDR;

	input clk;
	input levelDrawEnable;
	input levelDrawReset;
	input [2:0] brick_type_internal ;
	
	output reg levelDrawEnd;
	output [7:0] x_draw, y_draw;
	output [23:0] outColour; 

	// 1st Function - Drawing the level
	
	wire [7:0] x_count_brick;
	wire [7:0] y_count_brick;
	
	
	reg [15:0] levelCounter;
	assign x_count_brick = levelCounter[7:0] ;
	assign y_count_brick = levelCounter[15:8] ;
	
	always@(posedge clk)
		begin
			if(levelDrawEnable) begin
				// Currently Drawing the level 
				if(~brickDrawEnd) begin
					brickDrawReset <= 0;
				end
				if(brickDrawEnd) begin  : increment_counters
					brickDrawReset <= 1;
					if(levelCounter[7:0] < X_lim_level || levelCounter == -8'd1) begin
						if(levelCounter == -8'd1)
							levelCounter <= 0;
						else
							levelCounter <= levelCounter + 1;
					end
					else if(levelCounter[15:8] < Y_lim_level )
						levelCounter <= {levelCounter[15:8] + 1 , 8'b0};
					else begin 
						// End of counters, level fully drawn
						levelDrawEnd <= 1;
						levelCounter <= 0;
					end
				end
			end
			if(levelDrawReset) begin
				brickDrawReset <= 1;
				levelCounter <= 0;
				levelDrawEnd <= 0;
			end
		end
		
	wire brickDrawEnable = levelDrawEnable;
	output brickDrawEnd;
	reg brickDrawReset;
	
	//assign LEDR[4] = levelDrawEnable;
	//assign LEDR[9:5] = drawBrick_pos;
	// Have Multiple Memory Modules for for different levels.
	// Store Level info in MIF file
	// Use Brick Draw to draw Level.
	brickDraw single_draw(
		clk,
		brickDrawEnable,
		brick_type_internal,
		brickDrawEnd,
		brickDrawReset,
		'd20 + (x_count_brick * X_lim_brick) ,
		'd20 + (y_count_brick * Y_lim_brick),
		x_draw,
		y_draw,
		outColour
	);
	
	output [7:0] drawBrick_pos;
	wire [7:0] x_count_brick_adv = x_count_brick + 1;
	assign drawBrick_pos = x_count_brick + y_count_brick * (X_lim_level + 1);
	
	
endmodule 