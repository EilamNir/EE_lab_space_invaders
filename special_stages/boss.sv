
module boss(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [6:0] collision,
    input coordinate pixelX,
    input coordinate pixelY,

    output logic BossDR,
    output RGB BossRGB,
    output logic boss_dead,

    output logic missleDR,
    output RGB missleRGB
);

    `include "parameters.sv"

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter coordinate INITIAL_X = 287;
	parameter coordinate INITIAL_Y = 49;
	parameter fixed_point X_SPEED = fixed_point'(64);
    parameter fixed_point Y_SPEED = fixed_point'(-25);
    parameter unsigned BOSS_MISSILE_AMOUNT_WIDTH = 8;
    parameter logic unsigned [BOSS_MISSILE_AMOUNT_WIDTH-1:0] BOSS_MISSILE_AMOUNT = 8;
	parameter unsigned LIVES_AMOUNT_WIDTH = 5;
    parameter logic unsigned [LIVES_AMOUNT_WIDTH - 1:0] LIVES_AMOUNT = 3;

    coordinate offsetX;
    coordinate offsetY;
    logic squareDR;
    RGB squareRGB;
    logic [3:0] HitEdgeCode;
    coordinate topLeftX;
    coordinate topLeftY;
    logic Boss_deactivated;
    logic shooting_pusle;
    logic boss_faded;
    logic boss_damaged;
	RGB bitmapRGB;
    logic random_axis;

    logic [BOSS_MISSILE_AMOUNT-1:0] missiles_draw_requests;
    boss_move #(.X_SPEED(X_SPEED), .Y_SPEED(Y_SPEED), .INITIAL_X(INITIAL_X), .INITIAL_Y(INITIAL_Y)) boss_move_inst(
         .clk(clk),
         .resetN(resetN),
         .border_collision(collision[1] & BossDR),
         .startOfFrame(startOfFrame & (enable)),
         .HitEdgeCode(HitEdgeCode),
         .switch_direction_pulse(shooting_pusle),
         .random_axis(random_axis),
         .topLeftX(topLeftX),
         .topLeftY(topLeftY)
     );

    square_object #(.OBJECT_WIDTH_X(64), .OBJECT_HEIGHT_Y(64)) square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(squareDR),
        .RGBout(squareRGB)
    );

    delay_signal_by_frames #(.DELAY_FRAMES_AMOUNT(10)) delay_signal_by_frames_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame & (enable)),
        .input_signal(boss_dead),
        .output_signal(Boss_deactivated)
        );

    shooting_cooldown #(.SHOOTING_COOLDOWN(90)) shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (~(boss_dead)),
        .shooting_pusle(shooting_pusle)
        );

    genvar i;
    generate
        for (i = 0; i < BOSS_MISSILE_AMOUNT; i++) begin : generate_missiles
            missiles #(.SHOT_AMOUNT(4), .X_SPEED(8 + ((i - 4) * 16)), .Y_SPEED(128), .X_OFFSET(31), .Y_OFFSET(60), .MISSILE_COLOR(8'hD0)) missiles_inst (
                .clk            (clk),
                .resetN         (resetN),
                .shooting_pusle (shooting_pusle),
                .startOfFrame   (startOfFrame & (enable)),
                .collision      ((collision[4] | collision[2])),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .spaceShip_X    (topLeftX),
                .spaceShip_Y    (topLeftY),
                .missleDR       (missiles_draw_requests[i])
                );
        end
    endgenerate
  
      player_lives #(.LIVES_AMOUNT(LIVES_AMOUNT), .LIVES_AMOUNT_WIDTH(LIVES_AMOUNT_WIDTH), .PLAYER_DAMAGED_FRAME_AMOUNT(10)) player_lives_inst(
        .clk              (clk),
        .resetN           (resetN),
        .startOfFrame     (startOfFrame & (enable)),
        .missile_collision(collision[0] & BossDR),
        .player_faded     (boss_faded),
        .player_dead      (boss_dead)
        );
	
    ChickenautBitMap ChickenautBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR & !Boss_deactivated),
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
    assign missleRGB = 8'hD0;
    assign missleDR = (missiles_draw_requests != 0);

endmodule
