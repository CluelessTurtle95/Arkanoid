module speedControl(
    input clk,
    output pulse
);
    parameter [26:0] data = 'd50000000;
    reg [26:0] Q;

    always@(posedge clk)
        begin
            if (Q == 27'b0) 
                begin
                    Q <= data;
                end
            else
                begin
                    Q <= Q -1;
                end
        end
	assign pulse = (Q == 0) ? 1 : 0;
endmodule 

module seg7 (input [3:0] c, output [6:0] led );
	assign led[0] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & c[0]);
	assign led[1] = (~c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & ~c[0]) | (c[3] & ~c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]);
	assign led[2] = (~c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]) | (c[3] & c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]);
	assign led[3] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & c[1] & ~c[0]) | (c[3] & c[2] & c[1] & c[0]);
	assign led[4] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & ~c[1] & ~c[0]) | (~c[3] & c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & ~c[2] & ~c[1] & c[0]);
	assign led[5] = (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & ~c[2] & c[1] & ~c[0]) | (~c[3] & ~c[2] & c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & c[0]);
	assign led[6] = (~c[3] & ~c[2] & ~c[1] & ~c[0]) | (~c[3] & ~c[2] & ~c[1] & c[0]) | (~c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & ~c[1] & ~c[0]);
endmodule 

module debugClock(clk, debug, newclk, KEY);
	input clk;
	input debug;
	input [3:0] KEY;
	output reg newclk;
	
	always@(*) begin
		if(~debug)
			newclk = clk;
		else
			newclk = KEY[3];
	end
	
endmodule 

module lfsr (out, clk, rst);

  output reg [3:0] out;
  input clk, rst;

  wire feedback;

  assign feedback = ~(out[3] ^ out[2]);

always @(posedge clk, posedge rst)
  begin
    if (rst)
      out = 4'b0;
    else
      out = {out[2:0],feedback};
  end
endmodule 

module binToBCD(
	sourceValue,
	Hundreds,
	Tens,
	Units
	);

	//input
	input [7:0] sourceValue;
	
	//outputs
	output reg [3:0]Hundreds, Tens, Units;
	
	integer count;
	always @(sourceValue)//change to clock?
	begin
		//initialise/reset by default
		Hundreds = 4'b0;
		Tens = 4'b0;
		Units = 4'b0;
		
		//looping through all bits to apply bin to BCD conversion algorithm
		for (count=7; count>=0; count=count-1)
		begin
			//add 3 to all columns bigger or equal to 5
			if (Hundreds >= 5)
				Hundreds = Hundreds + 3;
			if (Tens >= 5)
				Tens = Tens + 3;
			if (Units >= 5)
				Units = Units + 3;
				
			//shift to the left by one
			Hundreds = Hundreds << 1;
			Hundreds[0] = Tens[3];
			Tens = Tens << 1;
			Tens[0] = Units[3];
			Units = Units << 1;
			Units[0] = sourceValue[count];
		end
	end
endmodule 