//-- this module control the high level game:
//-- initialize, run the game, pause and winning or losing
//-- also control the different stages
//-- written by Nir Eilam and Gil Kapel, may 18th, 2021


module stage_controller
(
    input logic clk,
    input logic resetN,
	input logic start_game,  //SW on the FPGA
	input logic win_stage,   //monsters / boss / astro modules will sent this
	
    output logic game_won,
    output logic enable_monst,
	output logic enable_boss,
    output logic enable_astero,
	output logic [2:0] stage_num 
);

	enum  logic [2:0] {INIT, STAGE1, STAGE2, STAGE3, STAGE4}  next_gameStage, pres_gameStage; //Game stages manager

always_ff@(posedge clk or negedge resetN)	
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
        game_won 	   = 1'b0;
		
		case (pres_gameStage)
			INIT: begin
				stage_num = INIT;
				if(start_game) next_gameStage = STAGE1;
			end
			STAGE1: begin
				stage_num = STAGE1;
				if(win_stage) next_gameStage = STAGE2;
				enable_monst = 1'b1;
			end
			STAGE2: begin
				stage_num = STAGE2;
				if(win_stage) next_gameStage = STAGE3;
				enable_monst = 1'b1;
			end
			STAGE3: begin
				stage_num = STAGE3;
				if(win_stage) next_gameStage = STAGE4;
				enable_astero = 1'b1;
			end
			STAGE4: begin
				stage_num = STAGE4;			
				enable_boss = 1'b1;
				enable_monst = 1'b1;
				if(win_stage) begin
					game_won = 1'b1;
					next_gameStage = STAGE1;
				end
			end
		endcase
	end 
				
endmodule