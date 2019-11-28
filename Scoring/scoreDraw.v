module scoreDraw(
	clk,
	scoreDrawEnable,
	scoreValue,
	scoreDrawEnd,
	scoreDrawReset,
	x,
	y,
	x_draw,
	y_draw,
	outColour
);

	localparam [1:0] maxDigit = 'd3;
	localparam [3:0] x_digit_limit= 'd14;
	
	// Inputs
	input clk, scoreDrawReset, scoreDrawEnable;
	input [7:0] scoreValue;
	
	// Postion to draw digit at
	input [7:0] x;
	input [7:0] y;
	
	// output Signal
	output reg scoreDrawEnd;
	
	// Current X , Y and Colour
	output [7:0] x_draw;
	output [7:0] y_draw; 
	
	output [23:0] outColour ;
	
	reg [1:0] digit_count;
	reg [3:0] digitValue;
	
	wire digitDrawEnd;
	wire [7:0] x_pass, y_pass;
	reg digitDrawReset;
	
	always@(posedge clk)
		begin
			if(scoreDrawEnable) begin
				if(~digitDrawEnd)
					digitDrawReset=0;
				else begin
					digitDrawReset =1;
					if(digit_count < maxDigit )
						digit_count <= digit_count + 1;
					else
						begin
						scoreDrawEnd <= 1;
						digit_count <= 1;//should be 0
						end
				end
			end
			if(scoreDrawReset) begin
				digit_count <= 0;
				scoreDrawEnd <= 0;
				digitDrawReset =1;
			end
		end
	
	assign x_pass = x_digit_limit*digit_count+x;
	assign y_pass = y;
	
	wire[3:0] leftDigit, middleDigit, rightDigit;
	
	binToBCD myBCD(scoreValue, leftDigit, middleDigit, rightDigit);
	
	always @ (posedge clk )begin
		begin: digit_count_cases
			case(digit_count)
				2'b00: digitValue <= leftDigit;   //scoreValue/100;
				2'b01: digitValue <= middleDigit; //(scoreValue-scoreValue/100*100)/10;
				2'b10: digitValue <= rightDigit;  //scoreValue-scoreValue/100*100-scoreValue/10*10;
				default: digitValue <= 'd11;//error case handled by digitDraw select
			endcase
		end
	end
		
	digitDraw unitdraw(clk, scoreDrawEnable, digitValue, digitDrawEnd, digitDrawReset, x_pass, y_pass, x_draw, y_draw, outColour);		
endmodule 