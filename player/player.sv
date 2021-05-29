/* player module

written by Nir Eilam and Gil Kapel, may 18th, 2021 */


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
    input logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] collision,

    output logic playerDR,
    output RGB playerRGB,

    output logic missleDR,
    output RGB missleRGB,

    output logic livesDR,
    output RGB livesRGB,

    output logic player_dead
);

    `include "parameters.sv"

    coordinate topLeftX;
    coordinate topLeftY;
    coordinate offsetX;
    coordinate offsetY;
    logic squareDR;
    edge_code HitEdgeCode;
    logic shooting_pusle;
    RGB bitmapRGB;
    logic [PLAYER_LIVES_AMOUNT_WIDTH - 1:0] remaining_lives;
    logic player_faded;
    logic player_damaged;

    logic upIsPress;
    keyToggle_decoder #(.KEY_VALUE(UP_KEY)) control_up_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(upIsPress)
        );

    logic downIsPress;
    keyToggle_decoder #(.KEY_VALUE(DOWN_KEY)) control_down_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(downIsPress)
        );

    logic RightIsPress;
    keyToggle_decoder #(.KEY_VALUE(RIGHT_KEY)) control_right_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(RightIsPress)
        );

    logic LeftIsPress;
    keyToggle_decoder #(.KEY_VALUE(LEFT_KEY)) control_left_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(LeftIsPress)
        );

    logic shotKeyIsPressed;

    keyToggle_decoder #(.KEY_VALUE(SHOOT_KEY)) control_strShot_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(shotKeyIsPressed)
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

    player_lives #(
        .LIVES_AMOUNT_WIDTH(PLAYER_LIVES_AMOUNT_WIDTH),
        .LIVES_AMOUNT(PLAYER_LIVES_AMOUNT),
        .DAMAGED_FRAME_AMOUNT_WIDTH(PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH),
        .DAMAGED_FRAME_AMOUNT(PLAYER_DAMAGED_FRAME_AMOUNT)
    ) player_lives_inst(
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

    logic [PLAYER_LIVES_AMOUNT - 1:0] lives_square_draw_requests;
    logic [PLAYER_LIVES_AMOUNT - 1:0] lives_draw_requests;
    coordinate [PLAYER_LIVES_AMOUNT - 1:0] lives_offsetX;
    coordinate [PLAYER_LIVES_AMOUNT - 1:0] lives_offsetY;

    genvar i;
    generate
        for (i = 0; i < PLAYER_LIVES_AMOUNT; i++) begin : generate_lives
            square_object #(
                .OBJECT_WIDTH_X(PLAYER_LIVES_X_SIZE),
                .OBJECT_HEIGHT_Y(PLAYER_LIVES_Y_SIZE)
            ) square_object_lives_inst(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (PLAYER_LIVES_TOPLEFT_X + (i * 16)),
                .topLeftY       (PLAYER_LIVES_TOPLEFT_Y),
                .offsetX        (lives_offsetX[i]),
                .offsetY        (lives_offsetY[i]),
                .drawingRequest (lives_square_draw_requests[i])
                );

            assign lives_draw_requests[i] = lives_square_draw_requests[i] & (i < remaining_lives);
        end
    endgenerate

    // Decide on which square object to pass into the bitmap
    logic chosen_lives_square_DR;
    coordinate chosen_lives_offsetX;
    coordinate chosen_lives_offsetY;
    always_comb begin
        chosen_lives_square_DR = 1'b0;
        chosen_lives_offsetX = 11'b0;
        chosen_lives_offsetY = 11'b0;
        for (logic unsigned [PLAYER_LIVES_AMOUNT_WIDTH - 1:0] j = 0; j < PLAYER_LIVES_AMOUNT; j++) begin
            // Only save the offset of the first square
            if (lives_draw_requests[j] == 1'b1) begin
                chosen_lives_square_DR = 1'b1;
                chosen_lives_offsetX = lives_offsetX[j];
                chosen_lives_offsetY = lives_offsetY[j];
                break;
            end
        end
    end

    livesBitMap livesBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_lives_offsetX),
        .offsetY(chosen_lives_offsetY),
        .InsideRectangle(chosen_lives_square_DR),
        .drawingRequest(livesDR),
        .RGBout(livesRGB)
    );

    shooting_cooldown #(
        .SHOOTING_COOLDOWN(PLAYER_SHOT_COOLDOWN)
    ) shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (shotKeyIsPressed & (~player_damaged)),
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
        .missleDR       (missleDR),
        .missleRGB      (missleRGB)
        );



endmodule
