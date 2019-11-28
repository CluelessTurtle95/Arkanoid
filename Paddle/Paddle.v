module paddleMovement(clk, reset, moveDir, x, y); // Clock and current Position of paddle --> update position
	input clk,reset;
	input [1:0] moveDir;
	
	output [7:0] y;
	assign y = 'd167;
	output reg [7:0] x;
	
	
	// Paddle Movement
	localparam [1:0] left = 2'b11 , right = 2'b01, noMove = 2'b10;
	// x => 160 - 40 , y => 120 - 8 - 10
	localparam [7:0] x_max = 'd120, x_min = 'd0;
	
	wire pulse;
	
	speedControl sp1(clk, pulse);
	defparam sp1.data = 26'd1000000;
	
	always@(posedge clk)
	begin
		if(reset)
			x <= 'd60;
		else if(moveDir == left && pulse) begin
			if(x > x_min)
				x <= x - 1;
		end
		else if(moveDir == right && pulse) begin
			if(x < x_max)
				x <= x + 1 ;
		end
	end
endmodule
 
module paddleDraw(
	clk,
	reset,
	paddleDrawEnable,
	x,
	y,
	outColour,
	x_curr,
	y_curr,
	paddleDrawEnd
);
	// Inputs
	
	// Postion to draw paddle at
	input [7:0] x;
	input [7:0] y;
	
	input clk,reset,paddleDrawEnable;
	
	// Ouputs
	output [23:0] outColour;
	
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
	localparam [7:0] Y_lim_paddle = 'd7 , X_lim_paddle = 'd39;
	
	// Paddle X,Y Counters
	reg [15:0] paddleCounter;
	wire [7:0] paddle_x_count = paddleCounter[7:0];
	wire [7:0] paddle_y_count = paddleCounter[15:8];
	
	// current X,Y locations
	output [7:0] x_curr;
	assign x_curr = paddle_x_count + x;
	output [7:0] y_curr;
	assign y_curr = paddle_y_count + y;
	
	// Memory Location
	wire [10:0] paddle_pos = paddle_x_count + paddle_y_count * (X_lim_paddle + 1);
	
	// Signal to indicate finish drawing
	output reg paddleDrawEnd;
	
	// Paddle Couting process
	always@(posedge clk)
		begin
			if(paddleDrawEnable) begin
				if(paddleCounter[7:0] < X_lim_paddle )
					paddleCounter <= paddleCounter + 1;
				else if(paddleCounter[15:8] < Y_lim_paddle )
					paddleCounter <= {paddleCounter[15:8] + 1 , 8'b0};
				else begin 
					paddleDrawEnd <= 1;
					paddleCounter <= 0;
				end
			end
			if(reset) begin
				paddleCounter <= 0;
				paddleDrawEnd <= 0;
			end
		end
	
	// Accessing from Memory
	PaddleMem pm1(.address(paddle_pos), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
endmodule 