
module score (
    input logic clk,
    input logic resetN,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,
    input logic monster_died_pulse,
	input logic boss_died_pulse,
	input logic asteroid_exploded_pulse,
	input logic [2:0] stage_num,
    input logic game_over,

    output logic scoreDR,
    output logic [7:0] scoreRGB,
    output logic [DIGIT_AMOUNT - 1:0] [6:0] ss // Output for 7Seg display
);
    parameter unsigned DIGIT_AMOUNT = 3;
	logic [2:0] add_amount;
	assign add_amount = ({monster_died_pulse, boss_died_pulse, asteroid_exploded_pulse} != 0) ? stage_num : 1'b0;

	draw_digits score_digits_inst(
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
