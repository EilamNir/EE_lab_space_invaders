/* This module controls the different stages
	it's possible to change the parameters via parameters.sv file
	the current version has 4 stages:
	1) only chicken as enemy
	2) more chickens
	3) asteroids falling until you destroy the all - can go throw the player boundry
	4) boss stage - a big enemy with extended live - harder to kill, combined with alot of chicken
	each stage will give the player more points - for each kill
written by Nir Eilam and Gil Kapel, may 18th, 2021 */


module stage_controller
(
    input logic clk,
    input logic resetN,
	input logic start_game,  //SW on the FPGA
	input logic win_stage,   //monsters / boss / astro modules will sent this or the cheat buttom that "lies" the game you won
	
    output logic game_won,   // a declartion if you won the last stage
    output logic enable_monst,
	output logic enable_boss,
    output logic enable_astero,
    output logic enable_gift,
	output game_stage stage_num // for use of other models to determine what to do each stage
);

	`include "parameters.sv"

	enum  logic [2:0] {INIT, STAGE1, STAGE2, STAGE3, STAGE4, END_GAME}  next_gameStage, pres_gameStage; //Game stages manager

always_ff@(posedge clk or negedge resetN)	// state machine
	begin
        if(!resetN) begin 
			pres_gameStage <= INIT;
		end else begin 
			pres_gameStage <= next_gameStage;
		end
	end
	
always_comb
	begin
        next_gameStage = pres_gameStage;
        enable_monst   = 1'b0;
        enable_boss    = 1'b0;
        enable_astero  = 1'b0;
        enable_gift    = 1'b0;
        game_won 	   = 1'b0;
		
		case (pres_gameStage)
			INIT: begin  //a pre game stage - no monsters
				stage_num = game_stage'(0);
				if(start_game) next_gameStage = STAGE1;
			end
			STAGE1: begin
				stage_num = game_stage'(1);
				if(win_stage) next_gameStage = STAGE2;
				enable_monst = 1'b1;
			end
			STAGE2: begin
				stage_num = game_stage'(2);
				if(win_stage) next_gameStage = STAGE3;
				enable_monst = 1'b1;
				enable_gift = 1'b1;
			end
			STAGE3: begin
				stage_num = game_stage'(3);
				if(win_stage) next_gameStage = STAGE4;
				enable_astero = 1'b1;
			end
			STAGE4: begin
				stage_num = game_stage'(4);
				enable_boss = 1'b1;
				enable_monst = 1'b1;
				if(win_stage) next_gameStage = END_GAME;
			end
			
			END_GAME: begin  // the final game state = only if you won the game, similiar to init
				stage_num = game_stage'(0);
				game_won = 1'b1;
			end
		endcase
	end 
				
endmodule