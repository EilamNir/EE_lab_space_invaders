/* score module

	a score counter, add amount duo to different enemies and different stages
	
written by Nir Eilam and Gil Kapel, May 20th, 2021 */

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
	logic [2:0] stage_amount;
	// add score duo to the current stage
	assign stage_amount = ({(monster_died_pulse & (stage_num != 4)), boss_died_pulse, asteroid_exploded_pulse} != 0) ? stage_num : 1'b0;
    // add different score when there are chickens and boss in the same stage
	assign combined_stage_amount = (monster_died_pulse & (stage_num == 4)) ? 1'b1 : 1'b0;
	assign add_amount = (monster_died_pulse & (stage_num == 4)) ? stage_amount : combined_stage_amount;
	
	// draw the score digits in the right buttom of the screen (and big drawing when the game is over)
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
