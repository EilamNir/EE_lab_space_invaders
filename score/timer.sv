
module timer (
    input logic clk,
    input logic resetN,
	input logic enable,
    input coordinate pixelX,
    input coordinate pixelY,
	input logic game_over,
	
    output logic timerDR,
    output RGB timerRGB,
	output hex_dig [DIGIT_AMOUNT - 1:0] ss // Output for 7Seg display
);
	
	`include "parameters.sv"

	logic one_sec;
	
	one_sec_counter one_sec_counter_inst(
		.clk			(clk),
		.enable			(enable),
		.resetN			(resetN),
		.one_sec		(one_sec));
		
		draw_digits #(.DIGIT_COLOR(TIMER_COLOR), .SMALL_TOPLEFT_X(TIMER_SMALL_TOPLEFT_X), .SMALL_TOPLEFT_Y(TIMER_SMALL_TOPLEFT_Y),
	.LARGE_TOPLEFT_X(TIMER_LARGE_TOPLEFT_X), .LARGE_TOPLEFT_Y(TIMER_LARGE_TOPLEFT_Y)) timer_digits_inst(
	
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
