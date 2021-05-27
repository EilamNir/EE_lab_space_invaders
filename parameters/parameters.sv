// Design parameters
// =================

`include "types.sv"


// -- General Parameters --

// Size of frame
localparam coordinate   FRAMESIZE_X = 639;
localparam coordinate   FRAMESIZE_Y = 479;

// Number of game stages. The 0 stage is not counted.
localparam game_stage   NUMBER_OF_STAGES = 4;

// General multiplier to convert to fixed point.
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
// we do all calculations with fixed point numbers to get a resolution of 1/64 pixel in calculations,
// we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
localparam fixed_point  FIXED_POINT_MULTIPLIER = 64;

// Map edge code bits to location
localparam
    BOTTOM_EDGE = 0,
    RIGHT_EDGE  = 1,
    TOP_EDGE    = 2,
    LEFT_EDGE   = 3;

// Map collision code bits to collision objects
localparam
    COLLISION_ENEMY_MISSILE = 0,
    COLLISION_ENEMY_ANY_BOUNDARY = 1,
    COLLISION_MISSILE_FAR_BOUNDARY = 2,
    COLLISION_PLAYER_ANY_BOUNDARY = 3,
    COLLISION_PLAYER_MISSILE = 4,
    COLLISION_ENEMY_FAR_BOUNDARY = 5,
    COLLISION_PLAYER_ENEMY = 6;


// -- Parameters for background module --
// Background colors
localparam RGB          BACKGROUND_MOVEMENT_ZONE_END_COLOR = 8'b10000000;
localparam RGB          BACKGROUND_STATISTICS_ZONE_COLOR = 8'b00000010;
localparam RGB          BACKGROUND_BACKGROUND_COLOR = 8'b00000000;
// Background zone locations
localparam coordinate   BACKGROUND_MOVEMENT_ZONE_OFFSET = 20;
localparam coordinate   BACKGROUND_STATISTICS_ZONE_OFFSET = 20;
localparam coordinate   BACKGROUND_UPPERBORDER = 20;
localparam coordinate   BACKGROUND_PLAYER_ZONE_Y = 310;
// Background end letters parameters
localparam coordinate   BACKGROUND_LETTER_X_SIZE = 64;
localparam coordinate   BACKGROUND_LETTER_Y_SIZE = 16;
localparam coordinate   BACKGROUND_LETTER_TOPLEFT_X = 63;
localparam coordinate   BACKGROUND_LETTER_TOPLEFT_Y = 159;
localparam RGB          BACKGROUND_GAME_WON_COLOR = 8'hFF;
localparam RGB          BACKGROUND_GAME_OVER_COLOR = 8'b10000000;
localparam unsigned     BACKGROUND_LETTER_SIZE_MULTIPLIER = 3;


// -- Parameters for hit detection module --
localparam unsigned     HIT_DETECTION_NUMBER_OF_OBJECTS = 9;
localparam unsigned     HIT_DETECTION_COLLISION_WIDTH = 7;


// -- Parameters for missile module --
localparam unsigned     MISSILE_SHOT_AMOUNT_WIDTH = 4;
localparam unsigned     SHOOTING_COOLDOWN_WIDTH = 8;


// -- Parameters for delay signal by frames module --
localparam unsigned     DELAY_SIGNAL_FRAMES_DELAY_WIDTH = 5;


// -- Parameters for monsters module --
localparam unsigned     MONSTERS_MONSTER_AMOUNT_WIDTH = 5;
localparam logic unsigned [MONSTERS_MONSTER_AMOUNT_WIDTH - 1:0] MONSTERS_MAX_MONSTER_AMOUNT = 16;
// Initial parameters for each monster is derived form these parameters.
// For actual parameter for each monster, look at the monsters module.
localparam coordinate   MONSTERS_INITIAL_X = 100;
localparam coordinate   MONSTERS_INITIAL_Y = 50;
localparam fixed_point  MONSTERS_X_SPEED = fixed_point'(-24);
localparam fixed_point  MONSTERS_Y_SPEED = fixed_point'(-15);
localparam coordinate   MONSTERS_X_SPACING = 128;
localparam coordinate   MONSTERS_Y_SPACING = 64;
localparam coordinate   MONSTERS_X_SIZE = 32;
localparam coordinate   MONSTERS_Y_SIZE = 32;
localparam logic [DELAY_SIGNAL_FRAMES_DELAY_WIDTH - 1:0] MONSTERS_EXPLOSION_DELAY = 10;
// Missile parameters
localparam logic [MISSILE_SHOT_AMOUNT_WIDTH-1:0] MONSTERS_SHOT_AMOUNT = 4;
localparam fixed_point  MONSTERS_MISSILE_X_SPEED = 0;
localparam fixed_point  MONSTERS_MISSILE_Y_SPEED = 128;
localparam coordinate   MONSTERS_MISSILE_X_OFFSET = 15;
localparam coordinate   MONSTERS_MISSILE_Y_OFFSET = 28;
localparam RGB          MONSTERS_MISSILE_COLOR = 8'hD0;


// -- Parameters for player lives module --
localparam coordinate   PLAYER_LIVES_X_SIZE = 8;
localparam coordinate   PLAYER_LIVES_Y_SIZE = 8;
// Initial parameters for each lives icon in derived from these parameters.
// For actual parameter for each lives icon, look at the player module.
localparam coordinate   PLAYER_LIVES_TOPLEFT_X = 32;
localparam coordinate   PLAYER_LIVES_TOPLEFT_Y = 467;


// -- Parameters for player module --
// Movement keys
localparam UP_KEY    = 9'h06C; // digit 7
localparam DOWN_KEY  = 9'h075; // digit 8
localparam RIGHT_KEY = 9'h14A; // key '/'
localparam LEFT_KEY  = 9'h073; // digit 5
localparam SHOOT_KEY = 9'h15A; // enter key
// Lives parameters
localparam unsigned     PLAYER_LIVES_AMOUNT_WIDTH = 4;
localparam logic unsigned [PLAYER_LIVES_AMOUNT_WIDTH - 1:0] PLAYER_LIVES_AMOUNT = 4;
localparam unsigned PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH = 5;
localparam logic unsigned [PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH - 1:0] PLAYER_DAMAGED_FRAME_AMOUNT = 30;
// Missile parameters
localparam logic [SHOOTING_COOLDOWN_WIDTH - 1:0] PLAYER_SHOT_COOLDOWN = 15;
localparam logic [MISSILE_SHOT_AMOUNT_WIDTH-1:0] PLAYER_SHOT_AMOUNT = 7;
localparam fixed_point  PLAYER_MISSILE_X_SPEED = fixed_point'(0);
localparam fixed_point  PLAYER_MISSILE_Y_SPEED = fixed_point'(-256);
localparam coordinate   PLAYER_MISSILE_X_OFFSET = 15;
localparam coordinate   PLAYER_MISSILE_Y_OFFSET = 0;
localparam RGB          PLAYER_MISSILE_COLOR = 8'h1F;
// Movement parameters
localparam coordinate   PLAYER_INITIAL_X = 300;
localparam coordinate   PLAYER_INITIAL_Y = 400;
localparam fixed_point  PLAYER_X_SPEED = fixed_point'(128);
localparam fixed_point  PLAYER_Y_SPEED = fixed_point'(128);
// Bitmap parameters
localparam coordinate   PLAYER_X_SIZE = 32;
localparam coordinate   PLAYER_Y_SIZE = 32;


// -- Parameters for boss module --
// Lives parameters
localparam unsigned     BOSS_LIVES_AMOUNT_WIDTH = 4;
localparam logic unsigned [BOSS_LIVES_AMOUNT_WIDTH - 1:0] BOSS_LIVES_AMOUNT = 15;
localparam unsigned BOSS_DAMAGED_FRAME_AMOUNT_WIDTH = 5;
localparam logic unsigned [BOSS_DAMAGED_FRAME_AMOUNT_WIDTH - 1:0] BOSS_DAMAGED_FRAME_AMOUNT = 10;
// Movement parameters
localparam coordinate   BOSS_INITIAL_X = 287;
localparam coordinate   BOSS_INITIAL_Y = 49;
localparam fixed_point  BOSS_X_SPEED = fixed_point'(64);
localparam fixed_point  BOSS_Y_SPEED = fixed_point'(-25);
localparam coordinate   BOSS_X_SIZE = 64;
localparam coordinate   BOSS_Y_SIZE = 64;
// Missile parameters
localparam unsigned     BOSS_MISSILE_AMOUNT_WIDTH = 4;
localparam logic unsigned [BOSS_MISSILE_AMOUNT_WIDTH-1:0] BOSS_MISSILE_AMOUNT = 8;
localparam logic [MISSILE_SHOT_AMOUNT_WIDTH-1:0] BOSS_SHOT_AMOUNT = 4;
// Initial parameters for each missiles in derived from these parameters.
// For actual parameter for each missiles, look at the boss module.
localparam fixed_point  BOSS_MISSILE_X_SPEED = 8;
localparam fixed_point  BOSS_MISSILE_Y_SPEED = 100;
localparam coordinate   BOSS_MISSILE_X_OFFSET = 31;
localparam coordinate   BOSS_MISSILE_Y_OFFSET = 60;
localparam RGB          BOSS_MISSILE_COLOR = 8'hC0;

// -- Parameters for draw digit module --

localparam unsigned     MAX_VALUE_PER_DIGIT = 9;
localparam unsigned     DIGIT_AMOUNT_WIDTH = 2;
localparam logic unsigned [DIGIT_AMOUNT_WIDTH-1:0] DIGIT_AMOUNT = 3;
localparam unsigned     SIZE_MULTIPLIER = 3;

// -- Parameters for score module --
localparam unsigned 	SCORE_COLOR = 8'b00010000;
// Initial parameters for each score digit in derived from these parameters.
// For actual parameter for each score digit, look at the score module.
localparam coordinate   SCORE_SMALL_TOPLEFT_X = 600;
localparam coordinate   SCORE_SMALL_TOPLEFT_Y = 466;
localparam coordinate   SCORE_LARGE_TOPLEFT_X = 620;
localparam coordinate   SCORE_LARGE_TOPLEFT_Y = 349;

// -- Parameters for timer module --
localparam unsigned 	TIMER_COLOR = 8'b10000000;
localparam coordinate   TIMER_SMALL_TOPLEFT_X = 330;
localparam coordinate   TIMER_SMALL_TOPLEFT_Y = 466;
localparam coordinate   TIMER_LARGE_TOPLEFT_X = 350;
localparam coordinate   TIMER_LARGE_TOPLEFT_Y = 349;

// Parameters for numbers bitmap
localparam coordinate   NUMBERS_X_SIZE = 6;
localparam coordinate   NUMBERS_Y_SIZE = 10;


// -- Parameters for up counter module --
localparam unsigned     UP_COUNTER_DIGIT_WIDTH = 4;


// -- Parameters for asteroids module --
localparam unsigned     ASTEROIDS_AMOUNT_WIDTH = 5;
localparam logic unsigned [ASTEROIDS_AMOUNT_WIDTH - 1:0] ASTEROIDS_AMOUNT = 20;
// Initial parameters for each asteroid is derived form these parameters.
// For actual parameter for each asteroid, look at the asteroids module.
localparam coordinate   ASTEROIDS_INITIAL_X = 33;
localparam coordinate   ASTEROIDS_INITIAL_Y = 21;
localparam fixed_point  ASTEROIDS_X_SPEED = 90;
localparam fixed_point  ASTEROIDS_Y_SPEED = 60;
localparam coordinate   ASTEROIDS_X_SPACING = 96;
localparam coordinate   ASTEROIDS_Y_SPACING = 32;
localparam coordinate   ASTEROIDS_X_SIZE = 32;
localparam coordinate   ASTEROIDS_Y_SIZE = 32;
localparam logic [DELAY_SIGNAL_FRAMES_DELAY_WIDTH - 1:0] ASTEROIDS_EXPLOSION_DELAY = 10;


// -- Parameters for asteroids move module --
localparam unsigned     ASTEROIDS_MOVE_GRAVITY_COUNTER_WIDTH = 3;
localparam logic unsigned [ASTEROIDS_MOVE_GRAVITY_COUNTER_WIDTH - 1:0] ASTEROIDS_MOVE_FRAMES_WITHOUT_GRAVITY = 5;
localparam fixed_point  ASTEROIDS_MOVE_MAXIMUM_SPEED_MULTIPLIER = 4;


// -- Parameters for video unit module --
localparam unsigned     VIDEO_UNIT_NUMBER_OF_OBJECTS_WIDTH = 4;
localparam logic unsigned [VIDEO_UNIT_NUMBER_OF_OBJECTS_WIDTH - 1:0] VIDEO_UNIT_NUMBER_OF_OBJECTS = 11;
