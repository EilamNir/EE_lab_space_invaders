/* player module
	determine which key will make the player move and shotKeyIsPressed
	control the speed, location, draw request and shooting of the player
	the lives control in this moudle will count each time there is a coliision between the player 
	and an enemy missile or asteroid and sent a pulse when the amount reaches a certian amount
	
written by Nir Eilam and Gil Kapel, May 18th, 2021 */


module  player (
    input logic clk,
    input logic resetN,
	input logic enable,
    input keycode keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
    input coordinate pixelX,
    input coordinate pixelY,
    input collision_t collision,
    input logic powerup,

    output logic playerDR,
    output RGB playerRGB,

    output logic missleDR,
    output RGB missleRGB,

    output logic livesDR,
    output RGB livesRGB,

    output logic player_dead // single pulse that stays static after rising up
);

    `include "parameters.sv"

    coordinate topLeftX;
    coordinate topLeftY;
    coordinate offsetX;
    coordinate offsetY;
    logic squareDR;
    edge_code HitEdgeCode;  //control a hit with the edge of the player draw
    logic shooting_pusle;
    RGB bitmapRGB;
    logic [PLAYER_LIVES_AMOUNT_WIDTH - 1:0] remaining_lives;
    logic player_faded;  // when the player is hit, his draw will flick and he will be ivonerable for a few frames
    logic player_damaged;
    logic double_missile_speed;
    logic [SHOOTING_COOLDOWN_WIDTH - 1:0] shooting_cooldown;
    
    logic upIsPress;
    logic downIsPress;
    logic RightIsPress;
    logic LeftIsPress;
    logic shotKeyIsPressed;

    // Get player controlls
    player_controls player_controls_inst(
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brake(brake),
        .upIsPress(upIsPress),
        .downIsPress(downIsPress),
        .RightIsPress(RightIsPress),
        .LeftIsPress(LeftIsPress),
        .shotKeyIsPressed(shotKeyIsPressed)
    );

    player_move player_move_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame & (enable)),
        .move_left(LeftIsPress),
        .move_right(RightIsPress),
        .move_up(upIsPress),
        .move_down(downIsPress),
        .border_collision(collision[COLLISION_PLAYER_ANY_BOUNDARY]),
        .HitEdgeCode(HitEdgeCode),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    square_object #(
        .OBJECT_WIDTH_X(PLAYER_X_SIZE),
        .OBJECT_HEIGHT_Y(PLAYER_Y_SIZE)
    ) square_object_inst(
        .clk			(clk),
        .resetN			(resetN),
        .pixelX			(pixelX),
        .pixelY			(pixelY),
        .topLeftX		(topLeftX),
        .topLeftY		(topLeftY),
        .offsetX		(offsetX),
        .offsetY		(offsetY),
        .drawingRequest	(squareDR)
        );


    spaceShipBitMap spaceShipBitMap_inst(
        .clk			(clk),
        .resetN			(resetN),
        .offsetX		(offsetX),
        .offsetY		(offsetY),
        .InsideRectangle(squareDR),
        .drawingRequest	(playerDR),
        .RGBout			(bitmapRGB),
        .HitEdgeCode	(HitEdgeCode)
        );

    lives #(
        .LIVES_AMOUNT_WIDTH(PLAYER_LIVES_AMOUNT_WIDTH),
        .LIVES_AMOUNT(PLAYER_LIVES_AMOUNT),
        .DAMAGED_FRAME_AMOUNT_WIDTH(PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH),
        .DAMAGED_FRAME_AMOUNT(PLAYER_DAMAGED_FRAME_AMOUNT)
    ) lives_inst(
        .clk              (clk),
        .resetN           (resetN),
        .startOfFrame     (startOfFrame & (enable)),
        .missile_collision(collision[COLLISION_PLAYER_MISSILE] || collision[COLLISION_PLAYER_ENEMY]),
        .remaining_lives  (remaining_lives),
        .player_faded     (player_faded),
        .player_damaged   (player_damaged),
        .player_dead      (player_dead)
        );

    assign playerRGB = RGB'((player_faded == 1'b1) ? RGB'('b0) : bitmapRGB) ;

    // Display player lives on screen
    player_lives player_lives_inst(
            .clk(clk),
            .resetN(resetN),
            .pixelX(pixelX),
            .pixelY(pixelY),
            .remaining_lives(remaining_lives),
            .livesDR(livesDR),
            .livesRGB(livesRGB)
        );

    // Have a delay between shooting, so there will not be constant shooting.
    shooting_cooldown shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (shotKeyIsPressed & (~player_damaged)), // prevent shooting when the player is hit
        .shooting_cooldown(shooting_cooldown),
        .shooting_pusle(shooting_pusle)
        );

    missiles #(
        .SHOT_AMOUNT(PLAYER_SHOT_AMOUNT),
        .X_SPEED(PLAYER_MISSILE_X_SPEED),
        .Y_SPEED(PLAYER_MISSILE_Y_SPEED),
        .X_OFFSET(PLAYER_MISSILE_X_OFFSET),
        .Y_OFFSET(PLAYER_MISSILE_Y_OFFSET),
        .MISSILE_COLOR(PLAYER_MISSILE_COLOR)
    ) missiles_inst(
        .clk            (clk),
        .resetN         (resetN),
        .shooting_pusle (shooting_pusle),
        .startOfFrame   (startOfFrame & (enable)),
        .collision      ((collision[COLLISION_ENEMY_MISSILE] | collision[COLLISION_MISSILE_FAR_BOUNDARY])),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .double_y_speed (double_missile_speed),
        .missleDR       (missleDR),
        .missleRGB      (missleRGB)
        );

    player_powerup player_powerup_inst (
        .clk(clk),
        .resetN(resetN),
        .powerup(powerup),
        .giftIsHit(collision[COLLISION_PLAYER_GIFT]),
        .shooting_cooldown(shooting_cooldown),
        .double_missile_speed(double_missile_speed)
        );


endmodule
