/* boss module

	control the speed, location and draw request of the boss
	control the missiles of the boss by the missile unit
	the boss has a starting pattern which will change randomly duo to coliisions
	
	one important outpout is that the boss died
	the boss died will be use for determine that a stage is over (win stage)
	
written by Nir Eilam and Gil Kapel, May 18th, 2021 */

module boss(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input collision_t collision,
    input coordinate pixelX,
    input coordinate pixelY,

    output logic BossDR,
    output RGB BossRGB,
    output logic boss_dead,

    output logic missleDR,
    output RGB missleRGB
);

    `include "parameters.sv"

    coordinate offsetX;
    coordinate offsetY;
    logic squareDR;
    edge_code HitEdgeCode;
    coordinate topLeftX;
    coordinate topLeftY;
    logic shooting_pusle;
    logic boss_faded;
    logic boss_damaged;
	RGB bitmapRGB;
    logic random_axis;

    logic [BOSS_MISSILE_AMOUNT-1:0] missiles_draw_requests;
    boss_move #(
        .X_SPEED(BOSS_X_SPEED),
        .Y_SPEED(BOSS_Y_SPEED),
        .INITIAL_X(BOSS_INITIAL_X),
        .INITIAL_Y(BOSS_INITIAL_Y)
    ) boss_move_inst(
         .clk(clk),
         .resetN(resetN),
         .border_collision(collision[COLLISION_ENEMY_ANY_BOUNDARY] & BossDR),
         .startOfFrame(startOfFrame & (enable)),
         .HitEdgeCode(HitEdgeCode),
         .switch_direction_pulse(shooting_pusle),
         .random_axis(random_axis),
         .topLeftX(topLeftX),
         .topLeftY(topLeftY)
     );

    square_object #(
        .OBJECT_WIDTH_X(BOSS_X_SIZE),
        .OBJECT_HEIGHT_Y(BOSS_Y_SIZE)
    ) square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(squareDR)
    );

    shooting_cooldown shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (~(boss_dead)),
        .shooting_cooldown(90),
        .shooting_pusle(shooting_pusle)
        );

    genvar i;
    generate
        for (i = 0; i < BOSS_MISSILE_AMOUNT; i++) begin : generate_missiles
            missiles #(
                .SHOT_AMOUNT(BOSS_SHOT_AMOUNT),
                .X_SPEED(BOSS_MISSILE_X_SPEED + ((i - 4) * 16)),
                .Y_SPEED(BOSS_MISSILE_Y_SPEED),
                .X_OFFSET(BOSS_MISSILE_X_OFFSET),
                .Y_OFFSET(BOSS_MISSILE_Y_OFFSET),
                .MISSILE_COLOR(BOSS_MISSILE_COLOR)
            ) missiles_inst(
                .clk            (clk),
                .resetN         (resetN),
                .shooting_pusle (shooting_pusle),
                .startOfFrame   (startOfFrame & (enable)),
                .collision      ((collision[COLLISION_PLAYER_MISSILE] | collision[COLLISION_MISSILE_FAR_BOUNDARY])),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .spaceShip_X    (topLeftX),
                .spaceShip_Y    (topLeftY),
                .double_y_speed (1'b0),
                .missleDR       (missiles_draw_requests[i])
                );
        end
    endgenerate
  
    lives #(
        .LIVES_AMOUNT_WIDTH(BOSS_LIVES_AMOUNT_WIDTH),
        .LIVES_AMOUNT(BOSS_LIVES_AMOUNT),
        .DAMAGED_FRAME_AMOUNT_WIDTH(BOSS_DAMAGED_FRAME_AMOUNT_WIDTH),
        .DAMAGED_FRAME_AMOUNT(BOSS_DAMAGED_FRAME_AMOUNT)
    ) lives_inst(
        .clk              (clk),
        .resetN           (resetN),
        .startOfFrame     (startOfFrame & (enable)),
        .missile_collision(collision[COLLISION_ENEMY_MISSILE] & BossDR),
        .player_faded     (boss_faded),
        .player_dead      (boss_dead)
        );
	
    ChickenautBitMap ChickenautBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR),
        .drawingRequest(BossDR),
        .RGBout(bitmapRGB),
        .HitEdgeCode(HitEdgeCode)
    );

    // Every time the boss shoots, it should reverse direction in a random axis
    GARO_random_bit GARO_random_bit_inst(
        .clk       (clk),
        .resetN    (resetN),
        .enable    (enable),
        .random_bit(random_axis)
        );

	assign BossRGB = RGB'((boss_faded == 1'b1) ? RGB'('b0) : bitmapRGB) ;
    assign missleRGB = BOSS_MISSILE_COLOR;
    assign missleDR = (missiles_draw_requests != 0);

endmodule
