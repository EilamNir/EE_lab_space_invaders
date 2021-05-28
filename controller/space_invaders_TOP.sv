module space_invaders_TOP
(
    input logic CLOCK_50,
    input logic resetN,
	input logic start_game,
	input logic cheatN,
	input logic pause,
    input logic PS2_CLK,
    input logic PS2_DAT,
    input logic AUD_ADCDAT,

    output hex_dig HEX0,
    output hex_dig HEX1,
    output hex_dig HEX2,
	output hex_dig HEX3,
    output hex_dig HEX4,
    output hex_dig HEX5,
    output VGA OVGA,
    inout audio AUDOUT
);

    `include "parameters.sv"

    logic clk;
    logic startOfFrame;
    coordinate pixelX;
    coordinate pixelY;
    RGB background_RGB;


    RGB playerRGB;
    RGB livesRGB;
    RGB scoreRGB;
	RGB timerRGB;
    RGB player_missleRGB;
    RGB monster_missleRGB;
    RGB monsterRGB;
    RGB asteroidsRGB;
    RGB BossRGB;
	RGB Boss_missleRGB;
	RGB end_game_RGB;
    RGB giftRGB;

    RGB [0:VIDEO_UNIT_NUMBER_OF_OBJECTS - 1] obj_RGB;
    assign obj_RGB = {playerRGB, player_missleRGB, monsterRGB, monster_missleRGB, asteroidsRGB, BossRGB, Boss_missleRGB, giftRGB, livesRGB, scoreRGB, timerRGB, end_game_RGB};
    logic player_missleDR;
    logic monster_missleDR;
    logic playerDR;
    logic livesDR;
    logic scoreDR;
	logic timerDR;
    logic monsterDR;
    logic asteroidsDR;
    logic BossDR;	
    logic Boss_missleDR;
	logic end_gameDR;
    logic giftDR;
    logic [0:1] bordersDR;
    assign bordersDR = {bordersDR[0], bordersDR[1]}; //bordersDR[0] = all around borders, bordersDR[1] = player end zone
    logic [0:HIT_DETECTION_NUMBER_OF_OBJECTS - 1 - 2] draw_requests_for_hits;
    assign draw_requests_for_hits = {playerDR, player_missleDR, monsterDR, monster_missleDR, asteroidsDR, BossDR, Boss_missleDR, giftDR};
    logic [0:VIDEO_UNIT_NUMBER_OF_OBJECTS - 1] draw_requests;
    assign draw_requests = {draw_requests_for_hits, livesDR, scoreDR, timerDR, end_gameDR};
    logic [0:HIT_DETECTION_NUMBER_OF_OBJECTS - 1] hit_request;
    assign hit_request = {bordersDR, draw_requests_for_hits};

    keycode keyCode;
    logic make;
    logic brake;

    logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] HitPulse;
    logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] collision;

    logic monster_died_pulse;
    logic all_monsters_dead;
    logic powerup;

    logic [0:1] sound_requests;
    assign sound_requests = {collision[COLLISION_ENEMY_MISSILE], collision[COLLISION_PLAYER_MISSILE] | collision[COLLISION_PLAYER_ENEMY]};

    clock_divider clock_div_inst (
        .refclk(CLOCK_50),
        .rst(~resetN),
        .outclk_0(clk));

    keyboard_interface kbd_inst(
        .clk(clk),
        .resetN(resetN),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .keyCode(keyCode),
        .make(make),
        .brake(brake)
        );

	logic player_dead;
	logic win_chicken_stage;
	logic win_astero_stage;
	logic enable_player;
	logic enable_monst;
	logic enable_boss;
	logic enable_astero;
    logic enable_gift;
	logic game_won;
	logic game_over;
	logic resetN_player;
	logic resetN_monst;
	logic resetN_asteroids;
	logic resetN_Boss;
    logic resetN_gift;
	game_stage stage_num;
	logic asteroid_exploded;
	logic boss_dead;

    game_controller controller_inst(
        .clk            (clk),
        .resetN         (resetN),
		.start_game		(start_game),
		.win_stage		((win_chicken_stage & !enable_boss) | win_astero_stage | boss_dead), 
		.player_dead	(player_dead), 
		.skip_stage		(~cheatN), 
		.pause			(pause), 
		.game_won		(game_won),
		.game_over		(game_over),
		.enable_player	(enable_player),
		.enable_monst   (enable_monst),
		.enable_boss	(enable_boss),
		.enable_astero  (enable_astero),
        .enable_gift    (enable_gift),
		.resetN_player	(resetN_player),
		.resetN_monst	(resetN_monst),
		.resetN_astero	(resetN_asteroids),
		.resetN_Boss	(resetN_Boss),
        .resetN_gift    (resetN_gift),
		.stage_num		(stage_num));

    player player_inst (
        .clk            (clk),
        .resetN         (resetN & resetN_player),
		.enable			(enable_player),
        .keyCode        (keyCode),
        .make           (make),
        .brake          (brake),
        .startOfFrame   (startOfFrame),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .collision      (collision),
        .powerup        (powerup),
        .playerDR       (playerDR),
        .playerRGB      (playerRGB),
		.player_dead	(player_dead),
        .missleDR       (player_missleDR),
        .missleRGB      (player_missleRGB),
        .livesDR        (livesDR),
        .livesRGB       (livesRGB));

    monsters monsters_inst (
        .clk            (clk),
        .resetN         (resetN & resetN_monst),
		.enable			(enable_monst),
        .startOfFrame   (startOfFrame),
        .collision      (collision),
		.stage_num   	(stage_num),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .monsterDR      (monsterDR),
        .monsterRGB     (monsterRGB),
        .missleDR       (monster_missleDR),
        .missleRGB      (monster_missleRGB),
        .monster_died_pulse(monster_died_pulse),
        .all_monsters_dead(win_chicken_stage));
	
	asteroids asteroids_inst(
        .clk            (clk),
        .resetN         (resetN & resetN_asteroids),
		.enable			(enable_astero),
        .startOfFrame   (startOfFrame),
        .collision      (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
		.asteroidsDR	(asteroidsDR),
		.asteroid_exploded_pulse(asteroid_exploded),
		.all_asteroids_destroied (win_astero_stage),
		.asteroidsRGB	(asteroidsRGB));

	boss boss_inst(	
        .clk            (clk),
        .resetN         (resetN  & resetN_Boss),
		.enable			(enable_boss),
        .startOfFrame   (startOfFrame),
        .collision      (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
		.BossDR			(BossDR),
		.BossRGB		(BossRGB),
		.boss_dead		(boss_dead),
        .missleDR       (Boss_missleDR),
        .missleRGB      (Boss_missleRGB));

    gift gift_inst(
        .clk(clk),
        .resetN(resetN & resetN_gift),
        .enable(enable_gift),
        .startOfFrame(startOfFrame),
        .collision(collision),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .giftDR(giftDR),
        .giftRGB(giftRGB),
        .powerup(powerup));

    hit_detection hit_detection_inst (
        .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
        .hit_request    (hit_request),
        .collision      (collision),
        .HitPulse       (HitPulse));
		
    background background_inst (
        .clk            (clk),
        .resetN         (resetN),
		.game_won		(game_won),
		.game_over		(game_over),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .bordersDR      (bordersDR),
		.end_gameDR		(end_gameDR),
		.end_game_RGB	(end_game_RGB),
        .background_RGB (background_RGB));

    video_unit video_unit_inst (
        .clk            (clk),
        .resetN         (resetN),
        .draw_requests  (draw_requests),
        .obj_RGB        (obj_RGB),
        .background_RGB (background_RGB),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .startOfFrame   (startOfFrame),
        .oVGA           (OVGA));

    sound_unit sound_unit_inst (
        .clk			(clk),
        .resetN			(resetN),
        .sound_requests	(sound_requests),
        .startOfFrame	(startOfFrame),
        .AUD_ADCDAT		(AUD_ADCDAT),
        .AUDOUT			(AUDOUT));

    score score_inst (
        .clk			(clk),
        .resetN			(resetN),
        .pixelX			(pixelX),
        .pixelY			(pixelY),
		.stage_num 	  	(stage_num),
        .monster_died_pulse	(monster_died_pulse),
		.boss_died_pulse	(boss_dead),
		.asteroid_exploded_pulse(asteroid_exploded),
        .game_over          (game_over),

        .scoreDR		(scoreDR),
        .scoreRGB		(scoreRGB),
        .ss				({HEX2, HEX1, HEX0})
    );
	
	    timer timer_inst (
        .clk			(clk),
        .resetN			(resetN),
		.enable			(start_game & !pause & !game_over & !game_won),
        .pixelX			(pixelX),
        .pixelY			(pixelY),
        .game_over      (game_over),

        .timerDR		(timerDR),
        .timerRGB		(timerRGB),
        .ss				({HEX5, HEX4, HEX3})
    );

endmodule
