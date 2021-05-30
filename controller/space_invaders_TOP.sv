/* Top module
	this module connect all of the smaller modules:
	1) clock diveder
	2) keyboard_interface - recieve the keyboard input and translate it to key code and make & brake bits
	3) game_controller - control the high level game and stages
	4) video_unit - controls all of the draw requests and extract the output for the screen using vga controller 
	5) sound_unit - controls all of the sound requests and extract the output for the speaker using sinus generator and an internal module within the fpga  
	6) score - count and print the score the is accumulate during the game
	7) timer - count the time that the game is play (stops at pause or end game stages
	8) hit_detection - checks if two or more objects ask to be drawed in the same pixel at the same time and sent a relevent collision as an output
	9) player module - high level player module, combine the player's parameters, key buttons, amount of lives, position and speed and missiles
	10) monsters module - high level monsters module, combine the chicken's parameters, amount , position and speed and missiles
	11) asteroids module - high level asteroids module, combine the asteroids's parameters, amount , position and speed
	12) boss module - high level boss enemy module, combine the boss's parameters, amount of lives, position and speed and missiles
    13) gift module - high level gift power up module, combine the gift's parameters, position and speed
	14) background - the background of the game, include the end game announcements

written by Nir Eilam and Gil Kapel, May 30th, 2021 */

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

    video_RGB_t obj_RGB;
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
    video_logic_t draw_requests;
    assign draw_requests = {draw_requests_for_hits, livesDR, scoreDR, timerDR, end_gameDR};
    hit_request_t hit_request;
    assign hit_request = {bordersDR, draw_requests_for_hits};

    keycode keyCode;
    logic make;
    logic brake;

    collision_t HitPulse;
    collision_t collision;

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

    hit_detection hit_detection_inst (
        .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
        .hit_request    (hit_request),
        .collision      (collision),
        .HitPulse       (HitPulse));
		
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


endmodule
