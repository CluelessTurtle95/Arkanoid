
module Keyboard (
		// Inputs
		clk,
		reset,
		// Bidirectionals
		PS2_CLK,
		PS2_DAT,
		last_data_received
	);
	// Inputs
	input				clk,reset;

	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;

	// Internal Wires
	wire		[7:0]	ps2_key_data;
	wire				ps2_key_pressed;

	// Internal Registers
	output reg			[7:0]	last_data_received;

	// State Machine Registers

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			last_data_received <= 8'h00;
		else if (ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end

	PS2_Controller PS2 (
		// Inputs
		.CLOCK_50				(clk),
		.reset				(reset),

		// Bidirectionals
		.PS2_CLK			(PS2_CLK),
		.PS2_DAT			(PS2_DAT),

		// Outputs
		.received_data		(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);
endmodule
