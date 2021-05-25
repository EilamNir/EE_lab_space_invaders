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
    input logic player_dead, //player module will sent this
    input logic skip_stage,  //command on the FPGA
    input logic pause,       //SW2 on the FPGA

    output logic game_won,
    output logic game_over,
    output logic enable_player,
    output logic enable_monst,
    output logic enable_boss,
    output logic enable_astero,
    output logic resetN_player,
    output logic resetN_monst,
    output logic resetN_astero,
    output logic resetN_Boss,
    output logic [2:0] stage_num
);

    enum  logic [2:0] {RESET, RUN, PAUSE, GAME_OVER, STAGE_WON}  next_st, pres_st; //state machine
    logic run_enable_monst;
    logic pause_enable_monst;
	logic pause_enable_astero;
	logic pause_enable_boss;
    logic skip_stage_pulse;
    logic previous_skip_stage;
    logic stable_start_game;
    logic stable_pause;
	logic run_resetN_monst;
	logic run_resetN_astero;
	logic run_resetN_Boss;
	logic run_enable_astero;
	logic run_enable_boss;
    // Create a short pulse when the skip_stage starts
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previous_skip_stage <= 1'b0;
        end else begin
            previous_skip_stage <= skip_stage;
        end
    end

    assign skip_stage_pulse = skip_stage & (~previous_skip_stage);

    //
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
        pause_enable_monst = 1'b1;
		pause_enable_astero = 1'b1;
		pause_enable_boss = 1'b1;
        game_over    = 1'b0;
        resetN_player= 1'b1;
        run_resetN_monst = 1'b1;
		run_resetN_astero = 1'b1;
        run_resetN_Boss = 1'b1;
        case (pres_st)
            RESET: begin
                resetN_player = 1'b0;
                run_resetN_monst  = 1'b0;
				run_resetN_astero = 1'b0;
				run_resetN_Boss = 1'b0;
                enable_player = 1'b0;
                pause_enable_monst = 1'b0;
				pause_enable_astero = 1'b0;
				pause_enable_boss 	= 1'b0;
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
                if(!stable_pause)          next_st = RUN;
                if(!stable_start_game)     next_st = RESET;
            end // pause

            STAGE_WON: begin
                run_resetN_monst = 1'b0;
                if(game_won | game_over) next_st = GAME_OVER;
                else next_st = RUN;

            end // STAGE_WON

            GAME_OVER: begin
                if(!game_won) game_over = 1'b1;
                enable_player = 1'b0;
                run_resetN_monst = 1'b0;
				run_resetN_astero = 1'b0;
				run_resetN_Boss = 1'b0;
                pause_enable_monst = 1'b0;
				pause_enable_astero = 1'b0;
				pause_enable_boss 	= 1'b0;
                if(!stable_start_game) next_st = RESET;
            end // GAME_OVER

        endcase
    end

    stage_controller stage_controller_inst(
        .clk(clk),
        .resetN(resetN),
        .start_game(stable_start_game),
        .win_stage(win_stage || skip_stage_pulse),
        .game_won (game_won),
        .enable_monst(run_enable_monst),
        .enable_boss(run_enable_boss),
        .enable_astero(run_enable_astero),
        .stage_num(stage_num)
    );


	assign enable_monst  = pause_enable_monst 	& run_enable_monst;
	assign enable_astero = pause_enable_astero 	& run_enable_astero;
	assign enable_boss	 = pause_enable_boss 	& run_enable_boss;
	assign resetN_monst	 = run_resetN_monst 	& run_enable_monst;
	assign resetN_astero = run_resetN_astero	& run_enable_astero;
	assign resetN_Boss	 = run_resetN_Boss		& run_enable_boss;

endmodule