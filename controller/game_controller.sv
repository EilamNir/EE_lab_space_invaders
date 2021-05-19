//-- this module control the high level game:
//-- initialize, run the game, pause and winning or losing
//-- also control the different stages
//-- written by Nir Eilam and Gil Kapel, may 18th, 2021


module game_controller
(
    input logic clk,
    input logic resetN,
	input logic start_game,
	input logic win_stage, 
	input logic last_stage,
	input logic player_destroyed, 
	input logic skip_stage, //command on the FPGA
	input logic pause, //SW on the FPGA
	
    output logic enable_player,
    output logic enable_monsters,
    output logic game_won,
    output logic game_over,
	output logic resetN_player,
	output logic resetN_monsters,
	output logic [2:0] stage_num
);

	enum  logic [2:0] {RESET, RUN, PAUSE, GAME_OVER, STAGE_WON}  next_st, pres_st; //state machine
	enum  logic [2:0] {stage1, stage2, stage3, stage4}  next_gameStage, pres_gameStage; //Game stages manager


always_ff@(posedge clk or negedge resetN)	
	begin
        if(!resetN) begin 
			pres_st <= RESET;
			pres_gameStage <= stage1;
			stage_num <= stage1;
		end else begin 
			pres_st <= next_st;
			pres_gameStage <= next_gameStage;
		end
	end
	
always_comb
	begin
		next_st = pres_st;
		next_gameStage = pres_gameStage;
        enable_player = 1'b0;
        enable_monsters = 1'b0;
        game_won = 1'b0;
        game_over = 1'b0;
	    resetN_player = 1'b1;
	    resetN_monsters = 1'b1;
		
		case (pres_st)
			RESET: begin
				if(start_game) next_st = RUN;  //next state 
				resetN_player = 1'b0;
				resetN_monsters = 1'b0;
				pres_gameStage = stage1;
			end // reset_game
			
			RUN: begin
				enable_player = 1'b1;
				enable_monsters = 1'b1;
				if(skip_stage && pres_gameStage != stage4) next_gameStage = pres_gameStage + 1'b1; 
				if(pause) 	next_st = PAUSE;
				else if(player_destroyed)   next_st = GAME_OVER; 
				else if(win_stage)    		next_st = STAGE_WON;
			end // run game
				
			PAUSE: begin
				enable_player = 1'b0;
				enable_monsters = 1'b0;
				if(!pause)    next_st = RUN;  
			end // pause
			
			STAGE_WON: begin
				if(pres_gameStage == stage4) next_st = GAME_OVER;   
				else begin
					next_st = RUN;
					resetN_monsters = 1'b0;
					stage_num = pres_gameStage;
					next_gameStage = pres_gameStage + 1'b1;
				end
			end // STAGE_WON
			
			GAME_OVER: begin
				if(!resetN) next_st = RESET;  
				enable_player = 1'b0;
				enable_monsters = 1'b0;
			end // GAME_OVER
    	
    	endcase
	end
	
endmodule