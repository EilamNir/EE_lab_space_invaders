
module score (
    input logic clk,
    input logic resetN,
    input coordinate pixelX,
    input coordinate pixelY,
    input logic monster_died_pulse,
	input logic boss_died_pulse,
	input logic asteroid_exploded_pulse,
	input game_stage stage_num,
    input logic game_over,

    output logic scoreDR,
    output RGB scoreRGB,
    output hex_dig [SCORE_DIGIT_AMOUNT - 1:0] ss // Output for 7Seg display
);

    `include "parameters.sv"

	logic [2:0] add_amount;
	assign add_amount = ({monster_died_pulse, boss_died_pulse, asteroid_exploded_pulse} != 0) ? stage_num : 1'b0;
    
	draw_digits #(
		.DIGIT_COLOR(SCORE_COLOR),
		.SMALL_TOPLEFT_X(SCORE_SMALL_TOPLEFT_X),
		.SMALL_TOPLEFT_Y(SCORE_SMALL_TOPLEFT_Y),
		.LARGE_TOPLEFT_X(SCORE_LARGE_TOPLEFT_X),
		.LARGE_TOPLEFT_Y(SCORE_LARGE_TOPLEFT_Y),
		.DIGIT_AMOUNT_WIDTH(SCORE_DIGIT_AMOUNT_WIDTH),
		.DIGIT_AMOUNT(SCORE_DIGIT_AMOUNT)
	) score_digits_inst(
	
		.clk			(clk),		
		.resetN			(resetN),
		.pixelX			(pixelX),	
		.pixelY			(pixelY),
		.add_amount		(add_amount),
		.game_over	 	(game_over),
		
		.digitDR		(scoreDR),
		.digitRGB		(scoreRGB),
		.ss				(ss)
		);
		
endmodule
