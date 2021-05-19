//-- this module control each stage:
//-- 4 stages:
//-- 1) 
//-- Gil Kapel, may 18th, 2021


module stage_controller
(
    input logic clk,
    input logic resetN,
	input logic [2:0] stage_num,
	
    output logic ,
	output logic
);
	parameter stage1 2'b00;
	parameter stage2 2'b01;
	parameter stage3 2'b10;
	parameter stage4 2'b11;
always_comb
	begin
		next_st = pres_st;	
        enable_player = 1'b0;
        enable_monsters = 1'b0;
        game_won = 1'b0;
        game_over = 1'b0;
	    resetN_player = 1'b1;
	    resetN_monsters = 1'b1;
		
		case (stage_num)
			RESET: begin
				if(start_game) next_st = RUN;  //next state 
				resetN_player = 1'b0;
				resetN_monsters = 1'b0;
			end // reset_game
			
			RUN: begin
				enable_player = 1'b1;
				enable_monsters = 1'b1;
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
				if(last_stage) next_st = GAME_OVER;   
				else begin
					next_st = RUN;
					resetN_monsters = 1'b0;
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