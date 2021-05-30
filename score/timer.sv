/* timer module
	a timer for the game counting only second from the start of the game until the end of it
	dont count when the game is in pause state
written by Nir Eilam and Gil Kapel, May 27th, 2021 */

module timer (
    input logic clk,
    input logic resetN,
	input logic enable,
    input coordinate pixelX,
    input coordinate pixelY,
	input logic game_over,
	
    output logic timerDR,
    output RGB timerRGB,
	output timer_hex_t ss // Output for 7Seg display
);
	
	`include "parameters.sv"

	logic one_sec;
	// make a single bit every second from a 50 MHz Clock
	one_sec_counter one_sec_counter_inst(
		.clk			(clk),
		.enable			(enable), //stop the clock when pausing or the game is over, start the time only when the game starts
		.resetN			(resetN),
		.one_sec		(one_sec));
	// draw the digits in the offset place
	
	draw_digits #(
		.DIGIT_COLOR(TIMER_COLOR),
		.SMALL_TOPLEFT_X(TIMER_SMALL_TOPLEFT_X),
		.SMALL_TOPLEFT_Y(TIMER_SMALL_TOPLEFT_Y),
		.LARGE_TOPLEFT_X(TIMER_LARGE_TOPLEFT_X),
		.LARGE_TOPLEFT_Y(TIMER_LARGE_TOPLEFT_Y),
		.DIGIT_AMOUNT_WIDTH(TIMER_DIGIT_AMOUNT_WIDTH),
		.DIGIT_AMOUNT(TIMER_DIGIT_AMOUNT)
	) timer_digits_inst(
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
