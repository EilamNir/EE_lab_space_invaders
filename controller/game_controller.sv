//-- this module control the high level game:
//-- initialize, run the game, pause and winning or losing
//-- also control the different stages
//-- written by Nir Eilam and Gil Kapel, may 18th, 2021


module game_controller
(
    input logic clk,
    input logic resetN,
	input logic start_game,  //SW1 on the FPGA
	input logic win_stage,   //monsters / boss / astro modules will sent this
	input logic player_died, //player module will sent this
	input logic skip_stage,  //command on the FPGA
	input logic pause, 		 //SW2 on the FPGA
	
    output logic game_won,
    output logic game_over,
	output logic enable_player,
    output logic enable_monst,
	output logic enable_boss,
    output logic enable_astero,
	output logic resetN_player,
	output logic resetN_monst,
	output logic [2:0] stage_num 
);

	enum  logic [2:0] {RESET, RUN, PAUSE, GAME_OVER, STAGE_WON}  next_st, pres_st; //state machine
	logic run_enable_monst;
	logic pause_enable_monst;
	
always_ff@(posedge clk or negedge resetN)	
	begin
        if(!resetN) begin 
			pres_st <= RESET;
		end else begin 
			pres_st <= next_st;
		end
	end
	
always_comb
	begin
        next_st = pres_st;
        enable_player= 1'b1;
		//		pause_enable_monst = 1'b1;
		enable_monst = 1'b1;
        game_won 	 = 1'b0;
        game_over    = 1'b0;
	    resetN_player= 1'b1;
	    resetN_monst = 1'b1;
		
		case (pres_st)
			RESET: begin
				if(start_game) next_st = RUN;  //next state
				else if(!start_game) next_st = RESET;
				resetN_player = 1'b0;
				resetN_monst  = 1'b0;
				enable_player = 1'b0;
				enable_monst  = 1'b0;
				//pause_enable_monst = 1'b0;
			end // reset_game
			
			RUN: begin 
				if(!start_game)			next_st = RESET;
				if(pause) 				next_st = PAUSE;
				else if(player_died)   	next_st = GAME_OVER; 
				else if(win_stage)    	next_st = STAGE_WON;
			end // run game
				
			PAUSE: begin
				if(!start_game)			next_st = RESET;
				enable_monst  = 1'b0;
				//pause_enable_monst = 1'b0;
				enable_player = 1'b0;
				if(!pause)    	next_st = RUN;	
				else if (pause) 			next_st = PAUSE;
			end // pause
			
			STAGE_WON: begin
				if(stage_num == 3'b100) next_st = GAME_OVER;
				else next_st = RUN;
				resetN_monst = 1'b0;
				
			end // STAGE_WON
			
			GAME_OVER: begin
				if(!resetN & !start_game) next_st = RESET; 
				if(win_stage) game_won = 1'b1;
				else game_over = 1'b1;
				enable_player = 1'b0;
				//pause_enable_monst = 1'b0;
			end // GAME_OVER
    	
    	endcase
	end
	stage_controller stage_controller_inst(
		.clk(clk),
		.resetN(resetN),
		.start_game(start_game),  
		.win_stage(win_stage),   
		.skip_stage (skip_stage),  
		.game_won (game_won),
		.game_over(game_over),
		.enable_monst(run_enable_monst),
		.enable_boss(enable_boss),
		.enable_astero(enable_astero),
		.stage_num(stage_num)
	);

	//assign enable_monst = pause_enable_monst & run_enable_monst;
endmodule