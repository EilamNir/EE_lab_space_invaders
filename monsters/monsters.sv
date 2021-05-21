
module monsters(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
	input logic [4:0] collision,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic monsterDR,
    output logic [7:0] monsterRGB,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 300;
	parameter int INITIAL_Y = 200;
	parameter int X_SPEED = 8;
    parameter int Y_SPEED = -2;
    parameter unsigned MONSTER_AMOUNT = 2;
    parameter unsigned NUMBER_OF_MONSTER_EXPLOSION_FRAMES = 5;

    logic [MONSTER_AMOUNT - 1:0] [10:0] offsetX;
    logic [MONSTER_AMOUNT - 1:0] [10:0] offsetY;
    logic [MONSTER_AMOUNT - 1:0] squareDR;
    logic [MONSTER_AMOUNT - 1:0] [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [MONSTER_AMOUNT - 1:0] [10:0] topLeftX;
    logic signed [MONSTER_AMOUNT - 1:0] [10:0] topLeftY;
    logic [MONSTER_AMOUNT - 1:0] monsterIsHit;
    logic [MONSTER_AMOUNT - 1:0] monster_deactivated;
    logic [MONSTER_AMOUNT - 1:0] shooting_pusle;

    logic [MONSTER_AMOUNT-1:0] missiles_draw_requests;

    genvar i;
    generate
        for (i = 0; i < MONSTER_AMOUNT; i++) begin : generate_monsters
            monsters_move #(.X_SPEED(X_SPEED + (i * 4)), .Y_SPEED(Y_SPEED + (i * 4)), .INITIAL_X(INITIAL_X + (i * 8)), .INITIAL_Y(INITIAL_Y)) monsters_move_inst(
                .clk(clk),
                .resetN(resetN),
                .missile_collision(collision[0] & squareDR[i]),
                .border_collision(collision[1] & squareDR[i]),
                .startOfFrame(startOfFrame),
                .HitEdgeCode(HitEdgeCode),
                .monsterIsHit(monsterIsHit[i]),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i])
                );

            square_object #(.OBJECT_WIDTH_X(32), .OBJECT_HEIGHT_Y(32)) square_object_inst(
                .clk(clk),
                .resetN(resetN),
                .pixelX(pixelX),
                .pixelY(pixelY),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i]),
                .offsetX(offsetX[i]),
                .offsetY(offsetY[i]),
                .drawingRequest(squareDR[i]),
                .RGBout(squareRGB[i])
                );

            delay_signal_by_frames #(.DELAY_FRAMES_AMOUNT(10)) delay_signal_by_frames_inst(
                .clk(clk),
                .resetN(resetN),
                .startOfFrame(startOfFrame),
                .input_signal(monsterIsHit[i]),
                .output_signal(monster_deactivated[i])
                );

            shooting_cooldown #(.SHOOTING_COOLDOWN(90)) shooting_cooldown_inst(
                .clk           (clk),
                .resetN        (resetN),
                .startOfFrame  (startOfFrame),
                .fire_command  (~(monsterIsHit[i])),
                .shooting_pusle(shooting_pusle[i])
                );

            missiles #(.SHOT_AMOUNT(4), .X_SPEED(0), .Y_SPEED(128), .X_OFFSET(15), .Y_OFFSET(28), .MISSILE_COLOR(8'hD0)) missiles_inst (
                .clk            (clk),
                .resetN         (resetN),
                .shooting_pusle (shooting_pusle[i]),
                .startOfFrame   (startOfFrame),
                .collision      ((collision[4] | collision[2])),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .spaceShip_X    (topLeftX[i]),
                .spaceShip_Y    (topLeftY[i]),
                .missleDR       (missiles_draw_requests[i])
                );
                end
    endgenerate

    // Decide on which square object to pass into the bitmap
    logic chosen_square_DR;
    logic [10:0] chosen_offsetX;
    logic [10:0] chosen_offsetY;
    logic chosen_monster_is_hit;
    always_comb begin
        chosen_square_DR = 1'b0;
        chosen_offsetX = 11'b0;
        chosen_offsetY = 11'b0;
        chosen_monster_is_hit = 1'b0;
        for (int j = 0; j < MONSTER_AMOUNT; j++) begin
            // Only save the offset of the first square
            if (squareDR[j] == 1'b1) begin
                // Ignore deactivated monsters
                if (monster_deactivated[j] == 1'b0) begin
                    chosen_square_DR = 1'b1;
                    chosen_offsetX = offsetX[j];
                    chosen_offsetY = offsetY[j];
                    chosen_monster_is_hit = monsterIsHit[j];
                    break;
                end
            end
        end
    end

    chickenBitMap chickenBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_offsetX),
        .offsetY(chosen_offsetY),
        .InsideRectangle(chosen_square_DR),
        .monsterIsHit(chosen_monster_is_hit),
        .drawingRequest(monsterDR),
        .RGBout(monsterRGB),
        .HitEdgeCode(HitEdgeCode)
    );

    assign missleRGB = 8'hD0;
    assign missleDR = (missiles_draw_requests != 0);

endmodule
