//-- this module control the high level game:
//-- initialize, run , pause, announce the end of the game and control the differnt stages
//-- using the stage controller
//-- written by Nir Eilam and Gil Kapel, may 18th, 2021


module game_controller
(
    input logic clk,
    input logic resetN,
    input logic start_game,  //SW1 on the FPGA
    input logic win_stage,   //monsters / boss / astro modules will sent this
    input logic player_dead, //player module will sent this
    input logic skip_stage,  //command on the FPGA
    input logic pause,       //SW2 on the FPGA

    output logic game_won,   // a declartion if you won the last stage
    output logic game_over,  // a declartion if the player lost all lives and died
    output logic enable_player,
    output logic enable_monst,
    output logic enable_boss,
    output logic enable_astero,
    output logic enable_gift,
    output logic resetN_player,
    output logic resetN_monst,
    output logic resetN_astero,
    output logic resetN_Boss,
    output logic resetN_gift,
    output game_stage stage_num
);

    `include "parameters.sv"

    enum  logic [2:0] {RESET, RUN, PAUSE, GAME_OVER, STAGE_WON}  next_st, pres_st; //state machine
    logic run_enable_monst;
    logic pause_enable_monst;
	logic pause_enable_astero;
	logic pause_enable_boss;
    logic pause_enable_gift;
    logic skip_stage_pulse;
    logic previous_skip_stage;
    logic stable_start_game;
    logic stable_pause;
	logic run_resetN_monst;
	logic run_resetN_astero;
	logic run_resetN_Boss;
    logic run_resetN_gift;
	logic run_enable_astero;
	logic run_enable_boss;
    logic run_enable_gift;
    // Create a synchronic pulse when the skip_stage starts
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previous_skip_stage <= 1'b0;
        end else begin
            previous_skip_stage <= skip_stage;
        end
    end

    assign skip_stage_pulse = skip_stage & (~previous_skip_stage);

    //prevent click errors, if you try to turn on the pause switch and the turn off very fast, the game will behave properly
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            stable_start_game <= 1'b0;
            stable_pause <= 1'b0;
        end else begin
            stable_start_game <= start_game;
            stable_pause <= pause;
        end
    end

always_ff@(posedge clk or negedge resetN) //state machine
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
        pause_enable_monst = 1'b1;
		pause_enable_astero = 1'b1;
		pause_enable_boss = 1'b1;
        pause_enable_gift = 1'b1;
        game_over    = 1'b0;
        resetN_player= 1'b1;
        run_resetN_monst = 1'b1;
		run_resetN_astero = 1'b1;
        run_resetN_Boss = 1'b1;
        run_resetN_gift = 1'b1;
        case (pres_st)
            RESET: begin
                resetN_player = 1'b0;
                run_resetN_monst  = 1'b0;
				run_resetN_astero = 1'b0;
				run_resetN_Boss = 1'b0;
                run_resetN_gift = 1'b0;
                enable_player = 1'b0;
                pause_enable_monst = 1'b0;
				pause_enable_astero = 1'b0;
				pause_enable_boss 	= 1'b0;
                pause_enable_gift   = 1'b0;
                if(stable_start_game) next_st = RUN;  //next state
            end // reset_game

            RUN: begin
                if(stable_pause)                        next_st = PAUSE;
                else if(player_dead)                    next_st = GAME_OVER;
                else if(win_stage || skip_stage_pulse)  next_st = STAGE_WON;
                if(!stable_start_game)                  next_st = RESET;
            end // run game

            PAUSE: begin
                enable_player 		= 1'b0;
                pause_enable_monst 	= 1'b0;
				pause_enable_astero = 1'b0;
				pause_enable_boss 	= 1'b0;
                pause_enable_gift   = 1'b0;
                if(!stable_pause)          next_st = RUN;
                if(!stable_start_game)     next_st = RESET;
            end // pause

            STAGE_WON: begin
                run_resetN_monst = 1'b0;
                if(game_won) next_st = GAME_OVER;
                else next_st = RUN;

            end // STAGE_WON

            GAME_OVER: begin
                game_over = 1'b1;
                enable_player = 1'b0;
                resetN_player = 1'b0;
                run_resetN_monst = 1'b0;
				run_resetN_astero = 1'b0;
				run_resetN_Boss = 1'b0;
                run_resetN_gift = 1'b0;
                pause_enable_monst = 1'b0;
				pause_enable_astero = 1'b0;
				pause_enable_boss 	= 1'b0;
                pause_enable_gift   = 1'b0;
                if(!stable_start_game) next_st = RESET;
            end // GAME_OVER

        endcase
    end

    stage_controller stage_controller_inst(
        .clk(clk),
        .resetN(resetN),
        .start_game(stable_start_game),
        .win_stage(win_stage || skip_stage_pulse), //when runing, if you press the cheat buttom or you got a pulse from one of the enemies
        .game_won (game_won),
        .enable_monst(run_enable_monst),
        .enable_boss(run_enable_boss),
        .enable_astero(run_enable_astero),
        .enable_gift(run_enable_gift),
        .stage_num(stage_num)
    );


	assign enable_monst  = pause_enable_monst 	& run_enable_monst;  // determine the monster enable only if the stage and game state fits
	assign enable_astero = pause_enable_astero 	& run_enable_astero; // same to all others
	assign enable_boss	 = pause_enable_boss 	& run_enable_boss;
    assign enable_gift   = pause_enable_gift    & run_enable_gift;
	assign resetN_monst	 = run_resetN_monst 	& run_enable_monst;
	assign resetN_astero = run_resetN_astero	& run_enable_astero;
	assign resetN_Boss	 = run_resetN_Boss		& run_enable_boss;
    assign resetN_gift   = run_resetN_gift      & run_enable_gift;

endmodule