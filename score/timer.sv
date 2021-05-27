
module timer (
    input logic clk,
    input logic resetN,
	input logic enable,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,
	input logic game_over,
	
    output logic timerDR,
    output logic [7:0] timerRGB,
	output logic [DIGIT_AMOUNT - 1:0] [6:0] ss // Output for 7Seg display
	);
	
	parameter unsigned DIGIT_AMOUNT = 3;
	parameter unsigned LEFT_DIGIT_POSITION_X = 330;
	parameter unsigned DIGIT_COLOR = 8'b10000000;
	logic one_sec;
	
	one_sec_counter one_sec_counter_inst(
		.clk			(clk),
		.enable			(enable),
		.resetN			(resetN),
		.one_sec		(one_sec));
		
	draw_digits #(.LEFT_DIGIT_POSITION_X(LEFT_DIGIT_POSITION_X), .DIGIT_COLOR(DIGIT_COLOR)) timer_digits_inst(
		.clk			(clk),		
		.resetN			(resetN),		
		.pixelX			(pixelX),	
		.pixelY			(pixelY),	
		.add_amount		(one_sec),
		.game_over	 	(game_over),
		
		.digitDR		(timerDR),
		.digitRGB		(timerRGB),
		.ss				(ss)
		);
		
endmodule
