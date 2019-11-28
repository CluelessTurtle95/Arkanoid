module screenDraw(
	clk,
	reset,
	screenDrawEnable,
	screenDrawEnd,
	outColour,
	outColour_start,
	outColour_over,
	x_curr,
	y_curr,
	x_curr_game,
	y_curr_game,
	drawGameOver
);
	
	// Screen Size
	localparam [7:0] Y_lim_screen = 'd180 , X_lim_screen = 'd160;
	
	localparam [7:0] Y_lim_game = 'd40 , X_lim_game = 'd80;
	
	// Inputs
	input clk, reset, screenDrawEnable;
	
	// Counter
	reg [15:0] screenCounter;
	reg [15:0] gameCounter;
	
	// output Signal
	output reg screenDrawEnd;
	
	// Current X , Y and Colour
	output [7:0] x_curr;
	output [7:0] y_curr; 

	assign x_curr = screenCounter[7:0];
	assign y_curr = screenCounter[15:8];
	
	output [7:0] x_curr_game;
	output [7:0] y_curr_game;
	
	assign x_curr_game = gameCounter[7:0];
	assign y_curr_game = gameCounter[15:8];
	
	output [23:0] outColour , outColour_start, outColour_over;
	
	// Screen Counting Process
	always@(posedge clk)
		begin
			if(screenDrawEnable) begin
				if(screenCounter[7:0] < X_lim_screen )
					screenCounter <= screenCounter + 1;
				else if(screenCounter[15:8] < Y_lim_screen )
					screenCounter <= {screenCounter[15:8] + 1 , 8'b0};
				else 
					screenDrawEnd <= 1;
			end
			if(reset) begin
				screenCounter <= 0;
				screenDrawEnd <= 0;
			end
		end
	
	input drawGameOver;
	always@(posedge clk)
		begin
			if(screenDrawEnable && drawGameOver) begin
				if(gameCounter[7:0] < X_lim_game )
					gameCounter <= gameCounter + 1;
				else if(gameCounter[15:8] < Y_lim_game )
					gameCounter <= {gameCounter[15:8] + 1 , 8'b0};
			end
			if(reset) begin
				gameCounter <= 0;
			end
		end
		
	// Memory Location
	wire [16:0] screen_pos = x_curr + y_curr * X_lim_screen;
	wire [16:0] screen_pos_game = x_curr_game + y_curr_game * X_lim_game;
	
	//assign outColor = 24'b0;
	BackgroundMem bm1(.address(screen_pos), .clock(clk), .q(outColour), .wren(1'b0), .data(24'b0));
	
	gameover over1(.address(screen_pos_game), .clock(clk), .q(outColour_over_4));
	startgame start1(.address(screen_pos), .clock(clk), .q(outColour_start_4));
	
	wire [11:0] outColour_over_4;
	wire [7:0] outColour_over_4_r = outColour_over_4[11:8] * 17;
	wire [7:0] outColour_over_4_g = outColour_over_4[7:4] * 17;
	wire [7:0] outColour_over_4_b = outColour_over_4[3:0] * 17;
	assign outColour_over = {outColour_over_4_r , outColour_over_4_g , outColour_over_4_b };
	
	
	wire [11:0] outColour_start_4;
	wire [7:0] outColour_start_4_r = outColour_start_4[11:8] * 17;
	wire [7:0] outColour_start_4_g = outColour_start_4[7:4] * 17;
	wire [7:0] outColour_start_4_b = outColour_start_4[3:0] * 17;
	assign outColour_start = {outColour_start_4_r , outColour_start_4_g , outColour_start_4_b };
	
endmodule 